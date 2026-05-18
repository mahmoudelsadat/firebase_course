import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/news_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/news_model.dart';
import '../../models/user_model.dart';
import 'package:intl/intl.dart';

class NewsListScreen extends StatefulWidget {
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
    setState(() => _user = userData);
  }

  void _showAddNewsDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Post Pharmacy News'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
              TextField(controller: contentController, decoration: InputDecoration(labelText: 'Content'), maxLines: 3),
              TextField(controller: imageUrlController, decoration: InputDecoration(labelText: 'Image URL (Optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final news = NewsModel(
                id: '',
                title: titleController.text,
                content: contentController.text,
                imageUrl: imageUrlController.text.isNotEmpty ? imageUrlController.text : null,
                timestamp: DateTime.now() as dynamic, // Firestore will handle Timestamp
              );
              _newsService.addNews(news);
              Navigator.pop(context);
            },
            child: Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacist = _user?.role == UserRole.pharmacist;

    return Scaffold(
      body: StreamBuilder<List<NewsModel>>(
        stream: _newsService.getNews(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

          final newsList = snapshot.data ?? [];
          if (newsList.isEmpty) return Center(child: Text('No news updates yet.'));

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (news.imageUrl != null)
                      Image.network(news.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover, 
                        errorBuilder: (context, error, stackTrace) => Container(height: 100, color: Colors.grey[200], child: Icon(Icons.broken_image))),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(news.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(DateFormat('MMM dd, yyyy').format(news.timestamp.toDate()), style: TextStyle(color: Colors.grey, fontSize: 12)),
                          SizedBox(height: 8),
                          Text(news.content),
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
              child: Icon(Icons.add_comment),
              tooltip: 'Post News',
            )
          : null,
    );
  }
}
