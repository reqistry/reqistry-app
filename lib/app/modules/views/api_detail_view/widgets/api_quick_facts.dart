import 'package:flutter/material.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/detail_section.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/fact_row.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/api_health_section.dart';

class ApiQuickFacts extends StatelessWidget {
  const ApiQuickFacts({super.key, required this.detail});

  final ApiDetail detail;

  @override
  Widget build(BuildContext context) {
    final facts = [
      ('Authentication', detail.access.authLabel),
      ('Pricing', detail.access.pricingLabel),
      ('HTTPS', nullableSupport(detail.capabilities.https)),
      ('CORS', corsLabel(detail.capabilities.cors)),
      ('API type', protocolLabel(detail.capabilities.protocol)),
      (
        'Response format',
        detail.capabilities.responseFormats.isEmpty
            ? 'Unknown'
            : detail.capabilities.responseFormats.join(', '),
      ),
      if (detail.access.creditCardRequired != null)
        (
          'Credit card required',
          detail.access.creditCardRequired! ? 'Yes' : 'No',
        ),
      if (detail.access.commercialUseAllowed != null)
        (
          'Commercial use',
          nullableSupport(detail.access.commercialUseAllowed),
        ),
      if (detail.capabilities.openApiAvailable != null)
        (
          'OpenAPI available',
          nullableSupport(detail.capabilities.openApiAvailable)
        ),
      if (detail.capabilities.sdkLanguages.isNotEmpty)
        ('SDKs', detail.capabilities.sdkLanguages.join(', ')),
      if (detail.access.rateLimit != null)
        ('Rate limit', detail.access.rateLimit!),
    ];
    return DetailSection(
      title: 'QUICK FACTS',
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

String nullableSupport(bool? value) => switch (value) {
      true => 'Supported',
      false => 'Not supported',
      null => 'Unknown',
    };

String corsLabel(CorsSupport value) => switch (value) {
      CorsSupport.supported => 'Supported',
      CorsSupport.unsupported => 'Not supported',
      CorsSupport.unknown => 'Unknown',
    };

String protocolLabel(ApiProtocol value) => switch (value) {
      ApiProtocol.rest => 'REST',
      ApiProtocol.graphql => 'GraphQL',
      ApiProtocol.soap => 'SOAP',
      ApiProtocol.websocket => 'WebSocket',
      ApiProtocol.unknown => 'Unknown',
    };
