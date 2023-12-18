import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class CatImage {
  final String url;

  CatImage({required this.url});

  factory CatImage.fromJson(Map<String, dynamic> json) {
    return CatImage(url: json['url']);
  }
}

class CatApi {
  static const String baseUrl = 'https://api.thecatapi.com/v1/images/search';

  static Future<CatImage> fetchRandomCat() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<String, dynamic> catData = data.first;
      return CatImage.fromJson(catData);
    } else {
      throw Exception('Failed to load cat image');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Cat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<CatImage> futureCatImage;

  @override
  void initState() {
    super.initState();
    futureCatImage = CatApi.fetchRandomCat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Image Viewer'),
      ),
      body: Center(
        child: FutureBuilder<CatImage>(
          future: futureCatImage,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Image.network(snapshot.data!.url);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            futureCatImage = CatApi.fetchRandomCat();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
