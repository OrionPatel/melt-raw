class Movie {
  String? title;
  String? description;
  String? tagline;
  String? year;
  String? releaseDate;
  String? imdbId;
  String? imdbRating;
  String? voteCount;
  String? popularity;
  String? youtubeTrailerKey;
  String? rated;
  int? runtime;
  List<String>? genres;
  List<String>? stars;
  List<String>? directors;
  List<String>? countries;
  List<String>? language;
  List<String>? imagesUrl;
  String? status;
  String? statusMessage;

  Movie(
      {this.title,
      this.description,
      this.tagline,
      this.year,
      this.releaseDate,
      this.imdbId,
      this.imdbRating,
      this.voteCount,
      this.popularity,
      this.youtubeTrailerKey,
      this.rated,
      this.runtime,
      this.genres,
      this.stars,
      this.directors,
      this.countries,
      this.language,
      this.imagesUrl,
      this.status,
      this.statusMessage});

  Movie.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    tagline = json['tagline'];
    year = json['year'];
    releaseDate = json['release_date'];
    imdbId = json['imdb_id'];
    imdbRating = json['imdb_rating'];
    voteCount = json['vote_count'];
    popularity = json['popularity'];
    youtubeTrailerKey = json['youtube_trailer_key'];
    rated = json['rated'];
    runtime = json['runtime'];
    genres = json['genres'].cast<String>();
    stars = json['stars'].cast<String>();
    directors = json['directors'].cast<String>();
    countries = json['countries'].cast<String>();
    language = json['language'].cast<String>();
    status = json['status'];
    statusMessage = json['status_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['tagline'] = this.tagline;
    data['year'] = this.year;
    data['release_date'] = this.releaseDate;
    data['imdb_id'] = this.imdbId;
    data['imdb_rating'] = this.imdbRating;
    data['vote_count'] = this.voteCount;
    data['popularity'] = this.popularity;
    data['youtube_trailer_key'] = this.youtubeTrailerKey;
    data['rated'] = this.rated;
    data['runtime'] = this.runtime;
    data['genres'] = this.genres;
    data['stars'] = this.stars;
    data['directors'] = this.directors;
    data['countries'] = this.countries;
    data['language'] = this.language;
    data['status'] = this.status;
    data['status_message'] = this.statusMessage;
    return data;
  }
}

class searchMovieResults {
  List<MovieResults>? movieResults;
  int? searchResults;
  String? status;
  String? statusMessage;

  searchMovieResults(
      {this.movieResults, this.searchResults, this.status, this.statusMessage});

  searchMovieResults.fromJson(Map<String, dynamic> json) {
    if (json['movie_results'] != null) {
      movieResults = <MovieResults>[];
      json['movie_results'].forEach((v) {
        movieResults!.add(new MovieResults.fromJson(v));
      });
    }
    searchResults = json['search_results'];
    status = json['status'];
    statusMessage = json['status_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.movieResults != null) {
      data['movie_results'] =
          this.movieResults!.map((v) => v.toJson()).toList();
    }
    data['search_results'] = this.searchResults;
    data['status'] = this.status;
    data['status_message'] = this.statusMessage;
    return data;
  }
}

class MovieResults {
  String? title;
  int? year;
  String? imdbId;

  MovieResults({this.title, this.year, this.imdbId});

  MovieResults.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    year = json['year'];
    imdbId = json['imdb_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['year'] = this.year;
    data['imdb_id'] = this.imdbId;
    return data;
  }
}
