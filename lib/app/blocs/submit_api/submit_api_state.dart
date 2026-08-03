import 'package:equatable/equatable.dart';

class SubmitApiState extends Equatable {
  final bool isSubmitting;
  final bool submitted;

  const SubmitApiState({
    this.isSubmitting = false,
    this.submitted = false,
  });

  SubmitApiState copyWith({
    bool? isSubmitting,
    bool? submitted,
  }) {
    return SubmitApiState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitted: submitted ?? this.submitted,
    );
  }

  @override
  List<Object> get props => [isSubmitting, submitted];
}
