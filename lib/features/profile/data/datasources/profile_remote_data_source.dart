import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileRemoteDataSource {
  final Dio _dio;
  ProfileRemoteDataSource(DioClient client) : _dio = client.dio;

  Future<UserProfileEntity?> getMyProfile() async {
    final res = await _dio.get('/users/me/profile');
    if (res.data is Map && res.data['message'] == 'PROFILE_NOT_CONFIGURED') {
      return null;
    }
    return UserProfileEntity.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<UserProfileEntity> upsertMyProfile(UserProfileEntity profile) async {
    final res = await _dio.post('/users/me/profile', data: profile.toJson());
    return UserProfileEntity.fromJson(Map<String, dynamic>.from(res.data));
  }
}
