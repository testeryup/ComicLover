import 'package:flutter/material.dart';
import 'package:getting_started/core/services/localization_service.dart'; // Thêm import

class Authors extends StatelessWidget {
  const Authors({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr('team_member'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Nguyễn Mạnh Đạt - 22010220'),
            const Text('Hoàng Thị Thảo Nhi - 22010062'),
            const Text('Nguyễn Đức Phong - 22010481'),
          ],
        ),
      ),
    );
  }
}
