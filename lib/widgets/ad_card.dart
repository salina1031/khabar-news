import 'package:flutter/material.dart';

// Inline "Sponsored" card that appears embedded within the news stream,
// visually distinct from real news posts with a subtle badge.
class AdCard extends StatelessWidget {
  final String businessName;
  final String message;

  const AdCard({
    super.key,
    this.businessName = 'Himalayan Java, Birtamode',
    this.message = 'Fresh coffee, cozy seats. Visit us for 10% off this week!',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade200,
                  child: const Icon(Icons.storefront, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(businessName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Sponsored',
                            style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined, size: 40, color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
