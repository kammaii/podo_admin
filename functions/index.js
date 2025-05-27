const functions = require("firebase-functions");
const admin = require('firebase-admin');
const auth = require('firebase/auth');
const nodemailer = require('nodemailer');
const OpenAI = require("openai");
const {onRequest} = require('firebase-functions/v1/https');
const {v4: uuidv4} = require('uuid');
const deepl = require('deepl-node');
const deeplKey = functions.config().deepl.key;
const translator = new deepl.Translator(deeplKey);
const gmailKey = functions.config().gmail.key;
const gmailKey_noReply = functions.config().gmail_noreply.key;
const emailKey = functions.config().email.key;
const axios = require('axios');
const revenueCatKey = functions.config().revenuecat.key;
const fs = require("fs");
const path = require("path");
const zohoRefreshToken = functions.config().zoho.refreshToken;
const zohoClientId = functions.config().zoho.clientId;
const zohoClientSecret = functions.config().zoho.clientSecret;
const { SendMailClient } = require("zeptomail");
const cors = require('cors')({ origin: 'https://www.podokorean.com' });


admin.initializeApp();

// export GOOGLE_APPLICATION_CREDENTIALS="D:\keys\podo-49335-e6a47f70b42a.json"

var languages = ['es', 'fr', 'de', 'pt-BR', 'id', 'ru'];

async function onDeeplFunction(request, response) {
    let message = request.body;
    let results = [];
    for(let i=0; i<languages.length; i++) {
        let result = await translator.translateText(message, null, languages[i]);
        results.push(result.text);
    }
    response.set('Access-Control-Allow-Origin', '*');
    response.status(200).send(results);
}

async function onContactFunction(request, response) {
    let body = request.body;
    let name = body['name'];
    let email = body['email'];
    let subject = body['subject'];
    let message = body['message'];

  const mailOptions = {
    from: 'Contact Us <' + email + '>',
    to: 'contact@podokorean.com',
    subject: subject,
    text: message + "\n\n" + name+ "\n" + email,
  };

  return mailTransport.sendMail(mailOptions)
    .then(() => {
      console.log('이메일 전송 성공');
      response.set('Access-Control-Allow-Origin', '*');
      response.status(200).send('Email sent');
      return null;
    })
    .catch((error) => {
      console.error('이메일 전송 실패:', error);
      response.set('Access-Control-Allow-Origin', '*');
      response.status(500).send('ERROR');
      return null;
    });
}

async function onFeedbackSent(snap, context) {
  const feedbackData = snap.data();
  const userEmail = feedbackData.email;
  const message = feedbackData.message;
  const url = 'https://api.zeptomail.com/v1.1/email';
  const token = functions.config().zepto.token;
  const client = new SendMailClient({ url, token });

      try {
          const response = await client.sendMail({
            subject: '[Feedback] From Podo Korean app user',
            from: {
              address: 'contact@podokorean.com',
              name: 'Podo Korean'
            },
            to: [
              {
                email_address: {
                  address: 'contact@podokorean.com',
                  name: 'Podo Korean'
                }
              }
            ],
            htmlbody: message + "\n\n" + userEmail
          });

          console.log("✅ Email sent via ZeptoMail:");
        } catch (error) {
          console.error("❌ ZeptoMail send error:", error);
        }
}

function onPodoMsgActivated(change, context) {
   let beforeData = change.before.data();
   let afterData = change.after.data();
   let shouldSendMessage = false;
   let payload;

   if(!beforeData.isActive && afterData.isActive) {
     shouldSendMessage = true;
     payload = {
       data: {
        'tag': 'podo_message',
       },
       notification: {
         title: 'podo',
         body: afterData.title['ko'],
       }
     };
   }

   if(!beforeData.hasBestReply && afterData.hasBestReply) {
     shouldSendMessage = true;
     payload = {
       data: {
        'tag': 'podo_message',
       },
       notification: {
         title: 'podo',
         body: 'The selection for the best reply has been completed! Please check it.',
       }
     };
   }

   if(shouldSendMessage) {
     return admin.messaging().sendToTopic('allUsers', payload)
       .then((response) => {
         console.log('알림 전송 성공:', response);
         return null;
       })
       .catch((error) => {
         console.log('알림 전송 실패:', error);
       });
   } else {
     return null;
   }
}

