import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/article_model.dart';

// Facebook-style post card for a single news article in the feed.
class PostCard extends StatelessWidget {
  final ArticleModel article;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onSave;

  const PostCard({
    super.key,
    required this.article,
    required this.isSaved,
    required this.onLike,
    required this.onSave,
  });

  void _shareToWhatsApp() {
    // share_plus opens the native share sheet; on most phones WhatsApp
    // will be one of the listed targets.
    Share.share('${article.title}\n\nRead more on BirtaKhabar app.');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Publisher row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepOrange.shade100,
                  child: Text(
                    article.authorName.isNotEmpty
                        ? article.authorName[0].toUpperCase()
                        : 'B',
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(article.authorName,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (article.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                size: 14, color: Colors.blue),
                          ],
                        ],
                      ),
                      Text(
                        '${timeago.format(article.timestamp)} • ${article.category}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Title & content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(article.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Text(
              article.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Image placeholder
          if (article.imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(color: Colors.grey.shade200),
                errorWidget: (c, u, e) => _imagePlaceholder(),
              ),
            )
          else
            _imagePlaceholder(),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(
                  icon: Icons.thumb_up_outlined,
                  label: 'Like (${article.likesCount})',
                  onTap: onLike,
                ),
                _actionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  onTap: () {},
                ),
                _actionButton(
                  icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                  label: 'Save',
                  onTap: onSave,
                  color: isSaved ? Colors.deepOrange : null,
                ),
                _actionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: _shareToWhatsApp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color ?? Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
