/// User submission history from `GET /v1/submissions/mine`.
///
/// Backend resolves `api` only for approved/duplicate rows that map to a
/// published API; every other status carries `api: null`.
class SubmissionApiRef {
  final String id;
  final String slug;
  final String name;

  const SubmissionApiRef({
    required this.id,
    required this.slug,
    required this.name,
  });

  factory SubmissionApiRef.fromJson(Map<String, dynamic> json) {
    return SubmissionApiRef(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
    );
  }
}

class SubmissionItem {
  final String submissionId;
  final String? name;
  final String? link;
  final String status;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime? submittedAt;
  final SubmissionApiRef? api;

  const SubmissionItem({
    required this.submissionId,
    this.name,
    this.link,
    required this.status,
    this.rejectionReason,
    this.reviewedAt,
    this.submittedAt,
    this.api,
  });

  factory SubmissionItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    final apiJson = json['api'];
    return SubmissionItem(
      submissionId: json['submissionId']?.toString() ?? '',
      name: json['name']?.toString(),
      link: json['link']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: json['rejectionReason']?.toString(),
      reviewedAt: parseDate(json['reviewedAt']),
      submittedAt: parseDate(json['submittedAt']),
      api: apiJson is Map<String, dynamic>
          ? SubmissionApiRef.fromJson(apiJson)
          : null,
    );
  }

  /// Slugs that can deep-link to API detail (approved/duplicate rows).
  String? get routableSlug {
    final slug = api?.slug.trim() ?? '';
    return slug.isEmpty ? null : slug;
  }

  String displayTitle() {
    final title =
        (name?.trim().isNotEmpty == true ? name!.trim() : link?.trim() ?? '');
    return title.isEmpty ? 'Unknown' : title;
  }
}
