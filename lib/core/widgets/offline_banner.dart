import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Shows a thin banner when Firestore reports we're serving from cache
/// rather than a live server connection. Wrap any screen's body with this
/// to give the user honest feedback that what they see might be stale.
class OfflineBanner extends StatelessWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // A lightweight, always-available stream just to read connection
      // metadata from — we don't use its actual data, only `.metadata`.
      stream: FirebaseFirestore.instance.collection('__connectivity_probe__').snapshots(),
      builder: (context, snapshot) {
        final isOffline = snapshot.data?.metadata.isFromCache ?? false;
        return Column(
          children: [
            if (isOffline)
              Container(
                width: double.infinity,
                color: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: const Text(
                  '📡 Offline — showing cached data',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}