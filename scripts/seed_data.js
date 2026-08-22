// Optional demo-data seeder for BirtaKhabar.
// Usage:
//   1. Download a Firebase Admin SDK service account key from
//      Firebase Console > Project Settings > Service Accounts, save it in
//      this scripts/ folder (it's already in .gitignore so it won't be
//      committed).
//   2. cd scripts && npm install firebase-admin
//   3. node seed_data.js
//
// This populates a handful of sample news articles and an emergency alert
// so the app has something to show right after setup, for the defense demo.

const admin = require('firebase-admin');
const serviceAccount = require('./YOUR_SERVICE_ACCOUNT_KEY.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function seed() {
  const news = [
    {
      title: 'New bridge inaugurated over Mechi River',
      content:
        'The long-awaited concrete bridge connecting Birtamode to the eastern wards was formally opened today, easing daily commutes for thousands of residents.',
      category: 'Local',
      imageUrl: '',
      authorName: 'BirtaKhabar Team',
      authorId: 'seed',
      publishedAt: admin.firestore.Timestamp.now(),
      likesCount: 12,
      views: 340,
      isVerified: true,
      isSponsored: false,
    },
    {
      title: 'Jhapa district sees record tea exports this season',
      content:
        'Local tea estates report a strong harvest, with export volumes up 18% compared to last year, boosting the regional economy.',
      category: 'Business',
      imageUrl: '',
      authorName: 'BirtaKhabar Team',
      authorId: 'seed',
      publishedAt: admin.firestore.Timestamp.now(),
      likesCount: 5,
      views: 120,
      isVerified: true,
      isSponsored: false,
    },
  ];

  const alerts = [
    {
      title: 'Heavy rainfall warning',
      description:
        'The Meteorological Department has issued a heavy rainfall warning for Jhapa district over the next 48 hours. Residents near riverbanks should stay alert.',
      severity: 'medium',
      area: 'Birtamode & surrounding wards',
      postedByName: 'Admin',
      postedAt: admin.firestore.Timestamp.now(),
      isActive: true,
    },
  ];

  for (const article of news) {
    await db.collection('news').add(article);
  }
  for (const alert of alerts) {
    await db.collection('alerts').add(alert);
  }

  console.log('Seed data added successfully.');
}

seed().catch(console.error);
