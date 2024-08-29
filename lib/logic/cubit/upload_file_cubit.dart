import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

part 'upload_file_state.dart';

class UploadFileCubit extends Cubit<UploadFileState> {
  UploadFileCubit() : super(UploadFileInitial());

  void uploadFile({required String filePath}) async {
    emit(UploadFileUploading());
    File file = File(filePath);
    var stream = http.ByteStream(file.openRead());
    stream.cast();
    int length = await file.length();
    Uri uri = Uri.parse("https://s1.sayuga.com/uploads/");
    http.MultipartFile multipartFile =
        http.MultipartFile('file', stream, length, filename: filePath);
    http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 201) {
      emit(UploadFileUploaded());
      return;
    }
    
    emit(UploadFileError());
  }
}