function onWritingReplied(change, context) {
  console.log('!!!!! Writing has replied !!!!!');
  let beforeData = change.before.data();
  let afterData = change.after.data();
  let status = afterData.status;
  let guid = afterData.guid;
  let userWriting = afterData.userWriting.toString();
  let fcmToken = afterData.fcmToken;

  if(beforeData.status == 0) {
    if(fcmToken != null) {
      let title;
      let body = userWriting;

      if(status == 1 || status == 2) {
        title = "Your writing has been reviewed";
      } else if(status == 3) {
        title = "Your writing has been returned";
      }

      const payload = {
        data: {
          'tag': 'writing',
        },
        notification: {
          title: title,
          body: body
        },
        token: fcmToken,
      };

      return admin.messaging().send(payload)
        .then(function(response){
          console.log('Notification sent successfully:',response);
          return null;
        })
      .catch(function(error){
        console.log('Notification sent failed:',error);
      });
    }
  }
}

async function userCount(context) {
    const db = admin.firestore();
    let now = new Date();

    // 구독자 상태 최신화
    let premiumUsers = 0;
    let subscribers = await db.collection('Users').where('status', '==', 2).get();
    console.log('-----------------------------------------')
    console.log('[Subscriber status update]')
    for(let i=0; i<subscribers.docs.length; i++) {
        let userId = subscribers.docs[i].get('id');
        console.log('-----------------------------------------')
        console.log(userId);
        const url = "https://api.revenuecat.com/v1/subscribers/"+userId;

        try {
            const response = await axios.get(url, {
                headers: {
                    'Authorization' : 'Bearer '+revenueCatKey,
                    'Content-Type': 'application/json'
                }
            });
            const subscriber = response.data?.subscriber;
            const entitlement = subscriber.entitlements;
            const premiumData = entitlement['premium'];
            if(premiumData != null && !premiumData['product_identifier'].includes('rc_promo')) {
                let premiumStart = premiumData['purchase_date'];
                let premiumEnd = premiumData['expires_date'];
                let status = 2;
                let end = new Date(premiumEnd);
                if(now > end) {
                    console.log('Expired premium');
                    let fcmToken = subscribers.docs[i].get('fcmToken');
                    if(fcmToken) {
                        try {
                            await admin.messaging().unsubscribeFromTopic([fcmToken], 'premiumUsers');
                            await admin.messaging().unsubscribeFromTopic([fcmToken], 'newUsers');
                            await admin.messaging().unsubscribeFromTopic([fcmToken], 'trialUsers');
                            await admin.messaging().unsubscribeFromTopic([fcmToken], 'trialExpiredUsers');
                            await admin.messaging().subscribeToTopic([fcmToken], 'premiumExpiredUsers');
                            await admin.messaging().subscribeToTopic([fcmToken], 'basicUsers');
                        } catch (e) {
                            console.error('Failed to update subscription for premiumExpiredUser', e);
                        }
                    }
                    status = 1;
                    //todo: zoho 연락처 검색해서 tag:premium_expired 추가
                } else {
                    console.log('Valid premium')
                    premiumUsers++;
                }
                let firstKey = Object.keys(subscriber.subscriptions)[0];
                await admin.firestore().collection('Users').doc(userId).update({
                    'premiumStart': premiumStart,
                    'premiumEnd': premiumEnd,
                    'originalPurchaseDate': subscriber.subscriptions[firstKey].original_purchase_date,
                    'status': status
                });
                console.log('Updated premium status');
            }
        } catch (e) {
            console.error('Error', e);
        }
    }

    // trial 유저 상태 최신화
    let trialEndUsers = await admin.firestore().collection('Users').where('status', '==', 3).where('trialEnd', '<', now).get();
    console.log('-----------------------------------------')
    console.log('[Trial expired users update]')
    for(let i=0; i<trialEndUsers.docs.length; i++) {
        let userId = trialEndUsers.docs[i].get('id');
        console.log('-----------------------------------------')
        console.log(userId);
        let fcmToken = trialEndUsers.docs[i].get('fcmToken');
        await admin.firestore().collection('Users').doc(userId).update({'status': 1});
        if(fcmToken) {
            try {
                await admin.messaging().unsubscribeFromTopic([fcmToken], 'trialUsers');
                await admin.messaging().unsubscribeFromTopic([fcmToken], 'newUsers');
                await admin.messaging().subscribeToTopic([fcmToken], 'trialExpiredUsers');
                await admin.messaging().subscribeToTopic([fcmToken], 'basicUsers');
            } catch(e) {
                console.error('Failed to update subscription for trialExpiredUser', e);
            }

        }
        console.log('Updated trial status')
    }

    // 활성 유저 수
    let activeNew = 0;
    let activeBasic = 0;
    let activeTrial = 0;
    let activePremium = 0;
    let signUpUsers = 0;

    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), 0, 0);
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);

    const activeUsers = await admin.firestore().collection('Users')
        .where('dateSignIn', '<=', admin.firestore.Timestamp.fromDate(today))
        .where('dateSignIn', '>', admin.firestore.Timestamp.fromDate(yesterday))
        .get();

    console.log('-----------------------------------------')
    console.log('[Active Users Counting]')
    console.log('Active Users: ' + activeUsers.docs.length)
    console.log('Today: ' + today)
    for(let i=0; i<activeUsers.docs.length; i++) {
        let activeUser = activeUsers.docs[i];
        let userId = activeUser.get('id');
        let status = activeUser.get('status');
        let dateSignUp = activeUser.get('dateSignUp');

        if(status === 0) {
            activeNew++;
        } else if(status === 1) {
            activeBasic++;
        } else if(status === 2) {
            activePremium++;
        } else if(status === 3) {
            activeTrial++;
        }

        // 신규 가입자 수 계산
        if (dateSignUp.toDate() <= today && dateSignUp.toDate() > yesterday) {
            signUpUsers++;
        }
    }

    // userCount 저장
    let statusNew = await admin.firestore().collection('Users').where('status', '==', 0).get();
    let statusBasic = await admin.firestore().collection('Users').where('status', '==', 1).get();
    let statusTrial = await admin.firestore().collection('Users').where('status', '==', 3).get();
    let data = {
        'date': now,
        'signUpUsers': signUpUsers,
        'statusNew': statusNew.size,
        'statusBasic': statusBasic.size,
        'statusPremium': premiumUsers,
        'statusTrial': statusTrial.size,
        'totalUsers': statusNew.size + statusBasic.size + premiumUsers + statusTrial.size,
        'activeNew': activeNew,
        'activeBasic': activeBasic,
        'activeTrial': activeTrial,
        'activePremium': activePremium,
        'activeTotal' : activeNew + activeBasic + activeTrial + activePremium,
    }

    let aHourAgo = new Date();
    aHourAgo.setHours(aHourAgo.getHours() - 1);

    let snapshot = await admin.firestore().collection('UserCounts')
        .where('userCleanUpDate', '>=', aHourAgo)
        .orderBy('userCleanUpDate', 'desc')
        .limit(1)
        .get();
    if(snapshot.empty) {
        console.log('Doc is not exists');
        return;
    }
    await snapshot.docs[0].ref.update(data);
    console.log('User Count Update Completed');
}

