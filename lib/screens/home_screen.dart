import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/alert_banner.dart';
import '../widgets/ad_card.dart';
import '../widgets/post_card.dart';
import 'alerts_screen.dart';
import 'tip_submission_screen.dart';

// Facebook-style home feed: compose prompt, pinned emergency banner,
// then a scrolling list of news posts with an ad card every 4 posts.
class HomeScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final news = context.watch<NewsProvider>();
    final auth = context.watch<AuthProvider>();
    final uid = auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('BirtaKhabar'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AlertsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: onLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => news.startListening(uid: uid),
        child: ListView(
          children: [
            AppHeader(
              onTapCompose: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TipSubmissionScreen()),
              ),
            ),
            if (news.topAlert != null)
              AlertBanner(
                alert: news.topAlert!,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                ),
              ),
            const SizedBox(height: 4),
            if (news.articles.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No news yet. Pull down to refresh.')),
              ),
            for (int i = 0; i < news.articles.length; i++) ...[
              PostCard(
                article: news.articles[i],
                isSaved: news.isSaved(news.articles[i].id),
                onLike: () => news.likeArticle(news.articles[i].id),
                onSave: () => uid.isEmpty
                    ? null
                    : news.toggleSave(uid, news.articles[i]),
              ),
              // Inline sponsored ad every 4 posts.
              if ((i + 1) % 4 == 0) const AdCard(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
