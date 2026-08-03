import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/services/local_db/hive/initializer.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';
import 'package:api_scout/app/services/share/share_plus/share_plus.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/config/env.dart';

part 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  static const initialTabKey = 'initialOpenTab';

  AppSettingsCubit()
      : super(AppSettingsState(
          initialTabIndex: LocalsDB.instance.getWithKey(initialTabKey) ??
              AppRoutes.tabIndexHome,
        ));

  Future<void> exportBookmarks() async {
    try {
      final dio = DioClient().dio;
      final response =
          await dio.get('/v1/bookmarks', queryParameters: {'limit': 100});
      final bookmarks = (response.data['bookmarks'] as List?) ?? [];
      if (bookmarks.isEmpty) {
        AppSnackBarHelper.show(
          title: 'No bookmarks',
          message: 'You have no bookmarks to export.',
        );
        return;
      }

      final buffer = StringBuffer()
        ..writeln('Bookmarked APIs')
        ..writeln('--------------------');

      for (final b in bookmarks) {
        final api = b['api'] ?? {};
        buffer
          ..writeln('- ${api['name']}')
          ..writeln('  ${api['description']}')
          ..writeln('  ${api['link']}')
          ..writeln();
      }

      await ShareService.instance.shareText(buffer.toString());
    } catch (_) {
      AppSnackBarHelper.show(
        title: 'Export failed',
        message: 'Could not export bookmarks.',
        isError: true,
      );
    }
  }

  Future<bool> clearLocalData() async {
    try {
      await LocalDatabase.instance.clearAllLocalData();
      DioClient().setAccessToken(null);
      AppSnackBarHelper.success(
        title: 'Local data cleared',
        message: '${Env.appName} will start fresh.',
      );
      return true;
    } catch (_) {
      AppSnackBarHelper.error(
        title: 'Clear failed',
        message: 'Unable to clear local data right now.',
      );
      return false;
    }
  }

  Future<void> setInitialTab(int index) async {
    await LocalsDB.instance.putWithKey(initialTabKey, index);
    emit(state.copyWith(initialTabIndex: index));
    AppSnackBarHelper.success(
      title: 'Startup updated',
      message: index == AppRoutes.tabIndexSearch
          ? '${Env.appName} will open on Discover.'
          : '${Env.appName} will open on Home.',
    );
  }
}
