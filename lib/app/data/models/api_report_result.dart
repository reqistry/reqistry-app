class ApiReportResult {
  const ApiReportResult({
    required this.reason,
    required this.deduplicated,
  });

  final String reason;
  final bool deduplicated;

  String get status => deduplicated ? 'deduplicated' : 'created';

  Map<String, Object> get analyticsProperties => {
        'report_reason': reason,
        'report_status': status,
      };
}