async function sendZeptoEmail(userEmail, msgType, mergeInfo = null) {
  let url = "https://api.zeptomail.com/v1.1/email/template";
  const token = functions.config().zepto.token;
  const templateKeys = {
      0: functions.config().zepto.templates.cleanup1,
      1: functions.config().zepto.templates.cleanup2,
      2: functions.config().zepto.templates.welcome,
      3: functions.config().zepto.templates.welcome_with_workbook,
  };
  const subjects = {
      0: '[Podo Korean] Your account is scheduled for deletion ⏳',
      1: '[Podo Korean] Your account has been deleted ✅',
      2: 'Welcome to Podo Korean! Let’s start your journey 🌟',
      3: 'Welcome to Podo Korean! Let’s start your journey 🌟',
  }
  const template_key = templateKeys[msgType];
  const emailSubject = subjects[msgType];
  const client = new SendMailClient({ url, token });
  let sender;
  if(msgType == 2 || msgType == 3) {
    sender = "contact@podokorean.com";
  } else {
    sender = "noreply@podokorean.com";
  }

  try {
    const emailPayload = {
        subject: emailSubject,
        template_key,
        from: {
          address: sender,
          name: "Podo Korean"
        },
        to: [
          {
            email_address: {
              address: userEmail
            }
          }
        ],
    };

    if(mergeInfo) {
        emailPayload.merge_info = mergeInfo;
    }

    const response = await client.sendMail(emailPayload);
    console.log("✅ Email sent via ZeptoMail:");
    return true;
  } catch (error) {
    console.error("❌ ZeptoMail send error:", error);
    return false;
  }
}

