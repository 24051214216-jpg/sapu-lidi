import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapu_lidi/features/auth/data/datasources/auth_remote_datasource.dart';

void main() {
  late Dio dio;
  late _FakeHttpClientAdapter adapter;
  late AuthRemoteDataSource dataSource;

  setUp(() {
    adapter = _FakeHttpClientAdapter();

    dio = Dio(
      BaseOptions(
        baseUrl: 'https://sapulidi.test/api/v1',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.httpClientAdapter = adapter;
    dataSource = AuthRemoteDataSource(dio);
  });

  tearDown(() {
    dio.close(force: true);
  });

  group('AuthRemoteDataSource - Register', () {
    test('mengirim data registrasi dan mengembalikan session', () async {
      adapter.enqueue({
        'success': true,
        'message': 'Pendaftaran berhasil.',
        'data': {
          'accessToken': 'register-token',
          'tokenType': 'Bearer',
          'user': {
            'id': 'user-001',
            'nama': 'Warga SapuLidi',
            'noHp': '081234567890',
            'role': 'WARGA',
            'status': 'AKTIF',
          },
        },
      });

      final result = await dataSource.register(
        nama: 'Warga SapuLidi',
        noHp: '081234567890',
        blokRumah: 'A',
        noRumah: '01',
        password: 'password123',
      );

      expect(result.accessToken, 'register-token');
      expect(result.tokenType, 'Bearer');
      expect(result.user['nama'], 'Warga SapuLidi');

      expect(adapter.requests.single.path, '/auth/register');
      expect(_requestData(adapter.requests.single), {
        'nama': 'Warga SapuLidi',
        'noHp': '081234567890',
        'blokRumah': 'A',
        'noRumah': '01',
        'password': 'password123',
      });
    });

    test('menolak registrasi jika server tidak memberikan access token',
        () async {
      adapter.enqueue({
        'success': true,
        'data': {
          'accessToken': '',
          'tokenType': 'Bearer',
          'user': {},
        },
      });

      expect(
        () => dataSource.register(
          nama: 'Warga SapuLidi',
          noHp: '081234567890',
          blokRumah: 'A',
          noRumah: '01',
          password: 'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRemoteDataSource - Login', () {
    test('mengirim kredensial dan mengembalikan challenge OTP', () async {
      adapter.enqueue({
        'success': true,
        'message': 'OTP diperlukan.',
        'data': {
          'challengeId': 'challenge-001',
          'phoneMasked': '0812****7890',
          'expiresIn': 300,
        },
      });

      final result = await dataSource.login(
        noHp: '081234567890',
        password: 'password123',
      );

      expect(result['challengeId'], 'challenge-001');
      expect(result['phoneMasked'], '0812****7890');
      expect(result['expiresIn'], 300);

      expect(adapter.requests.single.path, '/auth/login');
      expect(_requestData(adapter.requests.single), {
        'noHp': '081234567890',
        'password': 'password123',
      });
    });

    test('menolak login jika challengeId tidak tersedia', () async {
      adapter.enqueue({
        'success': true,
        'message': 'Challenge tidak tersedia.',
        'data': {},
      });

      expect(
        () => dataSource.login(
          noHp: '081234567890',
          password: 'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('menampilkan error jika login ditolak server', () async {
      adapter.enqueue({
        'success': false,
        'message': 'Nomor HP atau password salah.',
        'data': {},
      });

      expect(
        () => dataSource.login(
          noHp: '081234567890',
          password: 'password-salah',
        ),
        throwsA(
          predicate(
            (error) =>
                error is Exception &&
                error.toString().contains(
                      'Nomor HP atau password salah.',
                    ),
          ),
        ),
      );
    });
  });

  group('AuthRemoteDataSource - OTP Login', () {
    test('meminta OTP menggunakan challengeId', () async {
      adapter.enqueue({
        'success': true,
        'message': 'OTP berhasil dikirim.',
        'expiresIn': 300,
      });

      final expiresIn = await dataSource.requestOtp(
        challengeId: 'challenge-001',
      );

      expect(expiresIn, 300);
      expect(adapter.requests.single.path, '/auth/otp/request');
      expect(_requestData(adapter.requests.single), {
        'challengeId': 'challenge-001',
      });
    });

    test('memverifikasi OTP dan mengembalikan session', () async {
      adapter.enqueue({
        'success': true,
        'message': 'Verifikasi berhasil.',
        'data': {
          'accessToken': 'login-access-token',
          'tokenType': 'Bearer',
          'user': {
            'id': 'user-001',
            'nama': 'Warga SapuLidi',
            'role': 'WARGA',
            'status': 'AKTIF',
          },
        },
      });

      final result = await dataSource.verifyOtp(
        challengeId: 'challenge-001',
        otp: '123456',
      );

      expect(result.accessToken, 'login-access-token');
      expect(result.user['role'], 'WARGA');

      expect(adapter.requests.single.path, '/auth/otp/verify');
      expect(_requestData(adapter.requests.single), {
        'challengeId': 'challenge-001',
        'otp': '123456',
      });
    });

    test('menolak OTP jika server mengembalikan success false', () async {
      adapter.enqueue({
        'success': false,
        'message': 'Kode OTP tidak valid.',
      });

      expect(
        () => dataSource.verifyOtp(
          challengeId: 'challenge-001',
          otp: '000000',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRemoteDataSource - Reset Password', () {
    test('meminta OTP reset password dengan purpose yang benar', () async {
      adapter.enqueue({
        'success': true,
        'message': 'OTP berhasil dikirim.',
        'expiresIn': 300,
      });

      final expiresIn = await dataSource.requestPasswordResetOtp(
        noHp: '081234567890',
      );

      expect(expiresIn, 300);
      expect(adapter.requests.single.path, '/auth/otp/request');
      expect(_requestData(adapter.requests.single), {
        'noHp': '081234567890',
        'purpose': 'RESET_PASSWORD',
      });
    });

    test('memverifikasi OTP reset dan memperoleh resetToken', () async {
      adapter.enqueue({
        'success': true,
        'message': 'OTP berhasil diverifikasi.',
        'data': {
          'resetToken': 'reset-token-001',
        },
      });

      final resetToken = await dataSource.verifyPasswordResetOtp(
        noHp: '081234567890',
        otp: '123456',
      );

      expect(resetToken, 'reset-token-001');
      expect(adapter.requests.single.path, '/auth/otp/verify');
      expect(_requestData(adapter.requests.single), {
        'noHp': '081234567890',
        'purpose': 'RESET_PASSWORD',
        'otp': '123456',
      });
    });

    test('menolak verifikasi jika resetToken tidak diberikan', () async {
      adapter.enqueue({
        'success': true,
        'message': 'OTP berhasil diverifikasi.',
        'data': {},
      });

      expect(
        () => dataSource.verifyPasswordResetOtp(
          noHp: '081234567890',
          otp: '123456',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('mengirim resetToken dan password baru ke server', () async {
      adapter.enqueue({
        'success': true,
        'message': 'Password berhasil diperbarui.',
      });

      await expectLater(
        dataSource.resetPassword(
          resetToken: 'reset-token-001',
          newPassword: 'passwordBaru123',
        ),
        completes,
      );

      expect(adapter.requests.single.path, '/auth/password/reset');
      expect(_requestData(adapter.requests.single), {
        'resetToken': 'reset-token-001',
        'newPassword': 'passwordBaru123',
      });
    });

    test('menampilkan error jika reset password ditolak server', () async {
      adapter.enqueue({
        'success': false,
        'message': 'Reset token tidak valid atau kedaluwarsa.',
      });

      expect(
        () => dataSource.resetPassword(
          resetToken: 'expired-token',
          newPassword: 'passwordBaru123',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRemoteDataSource - Format Response', () {
    test('menolak response dengan format yang tidak valid', () async {
      adapter.enqueue('response tidak valid');

      expect(
        () => dataSource.requestOtp(
          challengeId: 'challenge-001',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}

Map<String, dynamic> _requestData(RequestOptions options) {
  final data = options.data;

  if (data is Map<String, dynamic>) {
    return data;
  }

  if (data is String) {
    final decoded = jsonDecode(data);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  }

  throw Exception('Payload request bukan JSON object.');
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final List<dynamic> _responses = [];

  void enqueue(dynamic response) {
    _responses.add(response);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    if (_responses.isEmpty) {
      throw StateError('Tidak ada response tiruan yang disiapkan.');
    }

    final response = _responses.removeAt(0);

    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
