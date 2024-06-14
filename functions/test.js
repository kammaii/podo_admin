const functions = require("firebase-functions");
const admin = require('firebase-admin');
const auth = require('firebase/auth');
const {onRequest} = require('firebase-functions/v1/https');
const axios = require('axios');

const KEY = "sk_wFBDSaBEJaZWeecTyfYKNqHQmnIwT";
const USER_ID = "l9yvPV5AqOgErjuggMlptBrN4dG3";


admin.initializeApp();

//async function test(context) {
//    const now = new Date();
//    const sixMonthsAgo = new Date();
//    sixMonthsAgo.setMonth(now.getMonth() - 6);
//    const aWeekAgo = new Date();
//    aWeekAgo.setDate(aWeekAgo.getDate() - 7)
//    let totalBasicUsers = await admin.firestore().collection('Users')
//        .where('dateSignIn', '<=', sixMonthsAgo)
//        .where('status', '!=', 2)
//        .get();
//    for(let i=0; i<totalBasicUsers.docs.length; i++) {
//        let userDoc = totalBasicUsers.docs[i];
//        let email = userDoc.get('email');
//        console.log('------------------------------');
//        console.log('InActiveUser: ' + email);
//    }
//}

async function test() {
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
                        'Authorization' : 'Bearer '+KEY,
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

test();
