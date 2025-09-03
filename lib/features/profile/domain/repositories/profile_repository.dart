import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity?> getMyProfile();
  Future<UserProfileEntity> upsertMyProfile(UserProfileEntity profile);
}
