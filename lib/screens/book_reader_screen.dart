import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme.dart';
import '../core/services/book_repository.dart';

class BookReaderScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final BookRepository _bookRepo = BookRepository();
  final FlutterTts _flutterTts = FlutterTts();
  
  List<Map<String, dynamic>> _chapters = [];
  bool _isLoading = true;
  
  Map<String, dynamic>? _selectedChapter;
  String _chapterContent = "";
  bool _isLoadingContent = false;
  
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadChapters();
  }

  void _initTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.4); // slower, child-friendly rate
    _flutterTts.setPitch(1.2); // slightly higher pitch for friendly voice
    
    _flutterTts.setStartHandler(() {
      setState(() => _isPlaying = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      setState(() => _isPlaying = false);
      print("TTS Error: $msg");
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadChapters() async {
    final chapters = await _bookRepo.getChapters(widget.book['id']);
    setState(() {
      _chapters = chapters;
      _isLoading = false;
    });
  }

  Future<void> _loadChapterContent(int chapterId) async {
    setState(() {
      _isLoadingContent = true;
      _flutterTts.stop();
      _isPlaying = false;
    });
    
    final content = await _bookRepo.getChapterContent(chapterId);
    setState(() {
      _selectedChapter = content;
      _chapterContent = content?['content'] ?? "No content available.";
      _isLoadingContent = false;
    });
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() => _isPlaying = false);
    } else {
      if (_chapterContent.isNotEmpty) {
        await _flutterTts.speak(_chapterContent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          widget.book['title'] ?? 'Book',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedChapter != null)
            IconButton(
              icon: Icon(_isPlaying ? Icons.stop_circle : Icons.play_circle_fill),
              color: AppTheme.primary,
              iconSize: 32,
              onPressed: _togglePlay,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedChapter == null
              ? _buildChaptersList()
              : _buildReaderView(),
    );
  }

  Widget _buildChaptersList() {
    if (_chapters.isEmpty) {
      return const Center(child: Text("No chapters found."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24).copyWith(bottom: 120),
      itemCount: _chapters.length,
      itemBuilder: (context, index) {
        final chapter = _chapters[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Text("${index + 1}", style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
            title: Text(
              chapter['title'] ?? 'Chapter ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _loadChapterContent(chapter['id']),
          ),
        );
      },
    );
  }

  Widget _buildReaderView() {
    return Column(
      children: [
        // Reader Header / Controls
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.surfaceContainerLow,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _flutterTts.stop();
                  setState(() {
                    _selectedChapter = null;
                    _isPlaying = false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  _selectedChapter!['title'] ?? 'Chapter',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _isLoadingContent
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24).copyWith(bottom: 100),
                  child: MarkdownBody(
                    data: _chapterContent,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 20, 
                        height: 1.6,
                        letterSpacing: 0.5,
                        color: AppTheme.onSurface,
                      ),
                      h1: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      h2: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      h3: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      listBullet: const TextStyle(fontSize: 20, color: AppTheme.onSurface),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
