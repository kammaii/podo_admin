const functions = require("firebase-functions");
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const OpenAI = require("openai");
const {onRequest} = require('firebase-functions/v2/https');

const openai = new OpenAI({
    apiKey: functions.config().openai.key
});

var languages = ['Spanish', 'French', 'German', 'Portuguese', 'Indonesian', 'Russian'];

async function translationRequest(en) {
    let result = [];
    for(let i=0; i<languages.length; i++) {
        let lang = languages[i];
        let response = await openai.chat.completions.create({
            messages: [{ role: "user", content: "Translate '" + en + "' into " + lang + ". Just answer with the translated result only without double quote and repeating the English sentence I wrote."}],
            model: "gpt-3.5-turbo",
        });
        result.push(response.choices[0].message.content);
    }
    return result;
}

function chatGPTFunction(request, response) {
    if(request.method == 'POST') {
        var en = request.body;
        var result = translationRequest(en).then((value) => {
            response.set('Access-Control-Allow-Origin', '*');
            response.status(200).send(value);
        });
    }
}



// export GOOGLE_APPLICATION_CREDENTIALS="G:\keys\podo-49335-firebase-adminsdk-qqve9-4227c667f7.json"

admin.initializeApp();

const mailTransport = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'akorean.danny@gmail.com',
    pass: 'eseymladnsdaokxl',
  },
});

function onFeedbackSent(snap, context) {
  const feedbackData = snap.data();
  const userEmail = feedbackData.email;
  const message = feedbackData.message;
  const mailOptions = {
    from: userEmail,
    to: 'akorean.help@gmail.com', // 수신 이메일 주소
    subject: '[podo] Feedback from the user',
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

exports.onWritingReply = functions.firestore.document('Writings/{writingId}').onUpdate(onWritingReplied);
exports.onPodoMsgActive = functions.firestore.document('PodoMessages/{podoMessageId}').onUpdate(onPodoMsgActivated);
exports.onFeedbackSent = functions.firestore.document('Feedbacks/{feedbackId}').onCreate(onFeedbackSent);
exports.onChatGPT = onRequest({}, chatGPTFunction);