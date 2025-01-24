import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/app/app_colors.dart';
import 'package:learnflutter/component/search_bar/cubit/search_bar_cubit.dart';
import 'package:learnflutter/component/search_bar/state/search_bar_state.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

class SearchBarBuilder extends StatefulWidget {
  final SearchController? searchController;
  final Widget Function(BuildContext)? builderWaiting;
  final Widget Function(BuildContext)? builderError;
  final Widget Function(BuildContext, dynamic) childBuilder;
  final bool isFullScreen;
  final String hintSearchFocus;
  final String hintSearchUnfocus;
  final BoxConstraints? viewConstraints;
  final void Function()? onTapChildBuilder;

  const SearchBarBuilder({
    super.key,
    this.searchController,
    this.builderWaiting,
    this.builderError,
    required this.childBuilder,
    this.isFullScreen = false,
    this.hintSearchFocus = '',
    this.hintSearchUnfocus = '',
    this.viewConstraints,
    this.onTapChildBuilder,
  });

  @override
  _SearchBarBuilderState createState() => _SearchBarBuilderState();
}

class _SearchBarBuilderState extends State<SearchBarBuilder> {
  @override
  initState() {
    super.initState();
    widget.searchController?.addListener(() {
      // Lắng nghe và xử lý sự kiện thay đổi của search bar
      if (widget.searchController?.text.isEmpty ?? false) {
        context.read<SearchCubit>().clearSuggestions();
      }
    });
  }

  BoxConstraints boxConstraints(SearchState state) {
    if (state is SearchLoading) {
      return widget.viewConstraints ?? BoxConstraints(maxHeight: context.mediaQuery.size.height / 6);
    } else if (state is SearchError) {
      return widget.viewConstraints ?? BoxConstraints(maxHeight: context.mediaQuery.size.height / 3);
    } else if (state is SearchLoaded) {
      return widget.viewConstraints ?? BoxConstraints(maxHeight: state.suggestions.isNotEmpty ? context.mediaQuery.size.height / 2 : context.mediaQuery.size.height / 3);
    }
    return widget.viewConstraints ?? BoxConstraints(maxHeight: context.mediaQuery.size.height / 2);
  }

  @override
  void dispose() {
    widget.searchController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return SearchAnchor.bar(
          searchController: widget.searchController ?? SearchController(),
          suggestionsBuilder: (context, controller) {
            return [
              BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return widget.builderWaiting?.call(context) ??
                        Center(
                          child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CupertinoActivityIndicator()),
                        );
                  } else if (state is SearchError) {
                    return widget.builderError?.call(context) ?? Text('Error fetching suggestions');
                  } else if (state is SearchLoaded) {
                    return Builder(
                      builder: (context) => SingleChildScrollView(
                        child: Column(
                          children: List.generate(
                            state.suggestions.length,
                            (index) => GestureDetector(
                              onTap: () {
                                controller.text = state.suggestions[index];
                                widget.onTapChildBuilder?.call();
                              },
                              child: widget.childBuilder(context, state.suggestions[index]),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ];
          },
          isFullScreen: widget.isFullScreen,
          viewHintText: widget.hintSearchFocus,
          barHintText: widget.hintSearchUnfocus,
          viewConstraints: boxConstraints(state),
          dividerColor: Colors.transparent,
          barBackgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.red;
              }
              return Colors.blue;
            },
          ),
          viewBackgroundColor: Colors.white,
          onChanged: (value) {
            context.read<SearchCubit>().fetchSuggestions(value);
          },
          onSubmitted: (value) {
            print('onSubmitted');
          },
          onTap: () {
            print('onTap');
          },
          barShape: WidgetStateProperty.resolveWith<OutlinedBorder>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: const BorderSide(
                    color: Colors.transparent,
                    width: 1.6,
                  ),
                );
              }
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: const BorderSide(
                  color: Colors.transparent,
                  width: 1.6,
                ),
              );
            },
          ),
          viewShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: const BorderSide(
              color: Colors.transparent,
              width: 1.6,
            ),
          ),
          // barPadding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
          //   (states) {
          //     if (states.contains(WidgetState.selected)) {
          //       return const EdgeInsets.all(8);
          //     }
          //     return EdgeInsets.zero;
          //   },
          // ),
        );
      },
    );
  }
}
