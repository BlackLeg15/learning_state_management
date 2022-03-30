import 'package:flutter/foundation.dart';

class FetchPostsNotifierParams {
  final VoidCallback? onStateCallback;
  final VoidCallback? onErrorCallback;

  const FetchPostsNotifierParams({this.onStateCallback, this.onErrorCallback});
}