// 비활성 유저 계정 삭제 알림 코드
async function userCleanUp(context) {
   const db = admin.firestore();
   let now = new Date();

   let deletedUsers = 0;
   let emailSentUsers = 0;
   const aYearAgo = new Date();
   aYearAgo.setMonth(now.getMonth() - 12);
   const aWeekAgo = new Date();
   aWeekAgo.setDate(aWeekAgo.getDate() - 7);
   let inactiveUsers = await admin.firestore().collection('Users')
       .where('dateSignIn', '<=', aYearAgo)
       .where('status', '!=', 2)
       .get();
   for(let i=0; i<inactiveUsers.docs.length; i++) {
       let userDoc = inactiveUsers.docs[i];
       let email = userDoc.get('email');
       console.log('------------------------------');
       console.log('InActiveUser: ' + email);
       let dateEmailSendTimestamp = userDoc.get('dateEmailSend');
       if(dateEmailSendTimestamp) {
           let dateEmailSend = dateEmailSendTimestamp.toDate();
           if(dateEmailSend < aWeekAgo) {
               console.log('REMOVE ACCOUNT');
               let userId = userDoc.get('id');
               let emailResult = await sendZeptoEmail(email, 1); // 계정 삭제 이메일
               if(emailResult) {
                   await admin.auth()
                     .deleteUser(userId)
                     .then(() => {
                       console.log('Successfully deleted user');
                       deletedUsers++;
                     })
                     .catch((error) => {
                       console.log('Error deleting user:', error);
                     });
                   await deleteSubCollection('Users/'+userId+'/Histories');
                   await deleteSubCollection('Users/'+userId+'/FlashCards');
                   await deleteSubCollection('Users/'+userId+'/Readings');
                   userDoc.ref.delete();
               }
           } else {
               console.log('Pending Account Deletion');
           }
       } else {
           let emailResult = await sendZeptoEmail(email, 0); // 계정 삭제 경고 이메일
           if(emailResult) {
               console.log('Email sent');
               emailSentUsers++;
               admin.firestore().collection('Users').doc(inactiveUsers.docs[i].id).update({'dateEmailSend': now});
           }
       }
   }
   let data = {
       'userCleanUpDate': now,
       'deletedUsers': deletedUsers,
       'emailSentUsers': emailSentUsers,
   }
   await db.collection('UserCounts').doc().set(data);
}

async function deleteSubCollection(path) {
    let collectionDocs = await admin.firestore().collection(path).get();
    for(let i=0; i<collectionDocs.docs.length; i++) {
        let doc = collectionDocs.docs[i];
        console.log('DocId:' + doc.id);
        doc.ref.delete();
    }
}

function onKoreanBiteFunction(request, response) {
    let body = request.body;
    let koreanBiteId = body['koreanBiteId'];
    let title = body['title'];
    let content = body['content'];

    let payload = {
      data: {
       'tag': 'koreanBite',
       'koreanBiteId': koreanBiteId,
      },
      notification: {
        title: title,
        body: content,
      },
      topic: 'allUsers',
    };

    response.set('Access-Control-Allow-Origin', '*');
    admin.messaging().send(payload).then((res) => {
      console.log('알림 전송 성공:', res);
      response.status(200).send('알림 전송 성공');
    })
    .catch((error) => {
      console.log('알림 전송 실패:', error);
      response.status(500).send('알림 전송 실패: '+ error);
    });
}

