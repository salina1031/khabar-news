import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../models/alert_model.dart';
import '../models/tip_model.dart';
import '../services/firestore_service.dart';

// NewsProvider owns the live Firestore streams for articles, alerts and
// tips, and exposes simple lists + actions to the UI.
class NewsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ArticleModel> _articles = [];
  List<AlertModel> _alerts = [];
  List<TipModel> _pendingTips = [];
  final Set<String> _savedIds = {};

  StreamSubscription? _articlesSub;
  StreamSubscription? _alertsSub;
  StreamSubscription? _tipsSub;
  StreamSubscription? _savedSub;

  List<ArticleModel> get articles => _articles;
  List<AlertModel> get alerts => _alerts;
  List<TipModel> get pendingTips => _pendingTips;
  AlertModel? get topAlert => _alerts.isNotEmpty ? _alerts.first : null;

  bool isSaved(String articleId) => _savedIds.contains(articleId);

  // Call once after login to start listening to live data.
  void startListening({String? uid}) {
    _articlesSub?.cancel();
    _alertsSub?.cancel();
    _tipsSub?.cancel();

    _articlesSub = _firestoreService.streamArticles().listen((data) {
      _articles = data;
      notifyListeners();
    });
    _alertsSub = _firestoreService.streamActiveAlerts().listen((data) {
      _alerts = data;
      notifyListeners();
    });
    _tipsSub = _firestoreService.streamPendingTips().listen((data) {
      _pendingTips = data;
      notifyListeners();
    });

    if (uid != null) {
      _savedSub?.cancel();
      _savedSub = _firestoreService.streamSavedArticles(uid).listen((data) {
        _savedIds
          ..clear()
          ..addAll(data.map((a) => a.id));
        notifyListeners();
      });
    }
  }

  void stopListening() {
    _articlesSub?.cancel();
    _alertsSub?.cancel();
    _tipsSub?.cancel();
    _savedSub?.cancel();
    _articles = [];
    _alerts = [];
    _pendingTips = [];
    _savedIds.clear();
  }

  Future<void> likeArticle(String articleId) {
    return _firestoreService.incrementLike(articleId);
  }

  Future<void> toggleSave(String uid, ArticleModel article) async {
    if (_savedIds.contains(article.id)) {
      await _firestoreService.unsaveArticle(uid, article.id);
    } else {
      await _firestoreService.saveArticle(uid, article);
    }
  }

  Future<void> submitTip(TipModel tip) => _firestoreService.submitTip(tip);

  Future<void> reviewTip(String tipId, bool approve) {
    return _firestoreService.updateTipStatus(tipId, approve ? 'approved' : 'rejected');
  }

  Future<void> publishArticle(ArticleModel article) {
    return _firestoreService.publishArticle(article);
  }

  Future<void> broadcastAlert(AlertModel alert) {
    return _firestoreService.broadcastAlert(alert);
  }

  Future<void> deactivateAlert(String alertId) {
    return _firestoreService.deactivateAlert(alertId);
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
