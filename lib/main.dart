import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(PokemonApp());
}

class PokemonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon TCG Cards',
      theme: ThemeData(primarySwatch: Colors.green),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentPage = 0;
  List<String> images = [
    'assets/splash1.jpg', // Ensure you have these images in your assets folder
    'assets/splash2.jpg',
    'assets/splash3.jpg',
    'assets/splash4.jpg',
    'assets/splash5.jpg',
    'assets/splash6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 450), (Timer timer) {
      if (_currentPage < images.length - 1) {
        setState(() {
          _currentPage++;
        });
      } else {
        timer.cancel();
        // Navigate to the second splash screen after the 6 images are displayed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SecondSplashScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 248, 17, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              images[_currentPage], // Displaying different splash images
              height: 450,
            ),
            SizedBox(height: 50),
            Text(
              ' ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondSplashScreen extends StatefulWidget {
  @override
  _SecondSplashScreenState createState() => _SecondSplashScreenState();
}

class _SecondSplashScreenState extends State<SecondSplashScreen> {
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    // Show floating text after 1 second
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _showText = true;
      });
    });

    // Navigate to CardListScreen after 3 seconds
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CardListScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 227, 6),
      body: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.jpg', // The logo image for the second splash screen
                  height: 350,
                ),
                SizedBox(height: 50),
              ],
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 5),
              top: _showText ? 200 : -50, // Adjust the position to create the floating effect
              left: 50, // Horizontal position
              right: 50,
              child: Text(
                'Pokémon TCG Cards',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  List<Map<String, dynamic>> cards = [];
  List<Map<String, dynamic>> filteredCards = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> favoriteCards = []; // List to store favorite cards

  @override
  void initState() {
    super.initState();
    fetchCards();
    searchController.addListener(() => filterCards());
  }

  Future<void> fetchCards() async {
    try {
      final response = await http.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          cards = List<Map<String, dynamic>>.from(jsonData['data']);
          filteredCards = cards; // Initialize filtered cards
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching cards: $error');
    }
  }

  void filterCards() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredCards = cards
          .where((card) => card['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  void toggleFavorite(Map<String, dynamic> card) {
    setState(() {
      if (favoriteCards.contains(card)) {
        favoriteCards.remove(card); // Remove from favorites if already added
      } else {
        favoriteCards.add(card); // Add to favorites
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search cards by name',
            border: InputBorder.none,
            hintStyle: TextStyle(color: const Color(0x00FFFFFF)),
          ),
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              FocusScope.of(context).unfocus(); // Close the keyboard
            },
          ),
        ],
        backgroundColor: Colors.green[700], // Solid background color
        elevation: 10, // Add shadow for depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ), // Rounded corners for the AppBar
        centerTitle: true,
      ),
      body: Container(
        color: const Color.fromARGB(255, 235, 235, 224),
        child: Column(
          children: [
            // Favorites Button
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // Navigate to favorites screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritesScreen(favoriteCards),
                    ),
                  );
                },
                child: Text('Favorites'),
              ),
            ),
            // Card List
            isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredCards.isEmpty
                    ? Center(child: Text('No cards found'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: filteredCards.length,
                          itemBuilder: (context, index) {
                            final card = filteredCards[index];
                            bool isFavorite = favoriteCards.contains(card); // Check if the card is in favorites
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageEnlargedScreen(
                                        imageUrl: card['images']['large'],
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${index + 1}. ${card['name']}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ),
                                    ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: card['images']['small'],
                                        height: 120,  // Increased size
                                        width: 120,   // Increased size
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : Colors.black,
                                      ),
                                      onPressed: () => toggleFavorite(card),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class ImageEnlargedScreen extends StatelessWidget {
  final String imageUrl;

  ImageEnlargedScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enlarged Image'),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteCards;

  FavoritesScreen(this.favoriteCards);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Cards'),
        backgroundColor: Colors.green[700],
      ),
      body: favoriteCards.isEmpty
          ? Center(child: Text('No favorites yet'))
          : ListView.builder(
              itemCount: favoriteCards.length,
              itemBuilder: (context, index) {
                final card = favoriteCards[index];
                return ListTile(
                  title: Text(card['name']),
                  subtitle: Text('Card #${index + 1}'),
                );
              },
            ),
    );
  }
}
