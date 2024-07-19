import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateHash(String input) {
  var bytes = utf8.encode(input); // data being hashed
  var digest = sha256.convert(bytes);
  return digest.toString();
}

bool verifyPassword(String input, String hashed) {
  return generateHash(input) == hashed;
}
