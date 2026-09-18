import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/submit_api/submit_api_state.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class SubmitApiCubit extends Cubit<SubmitApiState> {
  SubmitApiCubit() : super(const SubmitApiState());

  Future<void> submit({
    required String name,
    required String link,
    required AppLocalizations l10n,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true));

    try {
      await RemoteService.submitApi(name: name, link: link, l10n: l10n);
      emit(state.copyWith(isSubmitting: false, submitted: true));
      AppSnackBarHelper.show(
        title: l10n.snackbarSubmissionReceivedTitle,
        message: l10n.snackbarSubmissionReceivedMessage,
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false));
      AppSnackBarHelper.show(
        title: l10n.snackbarSubmissionFailedTitle,
        message: l10n.snackbarSubmissionFailedMessage,
        isError: true,
      );
    }
  }
}
