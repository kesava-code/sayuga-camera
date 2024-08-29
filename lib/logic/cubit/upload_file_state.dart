part of 'upload_file_cubit.dart';

abstract class UploadFileState {
  const UploadFileState();

 
}
class UploadFileInitial extends UploadFileState{}
class UploadFileUploading extends UploadFileState {}
class UploadFileUploaded extends UploadFileState{}
class UploadFileError extends UploadFileState{}
