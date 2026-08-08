import 'package:dio/dio.dart';

extension DioExceptionConnectivity on DioException {
  bool get isConnectivityError =>
      type == DioExceptionType.connectionError ||
      type == DioExceptionType.connectionTimeout ||
      type == DioExceptionType.sendTimeout ||
      type == DioExceptionType.receiveTimeout;
}
