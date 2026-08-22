import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

// Mock Premium Subscription screen. Real eSewa/Khalti payment gateway
// integration is out of scope for the MVP (see README) - this simulates
// a successful test-mode payment and flips the isPremium flag in Firestore.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _firestoreService = FirestoreService();
  bool _processing = false;

  Future<void> _mockPay(String method) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _processing = true);

    // Simulate a payment gateway round-trip.
    await Future.delayed(const Duration(seconds: 2));
    await _firestoreService.setPremium(user.id, true);
    await auth.refreshUser();

    setState(() => _processing = false);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text(
          'Your $method test payment of Rs. 99 was successful.\n'
          'You are now a Premium (ad-free) member.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isPremium = auth.currentUser?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Go Premium')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.workspace_premium, size: 72, color: Colors.amber),
              const SizedBox(height: 12),
              const Text(
                'BirtaKhabar Premium',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Rs. 99 / month',
                style: TextStyle(fontSize: 18, color: Colors.deepOrange),
              ),
              const SizedBox(height: 20),
              const _BenefitRow(text: 'Ad-free reading experience'),
              const _BenefitRow(text: 'Priority emergency alert notifications'),
              const _BenefitRow(text: 'Support local independent journalism'),
              const SizedBox(height: 28),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(child: Text('You already have Premium. Thank you!')),
                    ],
                  ),
                )
              else ...[
                const Text('Pay with (test mode):', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                _PayButton(
                  label: 'Pay with eSewa',
                  color: const Color(0xFF60BB46),
                  processing: _processing,
                  onTap: () => _mockPay('eSewa'),
                ),
                const SizedBox(height: 10),
                _PayButton(
                  label: 'Pay with Khalti',
                  color: const Color(0xFF5C2D91),
                  processing: _processing,
                  onTap: () => _mockPay('Khalti'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This is a sandbox/test-mode simulation for the college project demo.\n'
                  'No real money is charged.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.deepOrange, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool processing;
  final VoidCallback onTap;

  const _PayButton({
    required this.label,
    required this.color,
    required this.processing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: processing ? null : onTap,
        child: processing
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
