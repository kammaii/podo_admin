const functions = require("firebase-functions");
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const sgMail = require('@sendgrid/mail');


// export GOOGLE_APPLICATION_CREDENTIALS="G:\keys\podo-49335-firebase-adminsdk-qqve9-4227c667f7.json"

admin.initializeApp();

sgMail.setApiKey(process.env.SENDGRID_API_KEY)

function onFeedbackSent(snap, context) {
  const feedbackData = snap.data();
  const userEmail = feedbackData.userEmail;
  const message = feedbackData.message;
  const mailOptions = {
    from: 'akorean.help@gmail.com',
    to: 'akorean.help@gmail.com', // 수신 이메일 주소
    subject: '[podo] Feedback from the user',
    text: '${message}\n\n${userEmail}',
  };

  return sgMail.send(mailOptions)
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
   if(!beforeData.isActive && afterData.isActive) {
     const payload = {
       notification: {
         title: 'podo',
         body: afterData.title['ko'],
       }
     };

     return admin.messaging().sendToTopic('allUsers', payload)
       .then((response) => {
         console.log('알림 전송 성공:', response);
         return null;
       })
       .catch((error) => {
         console.log('알림 전송 실패:', error);
       });
   }
   return null;
}

function onWritingReplied(change, context) {
  console.log('!!!!! Writing has replied !!!!!');
  let afterData = change.after.data();
  let status = afterData.status;
  let guid = afterData.guid;
  let userWriting = afterData.userWriting.toString();
  let fcmToken = afterData.fcmToken;

  if(fcmToken != null) {
    let title;
    let body = userWriting;

    if(status == 1 || status == 2) {
      title = "Your writing has been reviewed";
    } else if(status == 3) {
      title = "Your writing has been returned";
    }

    const payload = {
      notification: {
        tag: "writing",
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

exports.onWritingReply = functions.firestore.document('Writings/{writingId}').onUpdate(onWritingReplied);
exports.onPodoMsgActive = functions.firestore.document('PodoMessages/{podoMessageId}').onUpdate(onPodoMsgActivated);
exports.onFeedbackSent = functions.firestore.document('Feedbacks/{feedbackId}').onCreate(onFeedbackSent);