async function refreshAccessToken() {
    console.log('리프레시 토큰!');
    const refreshToken = functions.config().zoho.refresh_token;
    const clientId = functions.config().zoho.client_id;
    const clientSecret = functions.config().zoho.client_secret;

    const res = await fetch('https://accounts.zoho.com/oauth/v2/token', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({
            client_id: clientId,
            client_secret: clientSecret,
            refresh_token: refreshToken,
            grant_type: 'refresh_token',
        }),
    });

    const result = await res.json();

    if(!result.access_token) {
        throw new Error('Failed to refresh access token!');
    }

    return result.access_token;
}

async function getValidAccessToken() {
    const docRef = admin.firestore().collection('Tokens').doc('zoho');
    const doc = await docRef.get();

    if(doc.exists) {
        const data = doc.data();
        const accessToken = data.access_token;
        const issuedAt = data.access_token_on || 0;
        const now = Date.now();
        console.log('IssuedAt', data.access_token_on);
        console.log('Now', now);

        if((now - issuedAt) < 50 * 60 * 1000) {     // 50분
            console.log('유효한 access 토큰!');
            return accessToken;
        }
    }

    const newToken = await refreshAccessToken();
    console.log('뉴토큰!', newToken);

    await docRef.update({
        access_token: newToken,
        access_token_on: Date.now(),
    });

    return newToken;

}

async function sendRequestToZoho(url, method, requestBody = null) {
    let accessToken = await getValidAccessToken();
    console.log('URL', url);

    const options = {
        method: method,
        headers: {
            Authorization: `Zoho-oauthtoken ${accessToken}`,
        },
    };

    if(method !== 'GET' && requestBody) {
        options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
        options.body = new URLSearchParams(requestBody);
    }

    const res = await fetch(url, options);
    const result = await res.json();
    console.log('Result', result);

    if (result.status === 'error') {
        throw new Error(result.message || 'Zoho API error');
    }

    return result;
}

async function addContactToZoho(request, response) {
    try {
        response.set('Access-Control-Allow-Origin', '*');
        const {email, name, source} = request.body;
        if(!email) return response.status(400).send('Missing email');

        let requestBody = {
            contactinfo: JSON.stringify({
                "First Name": name || '',
                "Contact Email": email,
            }),
            listkey: '3z6187e64413036ac5e15cc240c22e8660774c3bad914a0a1ed1639dbe18dead80',
            resfmt: 'JSON',
            source: source,
            stage: 'Seed',
            created_on: new Date().toISOString(),
        };

        // 앱 설치 여부 확인 (firestore)
        const ref = admin.firestore().collection('Users');
        const doc = await ref.where('email', '==', email).limit(1).get();

        if(!doc.empty) {
            console.log('Firestore User Exist: ' + email);
            const data = doc.docs[0].data();
            const userId = data.id;
            const userName = data.name;
            const dateSignUp = data.dateSignUp.toDate().toISOString();

            requestBody['user_id'] = userId;
            requestBody['app_installed_on'] = dateSignUp;
            if(!name && userName) {
                let contactInfo = JSON.parse(requestBody.contactinfo);
                contactInfo['First Name'] = userName;
                requestBody.contactinfo = JSON.stringify(contactInfo);
            }
        }
        await sendRequestToZoho('https://campaigns.zoho.com/api/v1.1/json/listsubscribe', 'POST', requestBody);
        // downloaded_app 태그는 zoho campaign 자동화에서 입력됨.
        response.status(200).send('Succeed to add contact');

    } catch (e) {
        console.error('❌ Error adding contact to Zoho:', e.message);
        response.status(500).send({ success: false, message: e.message });
    }
}

