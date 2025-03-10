import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/app/app_text_style.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/cubit/metarial_radio_button_cubit.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/state/metarial_radio_buton_state.dart';

enum RadioType { single, multi }

class MetarialRadioButton<M extends RadioItemModel> extends StatefulWidget {
  MetarialRadioButton({
    super.key,
    required this.enable,
    this.data,
    this.type = RadioType.single,
    this.onToggleValue,
    this.onChangeValue,
    this.direction = Axis.vertical,
  });
  final bool enable;
  List<M>? data;
  RadioType type;
  void Function(List<M>? items)? onToggleValue;
  void Function(M? item)? onChangeValue;
  final Axis direction;
  factory MetarialRadioButton.mutiselect({
    required bool enable,
    List<M>? data,
    void Function(List<M>? items)? onToggleValue,
    Axis direction = Axis.vertical,
  }) {
    return MetarialRadioButton(
      enable: enable,
      data: data,
      type: RadioType.multi,
      onToggleValue: onToggleValue,
      direction: direction,
    );
  }

  factory MetarialRadioButton.single({
    required bool enable,
    List<M>? data,
    void Function(M? item)? onChangeValue,
    Axis direction = Axis.vertical,
  }) {
    return MetarialRadioButton(
      enable: enable,
      data: data,
      type: RadioType.single,
      onChangeValue: onChangeValue,
      direction: direction,
    );
  }
  @override
  State<MetarialRadioButton> createState() => MetarialRadioButtonState();
}

class MetarialRadioButtonState<M extends RadioItemModel> extends State<MetarialRadioButton> {
  late MetarialRadioButtonCubit cubit;

  @override
  void initState() {
    cubit = MetarialRadioButtonCubit(MetarialRadioButonState.initial(widget.data, widget.type));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<MetarialRadioButtonCubit, MetarialRadioButonState<RadioItemModel>>(
        builder: (context, state) {
          return widget.direction == Axis.vertical
              ? Column(
                  children: List.generate(
                    state.listData?.length ?? 0,
                    (index) {
                      return AbsorbPointer(
                        absorbing: !widget.enable,
                        child: GestureDetector(
                          onTap: () async {
                            await cubit.toggleValue(state.listData?[index].id ?? "");
                            widget.onToggleValue?.call(state.listData?.where((element) => element.isSelected).toList());
                            widget.onChangeValue?.call(state.listData?[index]);
                          },
                          child: Row(
                            children: [
                              Radio(
                                value: (state.listData?[index] as M).isSelected,
                                groupValue: true,
                                onChanged: (value) async {
                                  await cubit.toggleValue(state.listData?[index].id ?? "");
                                  widget.onToggleValue?.call(state.listData?.where((element) => element.isSelected).toList());
                                  widget.onChangeValue?.call(state.listData?[index]);
                                },
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.listData?[index].title ?? "",
                                        // textDirection: TextDirection.ltr,
                                        // textAlign: TextAlign.left,
                                      ),
                                      Divider(
                                        height: 1,
                                        indent: 0,
                                        endIndent: 0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    state.listData?.length ?? 0,
                    (index) {
                      return AbsorbPointer(
                        absorbing: !widget.enable,
                        child: GestureDetector(
                          onTap: () async {
                            await cubit.toggleValue(state.listData?[index].id ?? "");
                            widget.onToggleValue?.call(state.listData?.where((element) => element.isSelected).toList());
                            widget.onChangeValue?.call(state.listData?[index]);
                          },
                          child: Row(
                            children: [
                              Radio(
                                value: (state.listData?[index] as M).isSelected,
                                groupValue: true,
                                onChanged: (value) async {
                                  await cubit.toggleValue(state.listData?[index].id ?? "");
                                  widget.onToggleValue?.call(state.listData?.where((element) => element.isSelected).toList());
                                  widget.onChangeValue?.call(state.listData?[index]);
                                },
                              ),
                              Text(
                                state.listData?[index].title ?? "",
                                // textDirection: TextDirection.ltr,
                                // textAlign: TextAlign.left,
                              ),
                              // Expanded(
                              //   child: Container(
                              //     color: Colors.transparent,
                              //     child: Column(
                              //       mainAxisAlignment: MainAxisAlignment.end,
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       children: [
                              //         Text(
                              //           state.listData?[index].title ?? "",
                              //           // textDirection: TextDirection.ltr,
                              //           // textAlign: TextAlign.left,
                              //         ),
                              //         Divider(
                              //           height: 1,
                              //           indent: 0,
                              //           endIndent: 0,
                              //         )
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
