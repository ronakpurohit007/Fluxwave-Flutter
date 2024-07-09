import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phone_number/screen/view_profile.dart';
// Replace with your profile screen import

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  void searchUsers(String username) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      setState(() {
        _searchResults = querySnapshot.docs;
      });
    } catch (e) {
      print('Error searching users: $e');
      // Handle error
    }
  }

  void navigateToUserProfile(DocumentSnapshot user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)),
    );
  }

  void sendFriendRequest(String recipientUid) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Add a new document in 'friendRequests' collection
      await FirebaseFirestore.instance.collection('friendRequests').add({
        'requesterUid': currentUserId,
        'recipientUid': recipientUid,
        'status': 'pending', // Initial status of the request
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent')),
      );
    } catch (e) {
      print('Error sending friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send friend request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter username',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String username = _searchController.text.trim();
                    if (username.isNotEmpty) {
                      searchUsers(username);
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                DocumentSnapshot user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['imageUrl'] ?? 'default_image_url'),
                  ),
                  title: Text(user['username']),
                  subtitle: Text(user['name']),
                  trailing: ElevatedButton(
                    onPressed: () {
                      sendFriendRequest(user.id); // Pass recipient's UID
                    },
                    child: Text('Add Friend'),
                  ),
                  onTap: () {
                    navigateToUserProfile(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
