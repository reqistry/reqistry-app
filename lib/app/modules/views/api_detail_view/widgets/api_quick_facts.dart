import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/detail_section.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/fact_row.dart';

class ApiQuickFacts extends StatelessWidget {
  const ApiQuickFacts({super.key, required this.detail});

  final ApiDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final facts = [
      (l10n.apiDetailAuthentication, detail.access.authLabel),
      (l10n.apiDetailPricing, detail.access.pricingLabel),
      (l10n.apiDetailHttps, _nullableSupportL10n(detail.capabilities.https, l10n)),
      (l10n.apiDetailCors, _corsLabelL10n(detail.capabilities.cors, l10n)),
      (l10n.apiDetailApiType, _protocolLabelL10n(detail.capabilities.protocol, l10n)),
      (
        l10n.apiDetailResponseFormat,
        detail.capabilities.responseFormats.isEmpty
            ? l10n.apiDetailUnknownValue
            : detail.capabilities.responseFormats.join(', '),
      ),
      if (detail.access.creditCardRequired != null)
        (
          l10n.apiDetailCreditCardRequired,
          detail.access.creditCardRequired! ? l10n.apiDetailYes : l10n.apiDetailNo,
        ),
      if (detail.access.commercialUseAllowed != null)
        (
          l10n.apiDetailCommercialUse,
          _nullableSupportL10n(detail.access.commercialUseAllowed, l10n),
        ),
      if (detail.capabilities.openApiAvailable != null)
        (
          l10n.apiDetailOpenApiAvailable,
          _nullableSupportL10n(detail.capabilities.openApiAvailable, l10n),
        ),
      if (detail.capabilities.sdkLanguages.isNotEmpty)
        (l10n.apiDetailSdks, detail.capabilities.sdkLanguages.join(', ')),
      if (detail.access.rateLimit != null)
        (l10n.apiDetailRateLimit, detail.access.rateLimit!),
    ];
    return DetailSection(
      title: l10n.sectionQuickFacts,
      child: Column(
        children: [
          for (var index = 0; index < facts.length; index++) ...[
            FactRow(label: facts[index].$1, value: facts[index].$2),
            if (index != facts.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

String _nullableSupportL10n(bool? value, AppLocalizations l10n) => switch (value) {
      true => l10n.apiDetailSupported,
      false => l10n.apiDetailNotSupported,
      null => l10n.apiDetailUnknownValue,
    };

String _corsLabelL10n(CorsSupport value, AppLocalizations l10n) => switch (value) {
      CorsSupport.supported => l10n.apiDetailSupported,
      CorsSupport.unsupported => l10n.apiDetailNotSupported,
      CorsSupport.unknown => l10n.apiDetailUnknownValue,
    };

String _protocolLabelL10n(ApiProtocol value, AppLocalizations l10n) => switch (value) {
      ApiProtocol.rest => l10n.apiDetailRest,
      ApiProtocol.graphql => l10n.apiDetailGraphql,
      ApiProtocol.soap => l10n.apiDetailSoap,
      ApiProtocol.websocket => l10n.apiDetailWebsocket,
      ApiProtocol.unknown => l10n.apiDetailUnknownValue,
    };
