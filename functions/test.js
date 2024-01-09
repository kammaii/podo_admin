const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const auth = require('firebase/auth');
const app = require('firebase-admin/app');

//admin.initializeApp();
app.initializeApp();

//export GOOGLE_APPLICATION_CREDENTIALS="G:/keys/newpodo/podo-49335-5e9743918010.json"

// 1. get users email who didn't sign in for 6 months.
// 2. send email to users
// 3. after a week check users who still didn't sign in.
// 4. remove auth and firestore

const mailTransport = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'akorean.danny@gmail.com',
    pass: 'eseymladnsdaokxl',
  },
});

function sendEmail(userEmail) {
  const mailOptions = {
    from: 'akorean.help@gmail.com',
    to: userEmail, // 수신 이메일 주소
    subject: '[podo] Notification',
    text: 'Your account will be removed! if you don\'t sign in a week',
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

async function onSchedule() {
    const now = new Date();
    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(now.getMonth() - 1); // todo: should change
    const aWeekAgo = new Date();
    aWeekAgo.setDate(aWeekAgo.getDate() - 7)
    let totalBasicUsers = await admin.firestore().collection('Users')
//        .where('emailLastSend', '<=', aWeekAgo)
        .where('dateSignIn', '<=', sixMonthsAgo)
        .where('userType', '==', 'test')
        .get();
    for(let i=0; i<totalBasicUsers.docs.length; i++) {
        // send Email and update email notification sent date
        let userDoc = totalBasicUsers.docs[i];
        let email = userDoc.get('email');
        let emailLastSend = userDoc.get('emailLastSend');
        if(emailLastSend) {
            console.log('InActiveUser');
            if(emailLastSend < aWeekAgo) {
            console.log('REMOVE ACCOUNT');
                //remove account
                let userId = userDoc.get('id');
                console.log('ADMIN:' + auth.getAuth);

//                auth.getAuth()
//                  .getUser(userId)
//                  .then((userRecord) => {
//                    // See the UserRecord reference doc for the contents of userRecord.
//                    console.log(`Successfully fetched user data: ${userRecord.toJSON()}`);
//                  })
//                  .catch((error) => {
//                    console.log('Error fetching user data:', error);
//                  });

            }
        } else {
            sendEmail(email);
            console.log('Email send: ' + email);
            admin.firestore().collection('Users').doc(totalBasicUsers.docs[i].id).update({'emailLastSend': now});

        }
    }
    //console.log(totalBasicUsers.docs[0].get('email'));
}

onSchedule();

