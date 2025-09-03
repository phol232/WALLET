import 'package:mart_wallet/features/profile/domain/entities/user_profile_entity.dart';
import 'package:mart_wallet/features/profile/domain/repositories/profile_repository.dart';
import 'package:mart_wallet/features/profile/data/datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  ProfileRepositoryImpl(this.remote);

  @override
  Future<UserProfileEntity?> getMyProfile() => remote.getMyProfile();

  @override
  Future<UserProfileEntity> upsertMyProfile(UserProfileEntity profile) =>
      remote.upsertMyProfile(profile);
}
