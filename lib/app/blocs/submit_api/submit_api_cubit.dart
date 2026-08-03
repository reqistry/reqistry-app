import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/submit_api/submit_api_state.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';

class SubmitApiCubit extends Cubit<SubmitApiState> {
  SubmitApiCubit() : super(const SubmitApiState());

  Future<void> submit({
    required String name,
    required String link,
  }) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      await RemoteService.submitApi(name: name, link: link);
      emit(state.copyWith(isSubmitting: false, submitted: true));
      AppSnackBarHelper.show(
        title: 'Submission received',
        message: 'Thank you! Your API was submitted for review.',
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false));
      AppSnackBarHelper.show(
        title: 'Submission failed',
        message: 'Unable to submit right now. Please try again.',
        isError: true,
      );
    }
  }
}
