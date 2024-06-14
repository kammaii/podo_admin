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
const axios = require('axios');
const revenueCatKey = functions.config().revenuecat.key;


admin.initializeApp();

// export GOOGLE_APPLICATION_CREDENTIALS="G:\keys\podo-49335-e6a47f70b42a.json"

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
  service: 'gmail',
  auth: {
    user: 'akorean.help@gmail.com',
    pass: gmailKey,
  },
});

function onFeedbackSent(snap, context) {
  const feedbackData = snap.data();
  const userEmail = feedbackData.email;
  const message = feedbackData.message;
  const mailOptions = {
    from: 'Podo Korean <' + userEmail + '>',
    to: 'akorean.help@gmail.com',
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
        }
      };

      return admin.messaging().sendToDevice(fcmToken, payload)
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

async function userCountFunction(context) {
    const db = admin.firestore();
    let today = new Date();

    // 구독자 상태 최신화
    let subscribers = await db.collection('Users').where('status', '==', 2).get();
        for(let i=0; i<subscribers.docs.length; i++) {
            let userId = subscribers.docs[i].get('id');
            console.log(userId);
            const url = "https://api.revenuecat.com/v1/subscribers/"+userId;

            try {
                const response = await axios.get(url, {
                    headers: {
                        'Authorization' : 'Bearer '+revenueCatKey,
                        'Content-Type': 'application/json'
                    }
                });
                let data = response.data['subscriber']['subscriptions']['podo_premium'];
                if(data == null) {
                    data = response.data['subscriber']['subscriptions']['podo_premium_2m_999'];
                }

                let premiumLastPurchase = data['purchase_date'];
                let premiumStart = data['original_purchase_date'];
                let premiumEnd = data['expires_date'];
                let premiumUnsubscribeDetected = data['unsubscribe_detected_at'];
                let status = 2;
                let end = new Date(premiumEnd);
                if(today > end) {
                    status = 1;
                }

                await admin.firestore().collection('Users').doc(userId).update({
                    'premiumStart': premiumStart,
                    'premiumEnd': premiumEnd,
                    'premiumLastPurchase': premiumLastPurchase,
                    'premiumUnsubscribeDetected': premiumUnsubscribeDetected,
                    'status': status
                });
                console.log('Updated user premium date');

            } catch (e) {
                console.error('Error', e);
            }
        }

    // trial 유저 상태 최신화
    let trialEndUsers = await admin.firestore().collection('Users').where('status', '==', 3).where('trialEnd', '<', today).get();
    for(let i=0; i<trialEndUsers.docs.length; i++) {
        let userId = trialEndUsers.docs[i].get('id');
        await admin.firestore().collection('Users').doc(userId).update({'status': 1});
        console.log('User state update: ' + userId);
    }

    // userCount 저장
    let newUsers = await admin.firestore().collection('Users').where('status', '==', 0).get();
    let basicUsers = await admin.firestore().collection('Users').where('status', '==', 1).get();
    let premiumUsers = await admin.firestore().collection('Users').where('status', '==', 2).get();
    let trialUsers = await admin.firestore().collection('Users').where('status', '==', 3).get();
    let data = {
        'date': today,
        'newUsers': newUsers.size,
        'basicUsers': basicUsers.size,
        'premiumUsers': premiumUsers.size,
        'trialUsers': trialUsers.size,
        'totalUsers': newUsers.size + basicUsers.size + premiumUsers.size + trialUsers.size,
    }
    await db.collection('UserCounts').doc().set(data);
}


