import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:melt/models/movie_model.dart';

final _apiKey = '7195cc1991msh24527d057955726p171039jsn7dab2fdd40a7';

Future<Movie?> getMovieByID(String id) async {
  try {
    final dio = Dio();

    dio.options.headers.addAll({
      'Type': 'get-movie-details',
      'X-Rapidapi-Key': _apiKey,
      'X-Rapidapi-Host': 'movies-tv-shows-database.p.rapidapi.com',
      'Host': 'movies-tv-shows-database.p.rapidapi.com',
    });

    Response response = await dio.get(
      'https://movies-tv-shows-database.p.rapidapi.com/?movieid=$id',
    );
    print(response.statusCode);
    // Parse response
    if (response.statusCode == 200) {
      // List<dynamic> data = jsonDecode(response.data);
      // print(data);
      Map<String, dynamic> jsonData = response.data;
      print(response.extra);
      print(jsonData);
      Movie movie = Movie.fromJson(jsonData);
      movie.imagesUrl = await getMovieImages(id);
      return movie;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

Future<List<String>?> getNowPlaying() async {
  try {
    final dio = Dio();

    dio.options.headers.addAll({
      'Type': 'get-nowplaying-movies',
      'X-Rapidapi-Key': _apiKey,
      'X-Rapidapi-Host': 'movies-tv-shows-database.p.rapidapi.com',
      'Host': 'movies-tv-shows-database.p.rapidapi.com',
    });

    Response response = await dio.get(
      'https://movies-tv-shows-database.p.rapidapi.com/?page=1',
    );

    //Parse Response
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = response.data;
      List<dynamic> jsonData = responseData['movie_results'];

      if (jsonData is List) {
        List<String> imdb_IDs = [];

        for (var item in jsonData) {
          if (item is Map<String, dynamic> && item.containsKey('imdb_id')) {
            imdb_IDs.add(item['imdb_id'] as String);
          }
        }

        return imdb_IDs;
      } else {
        print('Invalid data format');
        return null;
      }
    } else {
      print('Request failed with statusCode ${response.statusCode}');
      return null;
    }
  } catch (e) {
    throw ('Exception occured: $e');
  }
}

Future<searchMovieResults?> getMovieByTitle(String text) async {
  try {
    final dio = Dio();

    dio.options.headers.addAll({
      'Type': 'get-movies-by-title',
      'X-Rapidapi-Key': _apiKey,
      'X-Rapidapi-Host': 'movies-tv-shows-database.p.rapidapi.com',
      'Host': 'movies-tv-shows-database.p.rapidapi.com',
    });

    final encodedText = Uri.encodeQueryComponent(text);

    Response response = await dio.get(
      'https://movies-tv-shows-database.p.rapidapi.com/?title=$encodedText',
    );
    print(response.statusCode);
    // Parse response
    if (response.statusCode == 200) {
      final responseData = response.data;

      final searchResults = searchMovieResults.fromJson(responseData);

      return searchResults;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

Future<List<String>?> getMovieImages(String id) async {
  try {
    final dio = Dio();
    dio.options.headers.addAll({
      'Type': 'get-movies-images-by-imdb',
      'X-Rapidapi-Key': _apiKey,
      'X-Rapidapi-Host': 'movies-tv-shows-database.p.rapidapi.com',
      'Host': 'movies-tv-shows-database.p.rapidapi.com',
    });

    Response response = await dio
        .get('https://movies-tv-shows-database.p.rapidapi.com/?movieid=$id');

    print(response.statusCode);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data;
      String poster = jsonData['poster'];
      String fanart = jsonData['fanart'];
      return [poster, fanart];
    } else {
      print('Request failed with statusCode: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    throw ("Error: $e");
  }
}
