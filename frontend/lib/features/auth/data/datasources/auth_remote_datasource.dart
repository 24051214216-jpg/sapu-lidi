import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> login({
    required String noHp,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {
        'noHp': noHp,
        'password': password,
      },
    );

    final body = _readBody(response.data);
    final data = _readData(body);

    final challengeId = data['challengeId']?.toString();

    if (body['success'] != true || challengeId == null || challengeId.isEmpty) {
      throw Exception(
        body['message']?.toString() ??
            'Respons login tidak memiliki challenge OTP.',
      );
    }

    return {
      'challengeId': challengeId,
      'phoneMasked': data['phoneMasked']?.toString() ?? noHp,
      'expiresIn': data['expiresIn'] ?? 300,
    };
  }

  Future<void> requestOtp({
    required String challengeId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.requestOtp,
      data: {
        'challengeId': challengeId,
      },
    );

    final body = _readBody(response.data);

    if (body['success'] != true) {
      throw Exception(
        body['message']?.toString() ?? 'Gagal mengirim ulang kode OTP.',
      );
    }
  }

  Future<AuthSessionModel> verifyOtp({
    required String challengeId,
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.verifyOtp,
      data: {
        'challengeId': challengeId,
        'otp': otp,
      },
    );

    final body = _readBody(response.data);
    final data = _readData(body);

    if (body['success'] != true) {
      throw Exception(
        body['message']?.toString() ?? 'Verifikasi OTP gagal.',
      );
    }

    final session = AuthSessionModel.fromJson(data);

    if (session.accessToken.isEmpty) {
      throw Exception(
        'Access token tidak ditemukan setelah verifikasi OTP.',
      );
    }

    return session;
  }

  Map<String, dynamic> _readBody(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    throw Exception('Format respons server tidak valid.');
  }

  Map<String, dynamic> _readData(
    Map<String, dynamic> body,
  ) {
    final data = body['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception('Data respons server tidak ditemukan.');
  }
}
