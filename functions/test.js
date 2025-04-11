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

const mailTransport = nodemailer.createTransport({
    host: "mail.podokorean.com",
    port: 465,
    secure: true,
    auth: {
        user: 'contact@podokorean.com',
        pass: 'gabman84!',
    },
});

async function test(context) {

  let payload = {
    data: {
     'tag': 'koreanBite',
     'koreanBiteId': '6f23ea0d-960e-4db6-ba60-74f1eb9d0561',
    },
    notification: {
      title: 'title',
      body: 'content',
    },
    token: 'flOsINyaT1-iO-bDtUnIvu:APA91bGSC8vmswJRCQnXxsA9BP5urYQR0Vr_b_foaVVxRnwye4duBCLbS9XCsjG6pSmpTq5H1U9mJnU_PmLT-4kKsu2gLgRVA-nyZRL-JJw4bj2dNUB8dnE',
  };

  admin.messaging().send(payload).then((res) => {
    console.log('알림 전송 성공:', res);
  })
  .catch((error) => {
    console.log('알림 전송 실패:', error);
  });
}



async function test2() {
  let userEmail = 'gabmanpark@gmail.com';
  let displayName = 'park' || "there";

  let mailOptions = {
      from: '"Podo Korean" <contact@podokorean.com>' ,
      to: 'kammaii@naver.com',
      subject: '[Podo Korean] Welcome! Let’s Start Your Korean Journey Together 🌸',
      html: `
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
    <h1>Hi&nbsp;<span style="color:#6633cc;">[Name]</span>,</h1>

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
      <strong>Danny</strong><br />
      Creator &amp; Teacher, Podo Korean
    </p>

    <!-- 푸터 -->
    <p class="footer">
      © 2025 Podo Korean. All rights reserved.<br />
      Need anything? Reply to this email or adjust preferences <a href="[MANAGE_LINK]">here</a>.
    </p>
  </div>
</body>
      `,
  };

  mailTransport.sendMail(mailOptions)
      .then(() => {
        console.log('이메일 전송 성공');
      })
      .catch((error) => {
        console.error('이메일 전송 실패:', error);
      });
}



test2();
