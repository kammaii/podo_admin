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

          // 활성 유저 수
          let activeNew = 0;
          let activeBasic = 0;
          let activeTrial = 0;
          let activePremium = 0;

     const now = new Date();
     const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
     const yesterday = new Date(today);
     yesterday.setDate(today.getDate()-1);


          const activeUsers = await admin.firestore().collection('Users')
              .where('dateSignIn', '<=', admin.firestore.Timestamp.fromDate(today))
              .where('dateSignIn', '>', admin.firestore.Timestamp.fromDate(yesterday))
              .get();

          console.log('-----------------------------------------')
          console.log('[Active Users Counting]')
          console.log('todayUTC: ' +today)
          console.log('tomorrowUTC: '+yesterday)
          console.log('Active Users: ' + activeUsers.docs.length)
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

          console.log('activeNew: '+ activeNew);
          console.log('activeBasic: '+activeBasic);
          console.log('activeTrial: '+activeTrial);
          console.log('activePremium: '+ activePremium);



}

async function test3() {
      let now = new Date();

        // 활성 유저 수
        let activeNew = 0;
        let activeBasic = 0;
        let activeTrial = 0;
        let activePremium = 0;
        let newUsers = 0;

        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        const yesterday = new Date(today);
        yesterday.setDate(today.getDate()-1);

        const activeUsers = await admin.firestore().collection('Users')
            .where('dateSignIn', '<=', admin.firestore.Timestamp.fromDate(today))
            .where('dateSignIn', '>', admin.firestore.Timestamp.fromDate(yesterday))
            .get();

        console.log('-----------------------------------------')
        console.log('[Active Users Counting]')
        console.log('Active Users: ' + activeUsers.docs.length)
        for(let i=0; i<activeUsers.docs.length; i++) {
            let activeUser = activeUsers.docs[i];
            let userId = activeUser.get('id');
            let status = activeUser.get('status');
            let dateSignUp = activeUser.get('dateSignUp');
            console.log(userId);
            console.log(dateSignUp);

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
                newUsers++;
                console.log('신규');
            }
        }
}

test3();
