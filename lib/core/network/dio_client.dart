import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio get instance {
    if (_instance != null) return _instance!;

    _instance = Dio(
      BaseOptions(
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'User-Agent': 'PrimeView/1.0',
          'Accept': '*/*',
        },
      ),
    );

    _instance!.interceptors.add(_LogInterceptor());
    _instance!.interceptors.add(_ErrorInterceptor());

    return _instance!;
  }

  static Future<String> fetchPlaylistContent(String url) async {
    try {
      final response = await instance.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: true,
          maxRedirects: 5,
        ),
      );
      return response.data.toString();
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch playlist', error: e);
      rethrow;
    }
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('${options.method}: ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('Response ${response.statusCode}: ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('Dio error: ${err.message}', error: err);
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        message = 'Server error (${err.response?.statusCode}). Please try again.';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      default:
        message = 'Network error occurred. Please check your connection.';
    }

    AppLogger.error(message, error: err);
    handler.next(err);
  }
}
