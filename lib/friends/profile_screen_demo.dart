import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  final DocumentSnapshot user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<DocumentSnapshot> _posts = [];

  @override
  void initState() {
    super.initState();
    displayFriendsPosts();
  }

  Future<void> displayFriendsPosts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorUid', isEqualTo: widget.user.id)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _posts = postsSnapshot.docs;
      });
    } catch (e) {
      print('Error fetching user posts: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.user['imageUrl'] ?? 'default_image_url'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.user['username'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              widget.user['name'],
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                DocumentSnapshot post = _posts[index];
                return ListTile(
                  title: Text(post['content']),
                  subtitle: Text('Posted on ${post['timestamp'].toDate().toString()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
