import 'package:equatable/equatable.dart';

class PaginationModel extends Equatable {
  bool isUploadedStep;

  PaginationModel({this.isUploadedStep = false});

  @override
  List<Object?> get props => [isUploadedStep];
}
