import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_wallet/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:mart_wallet/features/profile/data/profile_repository_impl.dart';
import 'package:mart_wallet/features/profile/domain/entities/user_profile_entity.dart';
import 'package:mart_wallet/features/profile/domain/repositories/profile_repository.dart';
import 'package:mart_wallet/core/network/dio_client.dart';

class ProfileState {
  final bool loading;
  final UserProfileEntity? profile;
  final String? error;
  final bool exists;
  ProfileState({
    this.loading = true,
    this.profile,
    this.error,
    this.exists = false,
  });

  ProfileState copyWith({
    bool? loading,
    UserProfileEntity? profile,
    String? error,
    bool? exists,
  }) => ProfileState(
    loading: loading ?? this.loading,
    profile: profile ?? this.profile,
    error: error,
    exists: exists ?? this.exists,
  );
}

class ProfileController extends StateNotifier<ProfileState> {
  final ProfileRepository repo;
  ProfileController(this.repo) : super(ProfileState());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final p = await repo.getMyProfile();
      state = state.copyWith(loading: false, profile: p, exists: p != null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> upsert(UserProfileEntity profile) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final p = await repo.upsertMyProfile(profile);
      state = state.copyWith(loading: false, profile: p, exists: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final profileRemoteDataSourceProvider = Provider(
  (ref) => ProfileRemoteDataSource(DioClient()),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.read(profileRemoteDataSourceProvider)),
);

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      return ProfileController(ref.read(profileRepositoryProvider));
    });
