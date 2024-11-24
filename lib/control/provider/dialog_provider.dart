import 'package:flutter_riverpod/flutter_riverpod.dart';

class DialogData {
  DialogData();
  String title = '';
  String message = '';
}

final dialogProvider = StateNotifierProvider<DialogState, DialogData>((ref) {
  return DialogState();
});

class DialogState extends StateNotifier<DialogData> {
  DialogState() : super(DialogData());

  // ignore: use_setters_to_change_properties
  void set(DialogData dialog) {
    state = dialog;
  }
}