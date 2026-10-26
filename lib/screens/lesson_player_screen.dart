import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../services/app_state.dart';

class LessonPlayerScreen extends StatefulWidget {
  final Course course;
  final Lesson lesson;

  const LessonPlayerScreen({
    super.key,
    required this.course,
    required this.lesson,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final AppState _appState = AppState();
  
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final ScrollController _scrollController = ScrollController();
  int _currentSegmentIndex = 0;
  String? _currentWord;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isPlaying = true);
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() {
        _isPlaying = false;
        _position = _duration;
      });
      _appState.completeLesson(widget.course.id, widget.lesson.id);
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isPlaying = false);
    });

    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      if (mounted) {
        setState(() {
          _currentWord = word;
          // Approximate position based on characters read
          final progress = end / text.length;
          _position = Duration(milliseconds: (_duration.inMilliseconds * progress).toInt());
          _updateCurrentSegment(_position);
        });
      }
    });

    // Estimate total duration (approx 150 words per minute)
    final allText = widget.lesson.content.map((s) => s.text).join(" ");
    final wordCount = allText.split(" ").length;
    _duration = Duration(seconds: (wordCount / 2.5).toInt()); // Rough estimate
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      final textToSpeak = widget.lesson.content.map((s) => s.text).join(". ");
      await _flutterTts.speak(textToSpeak);
      if (mounted) setState(() => _isPlaying = true);
    }
  }

  void _updateCurrentSegment(Duration position) {
    int newIndex = widget.lesson.content.lastIndexWhere((s) => s.timestamp <= position);
    if (newIndex != -1 && newIndex != _currentSegmentIndex) {
      _currentSegmentIndex = newIndex;
      _scrollToSegment(newIndex);
    }
  }

  void _scrollToSegment(int index) {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      index * 110.0, 
      duration: 500.ms,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          _buildHeroBackground(),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildDiagramArea(),
                Expanded(child: _buildSyncTextArea()),
                _buildControlsArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 300,
      child: Image.network(
        widget.course.thumbnail,
        fit: BoxFit.cover,
      ).animate().blur(begin: const Offset(40, 40), end: const Offset(60, 60)),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                BackButton(color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.lesson.title.toUpperCase(),
                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      Text(
                        widget.course.title,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagramArea() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree, color: AppTheme.primary, size: 48),
            const SizedBox(height: 12),
            Text(
              "Step ${_currentSegmentIndex + 1} Visualization",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSyncTextArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: widget.lesson.content.length,
      itemBuilder: (context, index) {
        final line = widget.lesson.content[index];
        final isActive = _currentSegmentIndex == index;
        
        return AnimatedContainer(
          duration: 300.ms,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            line.text,
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              fontFamily: 'Inter',
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              color: isActive ? Colors.white : AppTheme.onSurfaceVariant,
            ),
          ),
        ).animate(target: isActive ? 1 : 0).shimmer(duration: 2.seconds, color: Colors.white10);
      },
    );
  }

  Widget _buildControlsArea() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Slider(
                      value: _position.inMilliseconds.toDouble(),
                      max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 100,
                      activeColor: AppTheme.primary,
                      inactiveColor: AppTheme.primary.withOpacity(0.1),
                      onChanged: (v) {
                        // Slider seek is tricky with TTS, we'll just update position for UI feedback
                        // A real implementation would restart TTS from that point
                      },
                    ),
                  ),
                  Text(_formatDuration(_duration), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlButton(Icons.replay_10, () {}),
                  const SizedBox(width: 32),
                  _playButton(),
                  const SizedBox(width: 32),
                  _controlButton(Icons.forward_10, () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: AppTheme.onSurface, size: 28),
      onPressed: onTap,
    );
  }

  Widget _playButton() {
    return GestureDetector(
      onTap: _togglePlayback,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    return "${d.inMinutes.remainder(60)}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }
}
