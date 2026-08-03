import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'user_activity_state.dart';

class UserActivityCubit extends Cubit<UserActivityState> {
  final AuthCubit _authCubit;
  final FavoritesCubit _favoritesCubit;

  UserActivityCubit({
    required AuthCubit authCubit,
    required FavoritesCubit favoritesCubit,
  })  : _authCubit = authCubit,
        _favoritesCubit = favoritesCubit,
        super(const UserActivityState()) {
    loadStats();
    _favoritesCubit.changed.addListener(_onBookmarksChanged);
  }

  void _onBookmarksChanged() {
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      emit(state.copyWith(isLoading: true));
      final stats = await _authCubit.fetchStats();
      if (stats != null) {
        emit(state.copyWith(
          totalBookmarks: stats.totalBookmarks,
          totalProjects: stats.totalProjects,
          totalProjectItems: stats.totalProjectItems,
          daysSinceCreation: stats.daysSinceCreation,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void refresh() => loadStats();

  @override
  Future<void> close() {
    _favoritesCubit.changed.removeListener(_onBookmarksChanged);
    return super.close();
  }
}
