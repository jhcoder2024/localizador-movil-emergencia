import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConversationScreen extends StatelessWidget {
  final String conversationId;
  const ConversationScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(conversationId),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text('Chat - Próximamente'),
      ),
    );
  }
}
