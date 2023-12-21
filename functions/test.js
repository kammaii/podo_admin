const admin = require('firebase-admin');
admin.initializeApp();

//export GOOGLE_APPLICATION_CREDENTIALS="G:/keys/newpodo/podo-49335-5e9743918010.json"

async function onSchedule() {
    const now = new Date();
    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(now.getMonth() - 1);
    let totalBasicUsers = await admin.firestore().collection('Users').where('dateSignIn', '<=', sixMonthsAgo).get();

    console.log(totalBasicUsers.docs[0].get('email'));
}

onSchedule();

