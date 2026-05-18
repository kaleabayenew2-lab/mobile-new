import 'package:flutter/foundation.dart';

String resolveHostUrl(String imageUrl) {
  if (imageUrl.startsWith('/uploads/') || imageUrl.startsWith('uploads/')) {
    return '${_localHostRoot()}/${imageUrl.replaceFirst(RegExp(r'^/+'), '')}';
  }

  if (imageUrl.startsWith('http://127.0.0.1:5000') || imageUrl.startsWith('http://localhost:5000')) {
    return imageUrl.replaceFirst(
      RegExp(r'^http://(127\.0\.0\.1|localhost):5000'),
      _localHostRoot(),
    );
  }

  return imageUrl;
}

String _localHostRoot() {
  if (kIsWeb) return 'http://127.0.0.1:5000';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5000';
  }
  return 'http://127.0.0.1:5000';
}
