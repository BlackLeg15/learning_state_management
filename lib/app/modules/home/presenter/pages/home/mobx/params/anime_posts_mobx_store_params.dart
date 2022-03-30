import 'package:flutter/foundation.dart';

class GetPostsMobxParams {
    final VoidCallback? onStateCallback;
  final VoidCallback? onErrorCallback;

  const GetPostsMobxParams({this.onStateCallback, this.onErrorCallback});
}