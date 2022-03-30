import 'package:flutter/foundation.dart';

class FetchPostsMobxParams {
  final VoidCallback? onStateCallback;
  final VoidCallback? onErrorCallback;

  const FetchPostsMobxParams({this.onStateCallback, this.onErrorCallback});
}
