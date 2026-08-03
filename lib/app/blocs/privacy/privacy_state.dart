part of 'privacy_cubit.dart';

class PrivacyState extends Equatable {
  final String content;
  final bool isLoading;
  final String errorMessage;
  final bool shouldNavigateToPage;

  const PrivacyState({
    this.content = '',
    this.isLoading = false,
    this.errorMessage = '',
    this.shouldNavigateToPage = false,
  });

  PrivacyState copyWith({
    String? content,
    bool? isLoading,
    String? errorMessage,
    bool? shouldNavigateToPage,
  }) {
    return PrivacyState(
      content: content ?? this.content,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      shouldNavigateToPage: shouldNavigateToPage ?? this.shouldNavigateToPage,
    );
  }

  @override
  List<Object> get props => [
        content,
        isLoading,
        errorMessage,
        shouldNavigateToPage,
      ];
}
