import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:encrypt/encrypt.dart';

enum Mode {
  encrypt,
  decrypt,
}

void main(List<String> args) async {
  final homePath = Platform.environment['HOME'];
  final configPath = p.join(homePath as String, '.password-encrypt');
  var mode = Mode.encrypt;
  for (final item in args) {
    if (item.startsWith('-mode:')) {
      final modeValue = item.substring(6);
      if (modeValue == 'decrypt') mode = Mode.decrypt;
    }
  }

  final toEncryptFile = p.join(configPath, 'password.txt');
  final encryptedFile = p.join(configPath, 'encrypted-password.txt');
  final decryptedFile = p.join(configPath, 'decryped-password.txt');
  final keyFile = p.join(configPath, 'key.txt');
  final keyString = (await File(keyFile).readAsString()).trim();
  final key = Key.fromBase64(keyString);
  final iv = IV(Uint8List(16));

  final encrypter = Encrypter(AES(key));

  switch (mode) {
    case Mode.encrypt:
      {
        final fileContent = await File(toEncryptFile).readAsString();
        final encrypted = encrypter.encrypt(fileContent, iv: iv);
        await File(encryptedFile).writeAsString(encrypted.base64);

        print('Password file successfully encrypted');
      }
    case Mode.decrypt:
      {
        final encryptedBase64 =
            (await File(encryptedFile).readAsString()).trim();
        final decrypted =
            encrypter.decrypt(Encrypted.fromBase64(encryptedBase64), iv: iv);
        await File(decryptedFile).writeAsString(decrypted);

        print('Password file decrypted');
      }
  }
}