// 비활성 유저 계정 삭제 알림 코드
async function userCleanUp(context) {
    const now = new Date();
    const aYearAgo = new Date();
    aYearAgo.setMonth(now.getMonth() - 12);
    const aWeekAgo = new Date();
    aWeekAgo.setDate(aWeekAgo.getDate() - 7)
    let totalBasicUsers = await admin.firestore().collection('Users')
        .where('dateSignIn', '<=', aYearAgo)
        .where('status', '!=', 2)
        .get();
    for(let i=0; i<totalBasicUsers.docs.length; i++) {
        let userDoc = totalBasicUsers.docs[i];
        let email = userDoc.get('email');
        console.log('------------------------------');
        console.log('InActiveUser: ' + email);
        let dateEmailSendTimestamp = userDoc.get('dateEmailSend');
        if(dateEmailSendTimestamp) {
            let dateEmailSend = dateEmailSendTimestamp.toDate();
            if(dateEmailSend < aWeekAgo) {
                console.log('REMOVE ACCOUNT');
                let userId = userDoc.get('id');
                await sendEmail(email, 1); // 계정 삭제 이메일
                await admin.auth()
                  .deleteUser(userId)
                  .then(() => {
                    console.log('Successfully deleted user');
                  })
                  .catch((error) => {
                    console.log('Error deleting user:', error);
                  });
                await deleteSubCollection('Users/'+userId+'/Histories');
                await deleteSubCollection('Users/'+userId+'/FlashCards');
                await deleteSubCollection('Users/'+userId+'/Readings');
                userDoc.ref.delete();
            } else {
                console.log('Pending Account Deletion');
            }
        } else {
            await sendEmail(email, 0); // 계정 삭제 경고 이메일
            console.log('Email sent');
            admin.firestore().collection('Users').doc(totalBasicUsers.docs[i].id).update({'dateEmailSend': now});
        }
    }
}

async function sendEmail(userEmail, msgType) {
  let mailOptions;
  if(msgType == 0) {
      mailOptions = {
        from: 'Podo Korean <akorean.help@gmail.com>',
        to: userEmail,
        subject: 'Account Deletion Notice',
        text: 'Hello,\n\nThank you for using Podo Korean.\n\nYour activity is valuable to us and contributes greatly to the ongoing improvement of our service.\n\nWe want to inform you that if you haven\'t logged in for the past a year, your account will be deleted within the next 7 days.\n\nPlease be aware that once your account is deleted, you will lose access to any stored information or data, and account recovery will not be possible.\n\nHowever, if you log in before your account is deleted, it will automatically be transitioned to an active status.\n\nIf you have any questions or need assistance regarding your account, please feel free to contact us. We are here to help.\n\nThank you.\n\nPodo Korean',
      };
  } else if (msgType == 1) {
    mailOptions = {
          from: 'Podo Korean <akorean.help@gmail.com>',
          to: userEmail,
          subject: 'Account Deletion Notice',
          text: 'Hello,\n\nThank you for using Podo Korean.\n\nWe regularly review unused accounts for customer account security and data management.\n\nAs previously notified, accounts that have not logged in for over a year will be automatically deleted.\n\nRegrettably, your account has been automatically deleted because you have not logged in for a week since the notification a week ago.\n\nTherefore, it is not possible to recover any data.\n\nThank you once again for using Podo Korean.\n\nWe are committed to continually improving our service to offer a better experience.\n\nThank you.\n\nThe Podo Korean'
    };
  }

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

async function deleteSubCollection(path) {
    let collectionDocs = await admin.firestore().collection(path).get();
    for(let i=0; i<collectionDocs.docs.length; i++) {
        let doc = collectionDocs.docs[i];
        console.log('DocId:' + doc.id);
        doc.ref.delete();
    }
}



exports.onWritingReply = functions.firestore.document('Writings/{writingId}').onUpdate(onWritingReplied);
exports.onPodoMsgActive = functions.firestore.document('PodoMessages/{podoMessageId}').onUpdate(onPodoMsgActivated);
exports.onFeedbackSent = functions.firestore.document('Feedbacks/{feedbackId}').onCreate(onFeedbackSent);
exports.onDeepl = onRequest(onDeeplFunction);
exports.onUserCount = functions.pubsub.schedule('0 0 * * *').timeZone('Asia/Seoul').onRun(userCountFunction);
exports.onEmailSend = functions.pubsub.schedule('0 0 * * *').timeZone('Asia/Seoul').onRun(userCleanUp);