import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_model.dart';
import '../models/alert_model.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';

// Admin Dashboard: three tabs -
//   1. Pending Tips  - approve/reject community submissions
//   2. Publish News  - post a verified news article
//   3. Broadcast Alert - push an emergency alert to the app
class AdminDashboardScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const AdminDashboardScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: onLogout,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Tips', icon: Icon(Icons.inbox_outlined)),
              Tab(text: 'Publish News', icon: Icon(Icons.article_outlined)),
              Tab(text: 'Broadcast Alert', icon: Icon(Icons.campaign_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PendingTipsTab(),
            _PublishNewsTab(),
            _BroadcastAlertTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Tab 1: Pending Tips ----------------

class _PendingTipsTab extends StatelessWidget {
  const _PendingTipsTab();

  @override
  Widget build(BuildContext context) {
    final news = context.watch<NewsProvider>();

    if (news.pendingTips.isEmpty) {
      return const Center(child: Text('No pending tips to review.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: news.pendingTips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tip = news.pendingTips[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                if (tip.location.isNotEmpty)
                  Text('📍 ${tip.location}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 6),
                Text(tip.description),
                const SizedBox(height: 6),
                Text('Submitted by ${tip.submittedByName}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Reject', style: TextStyle(color: Colors.red)),
                        onPressed: () => context.read<NewsProvider>().reviewTip(tip.id, false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('Approve', style: TextStyle(color: Colors.white)),
                        onPressed: () => context.read<NewsProvider>().reviewTip(tip.id, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------- Tab 2: Publish News ----------------

class _PublishNewsTab extends StatefulWidget {
  const _PublishNewsTab();

  @override
  State<_PublishNewsTab> createState() => _PublishNewsTabState();
}

class _PublishNewsTabState extends State<_PublishNewsTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _category = 'Local';
  bool _publishing = false;

  final _categories = const ['Local', 'Weather', 'Sports', 'Politics', 'Business'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final news = context.read<NewsProvider>();

    setState(() => _publishing = true);
    final article = ArticleModel(
      id: '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _category,
      imageUrl: _imageUrlController.text.trim(),
      authorName: auth.currentUser?.name ?? 'BirtaKhabar Team',
      authorId: auth.currentUser?.id ?? '',
      timestamp: DateTime.now(),
    );
    await news.publishArticle(article);
    setState(() => _publishing = false);

    _titleController.clear();
    _contentController.clear();
    _imageUrlController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('News article published.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Headline', border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter a headline' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category', border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Local'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Article content', border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter content' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)', border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _publishing ? null : _publish,
              child: _publishing
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Publish Article'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Tab 3: Broadcast Alert ----------------

class _BroadcastAlertTab extends StatefulWidget {
  const _BroadcastAlertTab();

  @override
  State<_BroadcastAlertTab> createState() => _BroadcastAlertTabState();
}

class _BroadcastAlertTabState extends State<_BroadcastAlertTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController(text: 'Birtamode');
  AlertSeverity _severity = AlertSeverity.medium;
  bool _sending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _broadcast() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final news = context.read<NewsProvider>();

    setState(() => _sending = true);
    final alert = AlertModel(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      severity: _severity,
      area: _areaController.text.trim(),
      postedByName: auth.currentUser?.name ?? 'Admin',
      timestamp: DateTime.now(),
    );
    await news.broadcastAlert(alert);
    setState(() => _sending = false);

    _titleController.clear();
    _descriptionController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert broadcast to all users.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final news = context.watch<NewsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Alert Title', border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(
                    labelText: 'Affected Area', border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter a description' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<AlertSeverity>(
                  initialValue: _severity,
                  decoration: const InputDecoration(
                    labelText: 'Severity', border: OutlineInputBorder(),
                  ),
                  items: AlertSeverity.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => _severity = v ?? AlertSeverity.medium),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _sending ? null : _broadcast,
                  child: _sending
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Broadcast Alert'),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          const Text('Active Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final alert in news.alerts)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
              title: Text(alert.title),
              subtitle: Text('${alert.area} • ${alert.severity.name}'),
              trailing: TextButton(
                onPressed: () => context.read<NewsProvider>().deactivateAlert(alert.id),
                child: const Text('Resolve'),
              ),
            ),
        ],
      ),
    );
  }
}
