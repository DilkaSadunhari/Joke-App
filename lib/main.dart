import 'package:flutter/material.dart';
import 'joke_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import Connectivity package
import 'dart:async'; // Import for StreamSubscription

void main() {
  runApp(MyFunApp());
}

class MyFunApp extends StatelessWidget {
  const MyFunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke Hub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
      ),
      debugShowCheckedModeBanner: false,
      home: const JokeListPage(),
    );
  }
}

class JokeListPage extends StatefulWidget {
  const JokeListPage({super.key});

  @override
  State<JokeListPage> createState() => _JokeListPageState();
}

class _JokeListPageState extends State<JokeListPage> {
  final JokeService _jokeService = JokeService();
  List<Map<String, dynamic>> _jokesRaw = [];
  bool _isLoading = false;
  bool _isOffline = false; // Flag for offline status
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadCachedJokes();
    _checkConnectivity();
    _startConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _startConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkConnectivity() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = result == ConnectivityResult.none;
    });
  }

  Future<void> _fetchJokes() async {
    if (_isOffline) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final jokes = await _jokeService.fetchJokesRaw();
      if (mounted) {
        setState(() {
          _jokesRaw = jokes.length >= 5 ? jokes.take(5).toList() : jokes;
        });
        await _cacheJokes(_jokesRaw);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch jokes: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCachedJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jokesJson = prefs.getString('cached_jokes');

    if (jokesJson != null) {
      setState(() {
        _jokesRaw = List<Map<String, dynamic>>.from(json.decode(jokesJson));
      });
    }
  }

  Future<void> _cacheJokes(List<Map<String, dynamic>> jokes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jokesJson = json.encode(jokes);
    await prefs.setString('cached_jokes', jokesJson);
  }

  void _clearJokes() {
    setState(() {
      _jokesRaw.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cleared all jokes!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joke Hub'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchJokes,
            tooltip: 'Refresh Jokes',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearJokes,
            tooltip: 'Clear Jokes',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome to Joke Hub!',
              style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial', // Updated to a supported font
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Enjoy a curated selection of jokes!',
              style: TextStyle(
                color: Colors.blue[600],
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16.0),
            _isOffline
                ? Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.red, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.red[700],
                          size: 28,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            'You are offline. Please check your internet connection.',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchJokes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      elevation: 10,
                    ),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text(
                      'Get Jokes',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
            const SizedBox(height: 20),
            Expanded(
              child: _jokesRaw.isEmpty
                  ? const Center(
                      child: Text(
                        'No jokes fetched yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black45,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _jokesRaw.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final joke = _jokesRaw[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    joke['type'] == 'single'
                                        ? Icons.sentiment_very_satisfied
                                        : Icons.category,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    joke['type'] == 'single'
                                        ? 'Single Joke'
                                        : joke['category'],
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                joke['type'] == 'single'
                                    ? joke['joke']
                                    : '${joke['setup']}\n\n${joke['delivery']}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
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
