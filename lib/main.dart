import 'package:flutter/material.dart';

void main() {
  runApp(const ImageFlowApp());
}

class ImageFlowApp extends StatelessWidget {
  const ImageFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ImageFlow',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('ImageFlow'),
        ),
      ),
    );
  }
}
