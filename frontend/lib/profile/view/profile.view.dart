import 'package:flutter/material.dart';
import 'package:utm_marketplace/shared/themes/theme.dart';
import 'package:go_router/go_router.dart';

class Profile extends StatefulWidget {
  final String userId;
  final bool isOwnProfile;

  const Profile({
    super.key,
    required this.userId,
    required this.isOwnProfile,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String firstName;
  late String lastName;
  late final String email;
  late final double rating;
  late final int reviewCount;
  late final String profileImage;
  late final List<ListingItem> listings;
  late final int savedItemsCount;

  String get fullName => '$firstName $lastName';

  @override
  void initState() {
    super.initState();
    firstName = 'Aubrey';
    lastName = 'Drake';
    email = 'aubreydrake@mail.utoronto.ca';
    rating = 4.3;
    reviewCount = 28;
    profileImage = 'assets/images/aubreydrakepfp.jpg';
    listings = List.generate(
      12,
      (i) => ListingItem(
        id: i.toString(),
        imageUrl: 'assets/images/books.jpg',
        price: 29.99,
        title: 'Item $i',
        description:
            'Description for item $i that might be very long and need truncating',
      ),
    );
    savedItemsCount = 15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(
            physics: ClampingScrollPhysics(),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(),
                _buildRatingSection(),
                if (widget.isOwnProfile) _buildActionButtons(),
                _buildListingsGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => context.replace('/marketplace'),  // Changed from context.pop()
      ),
      title: Text('Profile'),
      actions: [
        if (widget.isOwnProfile)
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Hero(
            tag: 'profile-image',
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(profileImage),
            ),
          ),
          SizedBox(height: 16),
          Text(
            fullName,
            style: ThemeText.header.copyWith(fontSize: 24),
          ),
          SizedBox(height: 8),
          Text(
            email,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < rating.floor()
                      ? Icons.star
                      : index < rating
                          ? Icons.star_half
                          : Icons.star_border,
                  color: Colors.amber,
                  size: 28,
                );
              }),
              SizedBox(width: 8),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '$reviewCount reviews',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _ActionButton(
            label: 'Edit Profile',
            icon: Icons.edit,
            onPressed: () => _showEditProfileDialog(context),
          ),
          _ActionButton(
            label: 'Saved Items ($savedItemsCount)',
            icon: Icons.favorite_border,
            onPressed: () => context.push('/item_listing'),
          ),
          _ActionButton(
            label: 'Purchase History',
            icon: Icons.history,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildListingsGrid() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Listings',
            style: ThemeText.header.copyWith(fontSize: 20),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 200,
            ),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return _ListingCard(listing: listing);
            },
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final profilePicture = GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/aubreydrakepfp.jpg'),
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
    );

    final firstNameField = TextFormField(
      controller: firstNameController,
      decoration: InputDecoration(
        labelText: 'First Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your first name';
        }
        return null;
      },
    );

    final lastNameField = TextFormField(
      controller: lastNameController,
      decoration: InputDecoration(
        labelText: 'Last Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your last name';
        }
        return null;
      },
    );

    final dialogContent = Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          profilePicture,
          SizedBox(height: 16),
          firstNameField,
          SizedBox(height: 8),
          lastNameField,
        ],
      ),
    );

    final actions = [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            final String firstName = firstNameController.text.trim();
            final String lastName = lastNameController.text.trim();

            setState(() {
              this.firstName = firstName;
              this.lastName = lastName;
            });

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile updated successfully')));
          }
        },
        child: Text('Save'),
      ),
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: AlertDialog(
            title: Text('Edit Profile'),
            content: SingleChildScrollView(child: dialogContent),
            actions: actions,
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
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
}

class _ListingCard extends StatelessWidget {
  final ListingItem listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final image = Expanded(
      child: Image.asset(
        listing.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );

    final title = Text(
      listing.title,
      style: TextStyle(fontWeight: FontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final price = Text(
      '\$${listing.price.toStringAsFixed(2)}',
      style: TextStyle(color: Colors.green),
    );

    final details = Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [price, title],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [image, details],
      ),
    );
  }
}

class ListingItem {
  final String id;
  final String imageUrl;
  final String title;
  final double price;
  final String description;

  ListingItem({
    required this.id,
    required this.imageUrl,
    required this.price,
    required this.title,
    required this.description,
  });
}
