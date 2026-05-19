import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/news_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/news_model.dart';
import '../../models/user_model.dart';
import 'package:intl/intl.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsService _newsService = NewsService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final auth = Provider.of<FirebaseAuthService>(context, listen: false);
    final userData = await auth.getUserData(FirebaseAuth.instance.currentUser!.uid);
    if (mounted) setState(() => _user = userData);
  }

  // Uses proper theming for the dialog popup as well
  void _showAddNewsDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Post Pharmacy News'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 10),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 4),
              const SizedBox(height: 10),
              TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: 'Image URL (Optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final news = NewsModel(
                id: '',
                title: titleController.text,
                content: contentController.text,
                imageUrl: imageUrlController.text.isNotEmpty ? imageUrlController.text : null,
                timestamp: DateTime.now() as dynamic, 
              );
              _newsService.addNews(news);
              Navigator.pop(context);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacist = _user?.role == UserRole.pharmacist;
    bool isLight = Theme.of(context).brightness == Brightness.light;
    
    Color surfaceColor = Theme.of(context).colorScheme.surface;
    Color accentColor = isLight ? Theme.of(context).primaryColor : const Color(0xFF4ADE80);
    Color textColor = isLight ? Colors.black87 : const Color(0xFFF8FAFC);
    Color textMutedColor = isLight ? Colors.black54 : const Color(0xFF94A3B8);
    Color borderColor = isLight ? Colors.black12 : surfaceColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<NewsModel>>(
        stream: _newsService.getNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: accentColor));
          
          final newsList = snapshot.data ?? [];
          if (newsList.isEmpty) {
            return Center(child: Text('No news updates yet.', style: TextStyle(color: textMutedColor)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))] : [],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (news.imageUrl != null)
                      Image.network(
                        news.imageUrl!, 
                        height: 180, 
                        width: double.infinity, 
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(height: 180, color: isLight ? Colors.black12 : Colors.white10, child: Center(child: CircularProgressIndicator(color: accentColor)));
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180, color: isLight ? Colors.black12 : Colors.white10, child: Icon(Icons.broken_image, size: 50, color: textMutedColor)
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(news.title, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                DateFormat('MMM dd').format(news.timestamp.toDate()), 
                                style: TextStyle(color: textMutedColor, fontSize: 12)
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            news.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(height: 1.4, color: isLight ? Colors.black87 : Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text('Read More', style: TextStyle(color: accentColor)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isPharmacist
          ? FloatingActionButton(
              onPressed: _showAddNewsDialog,
              backgroundColor: accentColor,
              tooltip: 'Post News',
              child: Icon(Icons.add_comment, color: isLight ? Colors.white : const Color(0xFF064E3B)),
            )
          : null,
    );
  }
}