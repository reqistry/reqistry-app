import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';

part 'main_shell_state.dart';

class MainShellCubit extends Cubit<MainShellState> {
  static const initialTabKey = 'initialOpenTab';
  static const tabCount = 5;

  MainShellCubit()
      : super(MainShellState(
          selectedTabIndex: _sanitizeTab(
            LocalsDB.instance.getWithKey(initialTabKey),
          ),
        ));

  static int _sanitizeTab(Object? raw) {
    if (raw is! int) return 0;
    if (raw < 0 || raw >= tabCount) return 0;
    return raw;
  }

  void selectTab(int index) {
    if (index < 0 || index >= tabCount) return;
    emit(state.copyWith(selectedTabIndex: index));
  }

  void navigateToSearch() {
    emit(state.copyWith(selectedTabIndex: 1));
  }
}
