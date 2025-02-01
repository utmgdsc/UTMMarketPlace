import 'package:flutter/material.dart';
import 'package:utm_marketplace/common/theme.dart';
import 'package:go_router/go_router.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = 'Aubrey Drake'; // Added state variable, replace with actual user name from backend

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/home');
            },
          ),
          title: Text('Profile'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // TODO: Implement settings navigation
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/Default_pfp.jpg'),
                // TODO: Replace with actual user profile picture from backend---db
              ),
              SizedBox(height: 16),
              
              // User Name
              StyleText(
                text: userName,  // Updated to use state variable
                style: ThemeText.header.copyWith(fontSize: 24),
              ),
              
              // Email
              Text(
                'aubreydrake@mail.utoronto.ca',  // TODO: Replace with actual email from backend
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
              
              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // TODO: Replace with actual stats from backend
                  _buildStatColumn('Listings', '12'),
                  _buildStatColumn('Sold', '8'),
                  _buildStatColumn('Rating', '4.5'),
                ],
              ),
              
              SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButton('My Listings', Icons.list_alt, () {
                // TODO: Navigate to listings
              }),
              _buildActionButton('Saved Items', Icons.favorite_border, () {
                // TODO: Navigate to saved items
              }),
              _buildActionButton('Purchase History', Icons.history, () {
                // TODO: Navigate to purchase history
              }),
              _buildActionButton('Edit Profile', Icons.edit, () {
                _showEditProfileDialog(context); // added this temporary dailog
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          children: [
            Icon(icon),
            SizedBox(width: 16),
            Text(label),
            Spacer(),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    // TODO: Implement image picker
                    print('Change profile picture');
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/Default_pfp.jpg'), // TODO: Replace with actual user profile picture from backend---db
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String firstName = firstNameController.text.trim();
                final String lastName = lastNameController.text.trim();
                
                if (firstName.isEmpty || lastName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in both names'))
                  );
                  return;
                }

                // TODO: Backend - Send request to update user profile
                
                setState(() {
                  userName = '$firstName $lastName';
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated successfully'))
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}