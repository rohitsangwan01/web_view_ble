String convertToIOSUUid(String uuid) {
  if (uuid.length > 6) {
    var uuidSeprator = uuid.split('-');
    if (uuidSeprator.isNotEmpty) {
      String firstId = uuidSeprator[0];
      if (firstId.contains('0000')) {
        return firstId.replaceAll('0000', '');
      }
    }
    return uuid;
  } else {
    return uuid;
  }
}
