part of 'api_detail_cubit.dart';

class ApiDetailState extends Equatable {
  final ApiDetail? detail;
  final bool isLoadingCore;
  final bool isRefreshingCore;
  final bool isRefreshingHealth;
  final bool isLoadingAlternatives;
  final bool isReportingIssue;
  final String? coreError;
  final String? healthError;
  final String? alternativesError;
  final String? transientMessage;

  const ApiDetailState({
    this.detail,
    this.isLoadingCore = false,
    this.isRefreshingCore = false,
    this.isRefreshingHealth = false,
    this.isLoadingAlternatives = false,
    this.isReportingIssue = false,
    this.coreError,
    this.healthError,
    this.alternativesError,
    this.transientMessage,
  });

  ApiDetailState copyWith({
    ApiDetail? detail,
    bool? isLoadingCore,
    bool? isRefreshingCore,
    bool? isRefreshingHealth,
    bool? isLoadingAlternatives,
    bool? isReportingIssue,
    String? coreError,
    String? healthError,
    String? alternativesError,
    String? transientMessage,
    bool clearCoreError = false,
    bool clearHealthError = false,
    bool clearAlternativesError = false,
    bool clearTransientMessage = false,
  }) {
    return ApiDetailState(
      detail: detail ?? this.detail,
      isLoadingCore: isLoadingCore ?? this.isLoadingCore,
      isRefreshingCore: isRefreshingCore ?? this.isRefreshingCore,
      isRefreshingHealth: isRefreshingHealth ?? this.isRefreshingHealth,
      isLoadingAlternatives:
          isLoadingAlternatives ?? this.isLoadingAlternatives,
      isReportingIssue: isReportingIssue ?? this.isReportingIssue,
      coreError: clearCoreError ? null : coreError ?? this.coreError,
      healthError: clearHealthError ? null : healthError ?? this.healthError,
      alternativesError: clearAlternativesError
          ? null
          : alternativesError ?? this.alternativesError,
      transientMessage: clearTransientMessage
          ? null
          : transientMessage ?? this.transientMessage,
    );
  }

  @override
  List<Object?> get props => [
        detail,
        isLoadingCore,
        isRefreshingCore,
        isRefreshingHealth,
        isLoadingAlternatives,
        isReportingIssue,
        coreError,
        healthError,
        alternativesError,
        transientMessage,
      ];
}
