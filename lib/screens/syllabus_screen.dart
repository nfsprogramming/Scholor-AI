import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../core/services/book_repository.dart';
import 'book_reader_screen.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  final BookRepository _bookRepo = BookRepository();
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;
  
  String? _selectedClass;
  List<Map<String, dynamic>> _books = [];
  bool _isLoadingBooks = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final classes = await _bookRepo.getClasses();
    setState(() {
      _classes = classes;
      _isLoading = false;
    });
  }

  Future<void> _loadBooksForClass(String className) async {
    setState(() {
      _selectedClass = className;
      _isLoadingBooks = true;
    });
    
    // We fetch books for Term I, II, III and combine them for display
    final term1 = await _bookRepo.getBooks(className, 'Term I');
    final term2 = await _bookRepo.getBooks(className, 'Term II');
    final term3 = await _bookRepo.getBooks(className, 'Term III');
    
    final allBooks = <Map<String, dynamic>>[...term1, ...term2, ...term3];
    
    setState(() {
      _books = allBooks;
      _isLoadingBooks = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          "My Syllabus",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: _selectedClass != null 
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.onSurface),
              onPressed: () {
                setState(() {
                  _selectedClass = null;
                  _books = [];
                });
              },
            )
          : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedClass == null
              ? _buildClassList()
              : _buildBooksList(),
    );
  }

  Widget _buildClassList() {
    if (_classes.isEmpty) {
      return const Center(child: Text("No offline books found."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24).copyWith(bottom: 120),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final className = _classes[index]['class_name'];
        return _buildClassCard(className);
      },
    );
  }

  Widget _buildClassCard(String className) {
    return GestureDetector(
      onTap: () => _loadBooksForClass(className),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school, color: AppTheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                className,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
          ],
        ),
      ).animate().fade().slideY(begin: 0.2, end: 0, duration: 400.ms),
    );
  }

  Widget _buildBooksList() {
    if (_isLoadingBooks) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_books.isEmpty) {
      return const Center(child: Text("No books found for this class."));
    }
    
    // Group books by term
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var book in _books) {
      String term = book['term'];
      if (!grouped.containsKey(term)) grouped[term] = [];
      grouped[term]!.add(book);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(24).copyWith(bottom: 120),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        String term = grouped.keys.elementAt(index);
        List<Map<String, dynamic>> termBooks = grouped[term]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                term,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                ),
              ),
            ),
            ...termBooks.map((book) => _buildBookCard(book)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookReaderScreen(book: book),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outline.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.book, color: AppTheme.secondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'] ?? 'Unknown Book',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fade().slideX(begin: 0.1, end: 0, duration: 300.ms),
    );
  }
}
