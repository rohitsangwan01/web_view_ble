import 'dart:developer' as developer;

void logInfo(dynamic msg) {
  developer.log('\x1B[34m$msg\x1B[34m', name: "WebViewBle");
}

void logSuccess(dynamic msg) {
  developer.log('\x1B[32m$msg\x1B[32m', name: "WebViewBle");
}

void logWarning(dynamic msg) {
  developer.log('\x1B[33m$msg\x1B[33m', name: "WebViewBle");
}

void logError(dynamic msg) {
  developer.log('\x1B[31m$msg\x1B[31m', name: "WebViewBle");
}
