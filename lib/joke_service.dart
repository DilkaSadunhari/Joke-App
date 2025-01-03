import 'package:dio/dio.dart';

class JokeService {
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> fetchJokesRaw() async {
    try {
      final response = await _dio
          .get('https://v2.jokeapi.dev/joke/Any?amount=5&blacklistFlags=nsfw');
      if (response.statusCode == 200) {
        final List<dynamic> jokesJsonList = response.data['jokes'];
        return jokesJsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Failed to load jokes");
      }
    } catch (e) {
      throw Exception("Error fetching jokes: $e");
    }
  }
}
