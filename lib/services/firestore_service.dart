import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/article_model.dart';
import '../models/alert_model.dart';
import '../models/tip_model.dart';
import '../models/user_model.dart';

// FirestoreService centralizes every Firestore read/write used by the app.
// Collections used: users, news, alerts, newsTips (see firestore.rules).
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- News Articles ----------------

  Stream<List<ArticleModel>> streamArticles() {
    return _db
        .collection('news')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ArticleModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> publishArticle(ArticleModel article) {
    return _db.collection('news').add(article.toMap());
  }

  Future<void> incrementLike(String articleId) {
    return _db.collection('news').doc(articleId).update({
      'likesCount': FieldValue.increment(1),
    });
  }

  // ---------------- Emergency Alerts ----------------

  Stream<List<AlertModel>> streamActiveAlerts() {
    return _db
        .collection('alerts')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final alerts =
          snap.docs.map((d) => AlertModel.fromMap(d.data(), d.id)).toList();
      // Sort critical -> low, most recent first within each severity.
      alerts.sort((a, b) {
        final severityCompare = b.severity.index.compareTo(a.severity.index);
        if (severityCompare != 0) return severityCompare;
        return b.timestamp.compareTo(a.timestamp);
      });
      return alerts;
    });
  }

  Future<void> broadcastAlert(AlertModel alert) {
    return _db.collection('alerts').add(alert.toMap());
  }

  Future<void> deactivateAlert(String alertId) {
    return _db.collection('alerts').doc(alertId).update({'isActive': false});
  }

  // ---------------- Community News Tips ----------------

  Stream<List<TipModel>> streamPendingTips() {
    return _db
        .collection('newsTips')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TipModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> submitTip(TipModel tip) {
    return _db.collection('newsTips').add(tip.toMap());
  }

  Future<void> updateTipStatus(String tipId, String status) {
    return _db.collection('newsTips').doc(tipId).update({'status': status});
  }

  // ---------------- Users ----------------

  Future<void> setPremium(String uid, bool isPremium) {
    return _db.collection('users').doc(uid).update({'isPremium': isPremium});
  }

  Future<UserModel> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return UserModel.fromMap(doc.data()!, uid);
  }

  // ---------------- Saved / Bookmarked Articles ----------------

  Future<void> saveArticle(String uid, ArticleModel article) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('saved')
        .doc(article.id)
        .set(article.toMap());
  }

  Future<void> unsaveArticle(String uid, String articleId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('saved')
        .doc(articleId)
        .delete();
  }

  Stream<List<ArticleModel>> streamSavedArticles(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('saved')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ArticleModel.fromMap(d.data(), d.id)).toList());
  }
}
