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

  void set(DialogData dialog) {
    state = dialog;
  }
}