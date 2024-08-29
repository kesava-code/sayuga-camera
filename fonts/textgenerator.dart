import 'dart:io';

void main() async {
  final fontZipFile = await File('Comfortaa-Bold.ttf.zip').readAsBytes();
  print(fontZipFile);
}
