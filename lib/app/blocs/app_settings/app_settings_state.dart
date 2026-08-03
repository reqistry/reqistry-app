part of 'app_settings_cubit.dart';

class AppSettingsState extends Equatable {
  final int initialTabIndex;

  const AppSettingsState({
    this.initialTabIndex = AppRoutes.tabIndexHome,
  });

  AppSettingsState copyWith({
    int? initialTabIndex,
  }) {
    return AppSettingsState(
      initialTabIndex: initialTabIndex ?? this.initialTabIndex,
    );
  }

  @override
  List<Object> get props => [initialTabIndex];
}
