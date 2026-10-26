import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme.dart';
import 'dart:ui';
import '../services/retrieval_service.dart';
import '../services/ai_inference_service.dart';

class Message {
  final String text;
  final bool isUser;
  final String time;

  Message({required this.text, required this.isUser, required this.time});
}

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final RetrievalService _retrievalService = RetrievalService();
  final AiInferenceService _aiInferenceService = AiInferenceService();
  
  final List<Message> _messages = [
    Message(
      text: "Hello! I'm **Scholor AI** 🧠 — your offline tutor, running entirely on your device.\n\nAsk me about **Python**, **AI/ML**, **math**, **data structures**, or any subject in your course library!",
      isUser: false,
      time: "Now",
    ),
  ];

  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize our offline AI services when the chat screen loads
    _initOfflineAI();
  }
  
  Future<void> _initOfflineAI() async {
    await _retrievalService.init();
    await _aiInferenceService.init();
  }

  @override
  void dispose() {
    _aiInferenceService.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final userText = _messageController.text.trim();
    
    setState(() {
      _messages.add(
        Message(
          text: userText,
          isUser: true,
          time: TimeOfDay.now().format(context),
        ),
      );
      _messageController.clear();
      _isTyping = true;
    });
    
    _scrollToBottom();
    _generateOfflineResponse(userText);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _generateOfflineResponse(String query) async {
    // 1. Retrieve grounded textbook context from SQLite
    List<String> contextChunks = await _retrievalService.search(query);
    
    // 2. Pass query and context to ONNX Inference Engine
    String aiResponse = await _aiInferenceService.generateResponse(query, contextChunks);

    if (!mounted) return;

    setState(() {
      _messages.add(
        Message(
          text: aiResponse,
          isUser: false,
          time: TimeOfDay.now().format(context),
        ),
      );
      _isTyping = false;
    });
    
    _scrollToBottom();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          _buildBackgroundElements(),

          Column(
            children: [
              _buildAppBar(),
              _buildSuggestionRow(),
              Expanded(child: _buildChatList()),
              _buildInputBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Positioned(
      top: 100,
      right: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.secondary.withOpacity(0.04),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 10.seconds),
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppTheme.surface.withOpacity(0.7),
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.smart_toy, color: AppTheme.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Scholor AI",
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const Text(
                    "RUNNING OFFLINE · ALL TOPICS",
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.1, end: 0),
        ),
      ),
    );
  }

  Widget _buildSuggestionRow() {
    final suggestions = [
      "🐍 Python Basics",
      "🤖 What is LLM?",
      "📚 Mastery Tips",
      "⚡ Sorting Algorithms",
      "🧬 Machine Learning",
      "📐 Calculus Explained",
      "📦 Data Structures",
      "🌐 Offline Features",
      "💡 Feynman Technique",
    ];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              label: Text(suggestions[index], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              backgroundColor: AppTheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onPressed: () {
                _messageController.text = suggestions[index];
                _sendMessage();
              },
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        final msg = _messages[index];
        return _buildChatBubble(msg);
      },
    );
  }

  Widget _buildChatBubble(Message msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: msg.isUser ? AppTheme.primary : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(msg.isUser ? 24 : 8),
            bottomRight: Radius.circular(msg.isUser ? 8 : 24),
          ),
          boxShadow: msg.isUser ? [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: msg.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: msg.isUser ? Colors.white : AppTheme.onSurface, fontSize: 15, height: 1.5, fontFamily: 'Inter'),
                strong: TextStyle(color: msg.isUser ? Colors.white : AppTheme.secondary, fontWeight: FontWeight.w900),
                listBullet: TextStyle(color: msg.isUser ? Colors.white : AppTheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg.time,
              style: TextStyle(color: msg.isUser ? Colors.white70 : AppTheme.onSurfaceVariant.withOpacity(0.5), fontSize: 10),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text("Scholor AI is typing...", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.onSurfaceVariant)),
      ),
    ).animate().fadeIn();
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppTheme.surfaceContainerHighest, width: 1),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "Ask Scholor AI anything...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppTheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
