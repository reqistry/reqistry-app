part of 'main_shell_cubit.dart';

class MainShellState extends Equatable {
  final int selectedTabIndex;

  const MainShellState({this.selectedTabIndex = 0});

  MainShellState copyWith({int? selectedTabIndex}) {
    return MainShellState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object> get props => [selectedTabIndex];
}
