import 'package:flutter/material.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Jobs',
          style: TextStyle(
            color: Color(0xFF121A2C),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Jobs coming soon',
          style: TextStyle(color: Color(0xFF737B8C), fontSize: 14),
        ),
      ),
    );
  }
}
