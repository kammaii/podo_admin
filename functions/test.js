const functions = require("firebase-functions");
const admin = require('firebase-admin');
const auth = require('firebase/auth');
const {onRequest} = require('firebase-functions/v1/https');
const axios = require('axios');
const nodemailer = require('nodemailer');
const KEY = "sk_wFBDSaBEJaZWeecTyfYKNqHQmnIwT";
const USER_ID = "l9yvPV5AqOgErjuggMlptBrN4dG3";
const gmailKey = 'utdu jhvp yrhm wrdp';
const revenueCatKey = 'sk_wFBDSaBEJaZWeecTyfYKNqHQmnIwT';



admin.initializeApp();

async function test(context) {
    const db = admin.firestore();
try {
        const en = await db.collection("Users").where("language", "==", "en").get();
        const fr = await db.collection("Users").where("language", "==", "fr").get();
        const de = await db.collection("Users").where("language", "==", "de").get();
        const es = await db.collection("Users").where("language", "==", "es").get();
        const id = await db.collection("Users").where("language", "==", "id").get();
        const pt = await db.collection("Users").where("language", "==", "pt").get();
        const ru = await db.collection("Users").where("language", "==", "ru").get();

        const enUserCount = en.size;
        const frUserCount = fr.size;
        const deUserCount = de.size;
        const esUserCount = es.size;
        const idUserCount = id.size;
        const ptUserCount = pt.size;
        const ruUserCount = ru.size;

        console.log(`Users with language "en": ${enUserCount}`);
        console.log(`Users with language "fr": ${frUserCount}`);
        console.log(`Users with language "de": ${deUserCount}`);
        console.log(`Users with language "es": ${esUserCount}`);
        console.log(`Users with language "id": ${idUserCount}`);
        console.log(`Users with language "pt": ${ptUserCount}`);
        console.log(`Users with language "ru": ${ruUserCount}`);

        return { enUserCount, frUserCount };
    } catch (error) {
        console.error("Error counting users:", error);
        throw error;
    }
}

async function test2() {
      const db = admin.firestore();
          let today = new Date();
          let premiumUsers = 0;

          // 구독자 상태 최신화
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
                      if(today > end) {
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
                      await admin.firestore().collection('Users').doc(userId).update({
                          'premiumStart': premiumStart,
                          'premiumEnd': premiumEnd,
                          'originalPurchaseDate': subscriber.original_purchase_date,
                          'status': status
                      });
                      console.log('Updated premium status');
                  }
              } catch (e) {
                  console.error('Error', e);
              }
          }

          // trial 유저 상태 최신화
          let trialEndUsers = await admin.firestore().collection('Users').where('status', '==', 3).where('trialEnd', '<', today).get();
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

          const now = new Date();

          const koreaOffset = 9 * 60 * 60 * 1000; // 현재 시간을 UTC+9로 변환
          const koreaNow = new Date(now.getTime() + koreaOffset);

          const todayKorea = new Date(koreaNow);
          todayKorea.setUTCHours(0, 0, 0, 0); // UTC 자정 기준으로 설정
          const tomorrowKorea = new Date(todayKorea);
          tomorrowKorea.setUTCDate(todayKorea.getUTCDate() + 1); // 다음 날 자정

          const todayUTC = new Date(todayKorea.getTime() - koreaOffset); // UTC로 변환
          const tomorrowUTC = new Date(tomorrowKorea.getTime() - koreaOffset);

          const activeUsers = await admin.firestore().collection('Users')
              .where('dateSignIn', '>=', admin.firestore.Timestamp.fromDate(todayUTC))
              .where('dateSignIn', '<', admin.firestore.Timestamp.fromDate(tomorrowUTC))
              .get();

          console.log('-----------------------------------------')
          console.log('[Active Users Counting]')
          for(let i=0; i<activeUsers.docs.length; i++) {
              let userId = activeUsers.docs[i].get('id');
              let status = activeUsers.docs[i].get('status');
              console.log('-----------------------------------------')
              console.log(userId);
              if(status === 0) {
                  activeNew++;
              } else if(status === 1) {
                  activeBasic++;
              } else if(status === 2) {
                  activePremium++;
              } else if(status === 3) {
                  activeTrial++;
              }
          }

          // userCount 저장
          let newUsers = await admin.firestore().collection('Users').where('status', '==', 0).get();
          let basicUsers = await admin.firestore().collection('Users').where('status', '==', 1).get();
          let trialUsers = await admin.firestore().collection('Users').where('status', '==', 3).get();
          let data = {
              'date': today,
              'newUsers': newUsers.size,
              'basicUsers': basicUsers.size,
              'premiumUsers': premiumUsers,
              'trialUsers': trialUsers.size,
              'totalUsers': newUsers.size + basicUsers.size + premiumUsers + trialUsers.size,
              'activeNew': activeNew,
              'activeBasic': activeBasic,
              'activeTrial': activeTrial,
              'activePremium': activePremium,
              'activeTotal' : activeNew + activeBasic + activeTrial + activePremium,
          }
          await db.collection('UserCounts').doc().set(data);

}

test();
