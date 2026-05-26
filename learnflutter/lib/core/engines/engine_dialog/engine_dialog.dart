/// Engine Dialog – Bộ dialog & snackbar chuẩn hóa cho toàn dự án.
///
/// ## Import duy nhất:
/// ```dart
/// import 'package:learnflutter/core/engines/engine_dialog/engine_dialog.dart';
/// ```
///
/// ## Dialog shortcuts (cần context):
/// ```dart
/// AppDialogEngine.showInfo(context, message: '...');
/// AppDialogEngine.showError(context, message: '...');
/// AppDialogEngine.showSuccess(context, message: '...');
/// AppDialogEngine.showWarning(context, message: '...');
/// AppDialogEngine.show(context, config: AppDialogConfig(...));
/// ```
///
/// ## Context-free shortcuts (dùng navigatorKey, gọi từ Cubit/Repo OK):
/// ```dart
/// AppDialogEngine.info('...');
/// AppDialogEngine.success('...');
/// AppDialogEngine.error('...');
/// AppDialogEngine.warning('...', onConfirm: () {});
/// AppDialogEngine.showUpdatePatch(version: '1.2.3', changelog: [...], onUpdate: () {});
/// ```
///
/// ## Snackbar shortcuts:
/// ```dart
/// AppSnackbarEngine.showInfo(context, message: '...');
/// AppSnackbarEngine.showError(context, message: '...');
/// AppSnackbarEngine.showSuccess(context, message: '...');
/// AppSnackbarEngine.showWarning(context, message: '...');
/// AppSnackbarEngine.show(context, config: AppSnackbarConfig(...));
/// ```
library;

export 'app_dialog_engine.dart';
export 'app_snackbar_engine.dart';
export 'models/dialog_config.dart';
export 'widgets/dialog_base_widget.dart';
export 'widgets/snackbar_base_widget.dart';
export 'widgets/process_stepper_widget.dart';
export 'widgets/multi_transfer_dialog.dart';
export 'widgets/update_patch_dialog.dart';
