import 'package:learnflutter/component/pagination/model/pagination_model.dart';
import 'package:learnflutter/core/state/base_state.dart';

class PaginationState extends BaseState {
  final List<PaginationModel> paginationModel;
  int currentStep;
  final bool isLastStep;

  PaginationState({required this.isLastStep, required this.paginationModel, required this.currentStep});

  factory PaginationState.initial(int? numbStep, bool isMaintainedTab) {
    return PaginationState(
      isLastStep: false,
      currentStep: 1,
      paginationModel: numbStep == null ? const [] : List.generate(numbStep, (index) => isMaintainedTab ? (PaginationModel()..isUploadedStep = true) : PaginationModel()),
    );
  }

  PaginationState cloneWith({
    List<PaginationModel>? paginationModel,
    int? currentStep,
    bool? isLastStep,
  }) {
    return PaginationState(
      isLastStep: isLastStep ?? this.isLastStep,
      currentStep: currentStep ?? this.currentStep,
      paginationModel: paginationModel ?? this.paginationModel,
    );
  }

  PaginationState setUploadedStep() {
    List<PaginationModel> list = List.from(paginationModel);
    list[currentStep - 1].isUploadedStep = true;
    return cloneWith(paginationModel: list);
  }

  @override
  List<Object?> get props => [paginationModel, currentStep, isLastStep];
}
