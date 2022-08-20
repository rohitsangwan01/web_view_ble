String convertToiOSUid(String uuid) {
  if (uuid.length > 6) {
    var uuidSeparator = uuid.split('-');
    if (uuidSeparator.isNotEmpty) {
      String firstId = uuidSeparator[0];
      if (firstId.contains('0000')) {
        return firstId.replaceAll('0000', '');
      }
    }
    return uuid;
  } else {
    return uuid;
  }
}

String validateUUid(String uuid) {
  if (uuid.length > 6) {
    return uuid;
  } else {
    return "0000$uuid-0000-1000-8000-00805f9b34fb";
  }
}
