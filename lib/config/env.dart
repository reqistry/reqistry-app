import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiUrl = _Env.apiUrl;

  @EnviedField(varName: 'APP_NAME')
  static const String appName = _Env.appName;

  @EnviedField(varName: 'APP_DESCRIPTION')
  static const String appDescription = _Env.appDescription;

  @EnviedField(varName: 'APP_SHARE_URL')
  static const String appShareUrl = _Env.appShareUrl;

  @EnviedField(varName: 'DEVELOPER_WEBSITE_URL')
  static const String developerWebsiteUrl = _Env.developerWebsiteUrl;

  @EnviedField(varName: 'CONTACT_EMAIL')
  static const String contactEmail = _Env.contactEmail;

  @EnviedField(varName: 'PRIVACY_POLICY_URL')
  static const String privacyPolicyUrl = _Env.privacyPolicyUrl;

  @EnviedField(varName: 'METADATA_USER_AGENT')
  static const String metadataUserAgent = _Env.metadataUserAgent;

  @EnviedField(varName: 'PRIVACY_MD_URL')
  static const String privacyMdUrl = _Env.privacyMdUrl;
}
