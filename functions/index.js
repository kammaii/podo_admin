const functions = require("firebase-functions");
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  //databaseURL: "https://podo-705c6.firebaseio.com"
  databaseURL: "http://localhost:4000/firestore"
});

let messaging = admin.messaging();

function sendMessage(token, payload) {
  return messaging.sendToDevice(token, payload)
    .then(function(response){
      console.log('Notification sent successfully:',response);
      return response;
    })
    .catch(function(error){
      console.log('Notification sent failed:',error);
    });
}


function onCloudMsgActive(change, context) {
   let afterData = change.after.data();
   if(afterData.isActive) {
       //todo: send fcmMsg to users who have accepted fcm. (or 베스트 리플라이 선정 끝나면 모두에게 보내기?)
   }
}

function onWritingReply(change, context) {
  console.log('!!!!! Writing has replied !!!!!');
  console.log(context.params.writingId);
  console.log(context.eventType);
  console.log('BEFORE:');
  console.log(change.before.data());
  console.log('AFTER:');
  console.log(change.after.data());
  let afterData = change.after.data();
  let status = afterData.status;
  let guid = afterData.guid;
  let userWriting = afterData.userWriting;
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
          title: title.toString(),
          body: body
        }
      };
      sendMessage(fcmToken, payload);
  }

  return true;
}


exports.onWritingReply = functions.firestore.document('Writings/{writingId}').onWrite(onWritingReply);
exports.onCloudMsgActive = functions.firestore.document('CloudMessages/{cloudMessageId}').onWrite(onCloudMsgActive);
