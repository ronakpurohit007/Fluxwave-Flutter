import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';






class FriendRequest {
  final String id;
  final String requesterUid;
  final String recipientUid;
  final String status;
  final DateTime timestamp;

  FriendRequest({
    required this.id,
    required this.requesterUid,
    required this.recipientUid,
    required this.status,
    required this.timestamp,
  });

  factory FriendRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      id: doc.id,
      requesterUid: data['requesterUid'],
      recipientUid: data['recipientUid'],
      status: data['status'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}



class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({Key? key}) : super(key: key);

  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<FriendRequest> _friendRequests = [];

  @override
  void initState() {
    super.initState();
    fetchFriendRequests();
  }

  Future<void> fetchFriendRequests() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('friendRequests')
          .where('recipientUid', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      List<FriendRequest> requests = querySnapshot.docs.map((doc) => FriendRequest.fromFirestore(doc)).toList();

      setState(() {
        _friendRequests = requests;
      });
    } catch (e) {
      print('Error fetching friend requests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch friend requests')),
      );
    }
  }

  void acceptFriendRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('friendRequests').doc(requestId).update({
        'status': 'accepted',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request accepted')),
      );

      // Refresh friend requests after accepting
      fetchFriendRequests();
    } catch (e) {
      print('Error accepting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept friend request')),
      );
    }
  }

  void rejectFriendRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('friendRequests').doc(requestId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request rejected')),
      );

      // Refresh friend requests after rejecting
      fetchFriendRequests();
    } catch (e) {
      print('Error rejecting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject friend request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
      ),
      body: _friendRequests.isEmpty
          ? Center(child: Text('No friend requests'))
          : ListView.builder(
        itemCount: _friendRequests.length,
        itemBuilder: (context, index) {
          FriendRequest request = _friendRequests[index];
          return ListTile(
            leading: CircleAvatar(
              // Display requester's profile image or default image
              backgroundImage: NetworkImage('default_image_url'),
            ),
            title: Text('Friend request from ${request.requesterUid}'),
            subtitle: Text(request.timestamp.toString()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    acceptFriendRequest(request.id);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    rejectFriendRequest(request.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


