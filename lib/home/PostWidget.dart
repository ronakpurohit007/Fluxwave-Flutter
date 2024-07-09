import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class PostWidget extends StatelessWidget {
  final DocumentSnapshot post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if 'authorId' field exists in the document
    if (!post.exists || !(post.data() as Map<String, dynamic>).containsKey('authorId')) {
      return SizedBox(); // Return an empty widget or handle accordingly
    }

    // Extract post data
    String content = post['content'];
    String imageUrl = post['imageUrl']; // Assuming an image URL field
    String authorId = post['authorId']; // Assuming authorId field exists

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fetch and display user information
            FutureBuilder(
              future: FirebaseFirestore.instance.collection('users').doc(authorId).get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (userSnapshot.hasError) {
                  return Text('Error: ${userSnapshot.error}');
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Text('User not found'); // Handle case where user document does not exist
                }

                String username = userSnapshot.data?['username'];
                String profileImageUrl = userSnapshot.data?['profileImageUrl']; // Assuming profile image URL field

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl ?? 'default_profile_image_url'),
                  ),
                  title: Text(username ?? 'Unknown User'),
                );
              },
            ),
            SizedBox(height: 8),
            // Display post content and image
            Text(content),
            if (imageUrl != null)
              SizedBox(
                height: 200,
                child: Image.network(imageUrl),
              ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () {
                    // Handle like functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    // Handle comment functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
