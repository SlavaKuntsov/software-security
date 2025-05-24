import '../config/environment_config.dart';

class ApiConstants {
  // Base URL for all services
  static String get baseUrl => EnvironmentConfig.baseUrl;
  
  // URL для WebSocket подключений
  static String get wsBaseUrl => EnvironmentConfig.wsUrl;
  
  // SignalR хабы
  static String get chatHub => '$wsBaseUrl/chatHub';

  // User Service Endpoints
  static String get userServicePath => '$baseUrl/auth';

  // Auth endpoints в User Service
  static String get login => '$baseUrl/auth/login';
  static String get users => '$baseUrl/auth';
  static String get delete => '$baseUrl/auth/me';
  static String get register => '$baseUrl/auth/registration';
  static String get googleAuth => '$baseUrl/auth/google-login';
  static String get googleResponse =>
      '$baseUrl/auth/google-response';
  static String get googleMobileAuth =>
      '$baseUrl/auth/google-mobile-auth';
  static String get logout => '$baseUrl/auth/unauthorize';
  static String get refreshToken => '$baseUrl/auth/refresh-token';
  static String get authorize => '$baseUrl/auth/authorize';
  static String get notifications => '$baseUrl/notifications';
  
  // Chat endpoints
  static String get chatUsers => '$baseUrl/chat/users';
  static String get chatHistory => '$baseUrl/chat/history';
  static String getChatHistory(String receiverId) => '$baseUrl/chat/history/$receiverId';
  static String markMessagesAsRead(String senderId) => '$baseUrl/chat/mark-read/$senderId';
  static String get chatUnread => '$baseUrl/chat/unread';

  // Admin API endpoints
  static String getAllUsers() => '$baseUrl/users';
  static String deleteUser(String userId) =>
      '$baseUrl/users/$userId';

  // Movie Service Endpoints
  static String get movieServicePath => '$baseUrl/movies';

  // Movie endpoints
  static String get movies => '$baseUrl/movies';
  static String get movieDetails => '$baseUrl/movies';
  static String get movieGenres => '$baseUrl/movies/genres';
  static String get nowPlaying => '$baseUrl/movies/now-playing';
  static String get upcoming => '$baseUrl/movies/upcoming';
  static String get search => '$baseUrl/movies/search';
  static String get moviePoster => '$baseUrl/movies/poster';
  static String get movieFrame => '$baseUrl/movies/frames';
  static String get sessions => '$baseUrl/sessions';
  static String get halls => '$baseUrl/halls';
  static String get seatsType => '$baseUrl/seats/types';
  static String get seats => '$baseUrl/seats';

  // Booking Service Endpoints
  static String get bookingServicePath => '$baseUrl/booking';

  // Booking endpoints
  static String get bookings => '$baseUrl/bookings';
  static String get cancel => '$baseUrl/bookings/cancel';
  static String get pay => '$baseUrl/bookings/pay';
  static String get bookingsHistory =>
      '$baseUrl/bookings/history';
  static String get reservedSeats =>
      '$baseUrl/bookingsSeats/reserved/session';
  static String get createBooking => '$baseUrl/bookings/create';

  // API Keys и прочие константы
  static const String googleClientId =
      '613641131431-k6tqdavhgcfqvkqi1aeo347il4g20boi.apps.googleusercontent.com';
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // JWT константы
  static const String REFRESH_COOKIE_NAME = "yummy-cackes";

  // Day management API endpoints
  static String getAllDays() => '$baseUrl/days';
  static String createDay() => '$baseUrl/days';
  static String deleteDay(String dayId) => '$baseUrl/days/$dayId';

  static String getAllHalls() => '$baseUrl/halls';
  static String getHallById(String id) => '$baseUrl/halls/$id';
  static String createSimpleHall() => '$baseUrl/halls/simple';
  static String createCustomHall() => '$baseUrl/halls/custom';
  static String updateHall() => '$baseUrl/halls';
  static String deleteHall(String id) => '$baseUrl/halls/$id';

  static String getMovieById(String id) => '$baseUrl/movies/$id';
  static String createMovie() => '$baseUrl/movies';
  static String updateMovie() => '$baseUrl/movies';
  static String deleteMovie(String id) => '$baseUrl/movies/$id';

  static String getMoviePoster(String id) =>
      '$baseUrl/movies/$id/poster';
  static String changeMoviePoster(String id) =>
      '$baseUrl/movies/$id/poster';
  static String getMoviePosterByName(String fileName) =>
      '$baseUrl/movies/poster/$fileName';

  // Movie frames endpoints
  static String getAllMovieFrames() => '$baseUrl/movies/frames';
  static String getMovieFramesByMovieId(String movieId) =>
      '$baseUrl/movies/$movieId/frames';
  static String getMovieFrameByName(String fileName) =>
      '$baseUrl/movies/frames/$fileName';
  static String addMovieFrame(String movieId, int frameOrder) =>
      '$baseUrl/movies/$movieId/frames/$frameOrder';
  static String deleteMovieFrame(String frameId) =>
      '$baseUrl/movies/frames/$frameId';

  // Genre endpoints
  static String getAllGenres() => '$baseUrl/movies/genres';
  static String updateGenre() => '$baseUrl/movies/genres';
  static String deleteGenre(String id) =>
      '$baseUrl/movies/genres/$id';

  // Session endpoints
  static String fetchSeatTypesByHallId(String hallId) =>
      '$baseUrl/sessions/halls/$hallId/seat-types';
}

// Константы JWT
class JwtConstants {
  static const String REFRESH_COOKIE_NAME = "yummy-cackes";
}
