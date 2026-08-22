import 'package:flutter/material.dart';

// Facebook-style prompt at the top of the feed:
// "What's happening in Birtamode?" -> opens the tip submission form.
class AppHeader extends StatelessWidget {
  final VoidCallback onTapCompose;

  const AppHeader({super.key, required this.onTapCompose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: onTapCompose,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.deepOrange,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "What's happening in Birtamode?",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              const Icon(Icons.camera_alt_outlined, color: Colors.deepOrange),
            ],
          ),
        ),
      ),
    );
  }
}
