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

const mailTransport = nodemailer.createTransport({
    host: "mail.podokorean.com",
    port: 465,
    secure: true,
    auth: {
        user: 'contact@podokorean.com',
        pass: emailKey,
    },
});

const mailTransportDanny = nodemailer.createTransport({
    host: "mail.podokorean.com",
    port: 465,
    secure: true,
    auth: {
        user: 'danny@podokorean.com',
        pass: emailKey,
    },
});


const mailTransportNoReply = nodemailer.createTransport({
    host: "mail.podokorean.com",
    port: 465,
    secure: true,
    auth: {
      user: 'noreply@podokorean.com',
      pass: emailKey,
    },
    pool: true,
    rateLimit: true,
    maxConnections: 2,
    maxMessages: 10,
});

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

function onFeedbackSent(snap, context) {
  const feedbackData = snap.data();
  const userEmail = feedbackData.email;
  const message = feedbackData.message;
  const mailOptions = {
    from: 'Podo Korean <' + userEmail + '>',
    to: 'contact@podokorean.com',
    subject: 'Feedback from the user',
    text: message + "\n\n" + userEmail,
  };

  return mailTransport.sendMail(mailOptions)
    .then(() => {
      console.log('이메일 전송 성공');
      return null;
    })
    .catch((error) => {
      console.error('이메일 전송 실패:', error);
      return null;
    });
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

async function sendEmail(userEmail, msgType) {
  let mailOptions;
  if(msgType == 0) {    // 계정 삭제 알림 1
      mailOptions = {
        from: 'Podo Korean <noreply@podokorean.com>',
        to: userEmail,
        subject: 'Account Deletion Notice',
        html: `
          <p>Hello,</p>
          <p>Thank you for using Podo Korean.</p>
          <p>Your activity is valuable to us and contributes greatly to the ongoing improvement of our service.</p>
          <p>We want to inform you that if you haven’t logged in for the past year, your account will be deleted within the next 7 days.</p>
          <p>Please be aware that once your account is deleted, you will lose access to any stored information or data, and account recovery will not be possible.</p>
          <p>However, if you log in before your account is deleted, it will automatically be transitioned to an active status.</p>
          <p>If you have any questions or need assistance regarding your account, please feel free to <a href="mailto:contact@podokorean.com">contact us</a>. We are here to help.</p>
          <p>Thank you.</p>
          <p>Podo Korean</p>
        `,
      };
  } else if (msgType == 1) {    // 계정 삭제 알림 2
    mailOptions = {
          from: 'Podo Korean <noreply@podokorean.com>',
          to: userEmail,
          subject: 'Account Deletion Notice',
          text: 'Hello,\n\nThank you for using Podo Korean.\n\nWe regularly review unused accounts for customer account security and data management.\n\nAs previously notified, accounts that have not logged in for over a year will be automatically deleted.\n\nRegrettably, your account has been automatically deleted because you have not logged in for a week since the notification a week ago.\n\nTherefore, it is not possible to recover any data.\n\nThank you once again for using Podo Korean.\n\nWe are committed to continually improving our service to offer a better experience.\n\nThank you.\n\nThe Podo Korean'
    };
  }

  return mailTransportNoReply.sendMail(mailOptions)
    .then(() => {
      console.log('이메일 전송 성공');
      return true;
    })
    .catch((error) => {
      console.error('이메일 전송 실패:', error);
      return false;
    });
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
   aWeekAgo.setDate(aWeekAgo.getDate() - 7)
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
               let emailResult = await sendEmail(email, 1); // 계정 삭제 이메일
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
           let emailResult = await sendEmail(email, 0); // 계정 삭제 경고 이메일
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

async function sendWelcomeEmail(user) {
  let userEmail = user.email;
  let displayName = user.displayName || "there";

  let mailOptions = {
      from: 'Podo Korean <contact@podokorean.com>',
      to: userEmail,
      subject: '[Podo Korean] 안녕하세요? Let’s Start Your Korean Journey Together 🌸',
      html: `
      <head>
        <meta charset="UTF-8" />
        <style>
            /* 기본 리셋 & 간단한 인라인 스타일 */
            body { margin:0; padding:0; font-family: Arial, Helvetica, sans-serif; background:#f7f7f7; }
            .container { max-width:600px; margin:0 auto; background:#ffffff; padding:24px; }
            h1 { color:#6c2bd9; font-size:24px; margin-bottom:12px; }
            h2 { color:#333333; font-size:18px; margin:24px 0 8px; }
            p  { color:#555555; line-height:1.6; margin:8px 0; }
            ul { padding-left:20px; }
            li { margin:6px 0; }
            .button {
              display:inline-block; background:#6c2bd9; color:#ffffff !important;
              padding:12px 24px; border-radius:6px; text-decoration:none; font-weight:bold;
            }
            .footer { font-size:12px; color:#999999; margin-top:32px; }
          </style>
        </head>
        <body>
          <div class="container">
            <!-- 인사말 -->
            <h1>Welcome to Podo Korean!</h1>
            <p>Hi <strong>${displayName}</strong>,</p>
            <p>Thank you for installing <strong>Podo Korean</strong>. We know learning a new language can feel overwhelming—so we’re here to make it simple, accurate, and fun.</p>

            <!-- 핵심 가치 -->
            <h2>Why Podo Korean?</h2>
            <p>With bite‑sized lessons and a friendly community, you’ll start using real‑life Korean faster than you think.</p>

            <!-- 기능 하이라이트 -->
            <h2>Here’s what you can try today:</h2>
            <ul>
              <li>📚 <strong>Topic &amp; Grammar Modes</strong> – follow a structured path or focus on specific points</li>
              <li>✨ <strong>Korean Bites</strong> – master one useful phrase in just 10 seconds a day</li>
              <li>📝 <strong>Writing Corrections</strong> – receive quick feedback from native teachers</li>
              <li>🤝 <strong>Community</strong> – ask questions, share wins, and stay motivated together</li>
            </ul>

            <!-- 지원 안내 -->
            <p>Any questions? Just reply to this email—we’re always happy to help.</p>

            <!-- 서명 -->
            <p>Happy learning, and see you in the app!<br /><br />
               Warm regards,<br />
               <strong>Danny</strong><br />
               Podo Korean Team</p>

            <!-- 푸터 -->
            <p class="footer">
              © 2023 Podo Korean. All rights reserved.<br />
            </p>
          </div>
        </body>
      `,
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

async function sendPremiumEmail(request, response) {
    let userEmail = request.body['email'];
    let userName = request.body['name'];
    let results = [];
    const mailOptions = {
        from: '정우 | Danny <danny@podokorean.com>',
        to: userEmail,
        subject: '[Podo Korean] 고맙습니다!',
        html: '
            <head>
              <meta charset="UTF-8" />
              <title>Personal Thank‑You</title>
              <style>
                body { margin:0; padding:0; font-family: Georgia, 'Times New Roman', serif; background:#faf7ff; }
                .wrapper { max-width:620px; margin:0 auto; background:#ffffff; padding:32px 28px; border-radius:10px; }
                h1   { color:#6633cc; font-size:26px; margin:0 0 18px; }
                p    { color:#4a4a4a; font-size:16px; line-height:1.6; margin:14px 0; }
                em   { color:#6633cc; font-style:normal; font-weight:bold; }
                .perks { background:#f3eeff; padding:18px 22px; border-radius:8px; }
                .perks li { margin:8px 0; }
                .footer { font-size:12px; color:#999999; margin-top:32px; text-align:center; }
              </style>
            </head>
            <body>
              <div class="wrapper">
                <!-- 인사말 -->
                <h1>Hi&nbsp;<span style="color:#6633cc;">${userName}</span>,</h1>

                <!-- 개인적 감사 -->
                <p>
                  I’m <strong>Danny</strong>, the person behind <em>Podo Korean</em>.
                  I just noticed you upgraded to <em>Premium</em> and wanted to reach out <u>personally</u> to say
                  <strong>thank you</strong>. Knowing that you chose to trust my little purple app on your Korean‑learning
                  journey genuinely makes my day.
                </p>

                <!-- 따뜻한 배경 이야기 -->
                <p>
                  When I began teaching Korean back in 2017, I dreamed of building a space where learners could feel both
                  <em>trustworthy</em> and <em>cared for</em>. Your support keeps that dream alive—and lets me keep adding new lessons,
                  readings, and surprises just for you.
                </p>

                <!-- 프리미엄 혜택(간결) -->
                <div class="perks">
                  <p style="margin-top:0;"><strong>Because you’re Premium, here’s what’s waiting for you:</strong></p>
                  <ul style="padding-left:20px;">
                    <li>Full access to <strong>every lesson &amp; reading</strong>—no locks, no limits.</li>
                    <li><strong>Unlimited flashcards</strong> to collect, edit, and review anytime.</li>
                    <li>Priority <strong>writing corrections</strong> from native teachers.</li>
                    <li>A downloadable <strong>Hangul workbook</strong> for offline practice.</li>
                    <li>And, of course, <strong>zero ads</strong>—just pure, focused learning.</li>
                  </ul>
                </div>

                <!-- 개인적 초대 -->
                <p>
                  If you ever feel stuck—or simply want to share a win—hit reply.
                  Your email will land straight in my inbox, and I’ll be happy to help.
                </p>

                <!-- 마무리 -->
                <p>
                  Thank you again for believing in <em>Podo Korean</em>.
                  Let’s make your Korean sparkle together!
                </p>

                <p style="margin-top:32px;">
                  Warm hugs from Seoul,<br />
                  <strong>정우 | Danny</strong><br />
                  Creator &amp; Teacher, Podo Korean
                </p>

                <!-- 푸터 -->
                <p class="footer">
                  © 2023 Podo Korean. All rights reserved.<br />
                </p>
              </div>
            </body>
        ',
      };

      return mailTransportDanny.sendMail(mailOptions)
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



exports.onWritingReply = functions.firestore.document('Writings/{writingId}').onUpdate(onWritingReplied);
exports.onPodoMsgActive = functions.firestore.document('PodoMessages/{podoMessageId}').onUpdate(onPodoMsgActivated);
exports.onFeedbackSent = functions.firestore.document('Feedbacks/{feedbackId}').onCreate(onFeedbackSent);
exports.onDeepl = onRequest(onDeeplFunction);
exports.onContact = onRequest(onContactFunction);
exports.onKoreanBiteFcm = onRequest(onKoreanBiteFunction);
exports.onUserCount = functions.runWith({timeoutSeconds: 540}).pubsub.schedule('0 0 * * *').timeZone('Asia/Seoul').onRun(userCount);
exports.onUserCleanUp = functions.runWith({timeoutSeconds: 540}).pubsub.schedule('30 23 * * *').timeZone('Asia/Seoul').onRun(userCleanUp);
//export.onSendWelcomeEmail = functions.auth.user().onCreate(sendWelcomeEmail);
//exports.onSendPremiumEmail = onRequest(sendPremiumEmail);