async function updateContactToZoho({
    email,
    userId,
    appInstalledOn,
    premiumOn,
    premiumExpiredOn,
    premiumReactivatedOn,
}) {
    if (!email) throw new Error('Missing email');

    const requestBody = {
        contactinfo: JSON.stringify({
          "Contact Email": email,
        }),
        resfmt: 'JSON',
    };

    const optionalFields = {
        user_id: userId,
        app_installed_on: appInstalledOn ? new Date(appInstalledOn).toISOString() : null,
        premium_on: premiumOn ? new Date(premiumOn).toISOString() : null,
        premium_expired_on: premiumExpiredOn,
        premium_reactivated_on: premiumReactivatedOn,
    };

    for (const [key, value] of Object.entries(optionalFields)) {
        if (value) {
          requestBody[key] = value;
        }
    }

    await sendRequestToZoho(
        'https://campaigns.zoho.com/api/v1.1/json/listsubscribe',
        'POST',
        requestBody
    );
}

async function assignTagToZoho(email, tag) {
    if(!email) return response.status(400).send('Missing email');

    const queryParams = new URLSearchParams({
        tagName: tag,
        lead_email: email,
        resfmt: 'JSON',
    }).toString();

    const url = 'https://campaigns.zoho.com/api/v1.1/tag/associate?' + queryParams;

    await sendRequestToZoho(url, 'GET');
}

async function sendWelcomeEmail(request, response) {
    // 앱 signUp 시 실행
    try {
        response.set('Access-Control-Allow-Origin', '*');
        const {email, userId, appInstalledOn} = request.body;
        console.log(email);
        if(!email) return response.status(400).send('Missing email');

        let requestBody = {
            listkey: '3z6187e64413036ac5e15cc240c22e8660774c3bad914a0a1ed1639dbe18dead80',
            resfmt: 'JSON',
        }

        // 이메일 구독 중인지 확인
        const result = await sendRequestToZoho('https://campaigns.zoho.com/api/v1.1/getlistsubscribers', 'POST', requestBody);
        const contacts = result['list_of_details'] || [];
        const emailExists = contacts.some(
            (contact) => contact['contact_email'].toLowerCase() === email.toLowerCase()
        );

        if(emailExists) {
            console.log('이메일 구독중');
            console.log('워크북 미포함 이메일 전송');
            await sendZeptoEmail(email, 2);

            console.log('Zoho Contact 필드 입력');
            await updateContactToZoho({
                email: email,
                userId: userId,
                appInstalledOn: appInstalledOn,
            });

            console.log('Zoho Contact 태그 입력');
            await assignTagToZoho(email, 'downloaded_app');

            response.status(200).send('Sent welcome email without workbook');

        } else {
            console.log('신규 유저');
            console.log('워크북 포함 이메일 전송');
            await sendZeptoEmail(email, 3, {'email': email});
            response.status(200).send('Sent welcome email with workbook');
        }

    } catch(e) {
        console.error('❌ Error in sendWelcomeEmail:', e.message);
        response.status(500).send({ success: false, message: e.message });
    }
}

exports.onWritingReply = functions.firestore.document('Writings/{writingId}').onUpdate(onWritingReplied);
exports.onPodoMsgActive = functions.firestore.document('PodoMessages/{podoMessageId}').onUpdate(onPodoMsgActivated);
exports.onFeedbackSent = functions.firestore.document('Feedbacks/{feedbackId}').onCreate(onFeedbackSent);
exports.onDeepl = onRequest(onDeeplFunction);
exports.onContact = onRequest(onContactFunction);
exports.onKoreanBiteFcm = onRequest(onKoreanBiteFunction);
exports.onUserCount = functions.runWith({timeoutSeconds: 540}).pubsub.schedule('0 0 * * *').timeZone('Asia/Seoul').onRun(userCount);
exports.onUserCleanUp = functions.runWith({timeoutSeconds: 540}).pubsub.schedule('30 23 * * *').timeZone('Asia/Seoul').onRun(userCleanUp);
exports.onAddContactToZoho = onRequest(addContactToZoho);
exports.onSendWelcomeEmail = onRequest(sendWelcomeEmail);


