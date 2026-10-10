import 'package:api_scout/app/modules/views/main_shell_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shell tabs have stable analytics names', () {
    expect(
      [for (var index = 0; index < 5; index++) shellTabScreenName(index)],
      ['home', 'discover', 'intelligence', 'saved', 'settings'],
    );
    expect(shellTabScreenName(-1), 'unknown');
  });
}
