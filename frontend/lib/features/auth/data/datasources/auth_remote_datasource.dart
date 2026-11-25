import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSessionModel> register({
    required String nama,
    required String noHp,
    required String blokRumah,
    required String noRumah,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'nama': nama,
        'noHp': noHp,
        'blokRumah': blokRumah,
        'noRumah': noRumah,
        'password': password,
      },
    );

    final body = _readBody(response.data);
    final data = _readData(body);

    if (body['success'] != true) {
      throw Exception(
        body['message']?.toString() ?? 'Pendaftaran warga gagal.',
      );
    }

    final session = AuthSessionModel.fromJson(data);

    if (session.accessToken.isEmpty) {
      throw Exception(
        'Server tidak mengembalikan access token setelah registrasi.',
      );
    }

    return session;
  }

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
            'Server tidak memberikan challenge verifikasi OTP.',
      );
    }

    return {
      'challengeId': challengeId,
      'phoneMasked': data['phoneMasked']?.toString() ?? noHp,
      'expiresIn': data['expiresIn'] ?? 300,
    };
  }

  Future<int> requestOtp({
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
        body['message']?.toString() ?? 'Gagal mengirim kode OTP.',
      );
    }

    return int.tryParse(body['expiresIn']?.toString() ?? '') ?? 300;
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

  // Meminta OTP untuk proses reset password.
  Future<int> requestPasswordResetOtp({
    required String noHp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.requestOtp,
      data: {
        'noHp': noHp,
        'purpose': 'RESET_PASSWORD',
      },
    );

    final body = _readBody(response.data);

    if (body['success'] != true) {
      throw Exception(
        body['message']?.toString() ??
            'Gagal mengirim OTP untuk reset password.',
      );
    }

    return int.tryParse(body['expiresIn']?.toString() ?? '') ?? 300;
  }

  // Memverifikasi OTP reset password dan mengambil resetToken.
  Future<String> verifyPasswordResetOtp({
    required String noHp,
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.verifyOtp,
      data: {
        'noHp': noHp,
        'purpose': 'RESET_PASSWORD',
        'otp': otp,
      },
    );

    final body = _readBody(response.data);
    final data = _readData(body);

    if (body['success'] != true) {
      throw Exception(
        body['message']?.toString() ?? 'Verifikasi OTP reset password gagal.',
      );
    }

    final resetToken = data['resetToken']?.toString();

    if (resetToken == null || resetToken.isEmpty) {
      throw Exception(
        'Server tidak mengembalikan token untuk reset password.',
      );
    }

    return resetToken;
  }

  // Mengirim password baru menggunakan resetToken.
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.resetPassword,
      data: {
        'resetToken': resetToken,
        'newPassword': newPassword,
      },
    );

    final body = _readBody(response.data);

    if (body['success'] != true) {
      throw Exception(
        body['message']?.toString() ?? 'Password gagal diperbarui.',
      );
    }
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
