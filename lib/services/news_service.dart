import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get News Stream
  Stream<List<NewsModel>> getNews() {
    return _firestore
        .collection('news')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NewsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add News (Pharmacist/Admin only)
  Future<void> addNews(NewsModel news) async {
    await _firestore.collection('news').add(news.toMap());
  }
}
