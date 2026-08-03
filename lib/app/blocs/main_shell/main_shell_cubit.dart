import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';

part 'main_shell_state.dart';

class MainShellCubit extends Cubit<MainShellState> {
  static const initialTabKey = 'initialOpenTab';

  MainShellCubit()
      : super(MainShellState(
          selectedTabIndex: LocalsDB.instance.getWithKey(initialTabKey) ?? 0,
        ));

  void selectTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void navigateToSearch() {
    emit(state.copyWith(selectedTabIndex: 1));
  }
}
