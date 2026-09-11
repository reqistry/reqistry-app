/// Machine-readable codes the billing endpoints return. Behavior keys off
/// these, never off human-readable error text.
abstract final class FailureCode {
  static const String emailRequired = 'email_required';
  static const String inactiveSubscription = 'inactive_subscription';
  static const String upgradeRequired = 'upgrade_required';
  static const String tokenOwned = 'token_owned';
}

class Failure {
  final String title;
  final String content;
  final String? code;

  Failure(this.title, this.content, {this.code});
}
