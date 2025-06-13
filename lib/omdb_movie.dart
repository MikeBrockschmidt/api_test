import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Filmsuche', home: MovieSearchPage());
  }
}

class MovieSearchPage extends StatefulWidget {
  @override
  _MovieSearchPageState createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _movieData;
  String? _error;
  bool _isLoading = false;

  final String apiKey = '1b316206';

  Future<void> fetchMovie(String title) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _movieData = null;
    });

    final url =
        'https://www.omdbapi.com/?t=${Uri.encodeComponent(title)}&apikey=$apiKey&plot=short&lang=de';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['Response'] == 'False') {
        setState(() {
          _error = data['Error'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _movieData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Fehler beim Abrufen der Daten';
        _isLoading = false;
      });
    }
  }

  Widget buildResult() {
    if (_isLoading) {
      return CircularProgressIndicator();
    }
    if (_error != null) {
      return Text('Fehler: $_error', style: TextStyle(color: Colors.red));
    }
    if (_movieData == null) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_movieData!['Title']} (${_movieData!['Year']})',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        _movieData!['Poster'] != 'N/A'
            ? Image.network(_movieData!['Poster'], height: 300)
            : Container(),
        SizedBox(height: 10),
        Text(_movieData!['Plot'] ?? ''),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filmsuche')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Filmtitel eingeben',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => fetchMovie(value),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final title = _controller.text.trim();
                if (title.isNotEmpty) {
                  fetchMovie(title);
                }
              },
              child: Text('Suchen'),
            ),
            SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: buildResult())),
          ],
        ),
      ),
    );
  }
}
