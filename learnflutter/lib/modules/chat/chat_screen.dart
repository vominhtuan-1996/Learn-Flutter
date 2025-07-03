import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');

  void _onSendPressed(types.PartialText message) async {
    final newMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, newMessage);
    });

    final botReply = await sendPromptToAI(message.text);

    final botMessage = types.TextMessage(
      author: const types.User(id: 'bot'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: botReply,
    );

    setState(() {
      _messages.insert(0, botMessage);
    });
  }

  Future<String> sendPromptToAI(String prompt) async {
    final response = await http.post(
      Uri.parse('http://172.27.9.25:11434/api/generate'), // Dùng IP thật ở đây
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'mistral',
        'prompt': prompt,
        'stream': false,
      }),
    );

    final results = jsonDecode(response.body)['response'];
    // Gọi local model hoặc server AI backend ở đây
    return "Mô hình của bạn trả lời: $results";
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      child: Scaffold(
        body: Chat(
          messages: _messages,
          onSendPressed: _onSendPressed,
          user: _user,
        ),
      ),
    );
  }
}
