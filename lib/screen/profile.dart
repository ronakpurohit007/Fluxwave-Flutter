import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phone_number/screen/update_profile.dart';
import '../controller/auth_service.dart';
import '../pages/login_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.menu, size: 35,),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: TextButton.icon(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(),));
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Edit Profile'),
                ),
              ),
              PopupMenuItem(
                child: TextButton.icon(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  icon: Icon(Icons.exit_to_app_rounded),
                  label: Text('Logout'),
                ),
              )
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: UpdateScreen(commentController: _commentController),
      ),
    );
  }
}

class UpdateScreen extends StatefulWidget {
  final TextEditingController commentController;

  const UpdateScreen({Key? key, required this.commentController});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late String fullName = "";
  late String username = "";
  late String about = "";
  late String phone = "";
  late String imageUrl = ""; // Variable to store image URL

  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void fetchProfileData() async {
    try {
      String? uid = AuthService.getCurrentUserUID(); // Fetch current user's UID from AuthService

      if (uid != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (snapshot.exists) {
          setState(() {
            fullName = snapshot.get('name');
            username = snapshot.get('username');
            about = snapshot.get('about');
            phone = snapshot.get('phone');
            imageUrl = snapshot.get('imageUrl') ?? ''; // Fetch image URL

            _phoneController.text = phone;
          });
        }
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  Stream<QuerySnapshot> getUserPostsStream() {
    String? uid = AuthService.getCurrentUserUID(); // Fetch current user's UID from AuthService
    if (uid != null) {
      return FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      throw Exception("No user logged in");
    }
  }

  void likePost(String postId) async {
    try {
      String? uid = AuthService.getCurrentUserUID();
      if (uid != null) {
        DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot postSnapshot = await transaction.get(postRef);

          if (!postSnapshot.exists) {
            throw Exception("Post does not exist");
          }

          // Retrieve current likedBy and likeCount values from the document
          List<dynamic> likedBy = List.from(postSnapshot.get('likedBy') ?? []);
          int likeCount = postSnapshot.get('likeCount') ?? 0;

          // Perform like/unlike logic based on whether uid is in likedBy
          if (likedBy.contains(uid)) {
            // User has already liked the post, so unlike it
            transaction.update(postRef, {
              'likeCount': likeCount - 1,
              'likedBy': FieldValue.arrayRemove([uid]),
            });
          } else {
            // User has not liked the post yet, so like it
            transaction.update(postRef, {
              'likeCount': likeCount + 1,
              'likedBy': FieldValue.arrayUnion([uid]),
            });
          }
        });
      } else {
        print('Current user UID is null');
      }
    } catch (e) {
      print("Error liking post: $e");
      // Handle error as needed
    }
  }

  void addComment(String postId, String commentText) async {
    try {
      String? uid = AuthService.getCurrentUserUID();
      if (uid != null) {
        await FirebaseFirestore.instance.collection('comments').add({
          'postId': postId,
          'userId': uid,
          'comment': commentText,
          'timestamp': FieldValue.serverTimestamp(),
        });
        // Clear the comment text field after adding comment
        widget.commentController.clear();
      }
    } catch (e) {
      print("Error adding comment: $e");
      // Handle error as needed
    }
  }

  void navigateToCommentScreen(String postId) {
    // Example: Navigate to a comment screen or dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentScreen(postId: postId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(5),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Implement logic to update profile picture
              },
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey, // Placeholder color
                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              ),
            ),
            SizedBox(height: 20),
            Text(fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Text(username, style: TextStyle(fontSize: 18)),
            SizedBox(height: 5),
            Text(about, style: TextStyle(fontSize: 18)),
            SizedBox(height: 5),
            Text(phone, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Divider(thickness: 2, color: Colors.black),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: getUserPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final posts = snapshot.data?.docs ?? [];

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    List likedBy = post['likedBy'] ?? [];
                    int likeCount = post['likeCount'] ?? 0;
                    bool isLiked = likedBy.contains(AuthService.getCurrentUserUID());

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(post['content'] ?? ''),
                            SizedBox(height: 10),
                            post['imageUrl'] != null ? Image.network(post['imageUrl']) : SizedBox.shrink(),
                            SizedBox(height: 10),
                            Text(post['timestamp'] != null ? (post['timestamp'] as Timestamp).toDate().toString() : 'No timestamp'),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: isLiked ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_border),
                                      // icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                                      onPressed: () {
                                        likePost(post.id);
                                      },
                                    ),
                                    Text('$likeCount likes'),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.comment),
                                  onPressed: () {
                                    navigateToCommentScreen(post.id);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(color: Colors.grey),
                            SizedBox(height: 10),
                            // Comment Section
                            _buildCommentSection(post.id),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(String postId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('comments')
              .where('postId', isEqualTo: postId)
              .orderBy('timestamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            final comments = snapshot.data?.docs ?? [];

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  title: Text(comment['comment']),
                  subtitle: Text('By ${comment['userId']}'),
                );
              },
            );
          },
        ),
        SizedBox(height: 10),
        // Add Comment Section
        _buildAddCommentSection(postId),
      ],
    );
  }

  Widget _buildAddCommentSection(String postId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.commentController,
          decoration: InputDecoration(
            hintText: 'Add a comment...',
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (widget.commentController.text.isNotEmpty) {
                  addComment(postId, widget.commentController.text);
                }
              },
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class CommentScreen extends StatelessWidget {
  final String postId;

  const CommentScreen({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement your comment screen UI here
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Center(
        child: Text('Comments for post ID: $postId'),
      ),
    );
  }
}
