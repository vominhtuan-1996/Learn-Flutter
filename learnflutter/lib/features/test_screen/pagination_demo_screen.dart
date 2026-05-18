import 'package:flutter/material.dart';
import 'package:learnflutter/shared/components/pagination/pagination_controller.dart';
import 'package:learnflutter/shared/components/pagination/pagination_layout.dart';
import 'package:learnflutter/shared/components/pagination/pagination_scaffold.dart';

enum PaginationAnimationType {
  animated,
  cube3D,
  depth,
  stack,
  zoomRotate,
  parallax,
  wheel,
  flip,
  skew,
  coverFlow,
  accordion,
  door3D,
  perspectiveVertical,
  fan3D,
  tunnel3D
}

class PaginationDemoScreen extends StatefulWidget {
  const PaginationDemoScreen({super.key});

  @override
  State<PaginationDemoScreen> createState() => _PaginationDemoScreenState();
}

class _PaginationDemoScreenState extends State<PaginationDemoScreen> {
  late final PaginationController<String> _controller;
  PaginationAnimationType _animationType = PaginationAnimationType.cube3D;

  @override
  void initState() {
    super.initState();
    _controller = PaginationController<String>(
      onLoad: (page) async {
        await Future.delayed(const Duration(seconds: 1));
        return List.generate(5, (index) => 'Trang ${page * 5 + index + 1}');
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _applyAnimation(double offset, Widget child) {
    switch (_animationType) {
      case PaginationAnimationType.animated:
        return PaginationLayout.animatedItem(offset: offset, child: child);
      case PaginationAnimationType.cube3D:
        return PaginationLayout.cube3D(offset: offset, child: child);
      case PaginationAnimationType.depth:
        return PaginationLayout.depthEffect(offset: offset, child: child);
      case PaginationAnimationType.stack:
        return PaginationLayout.stackEffect(offset: offset, child: child);
      case PaginationAnimationType.zoomRotate:
        return PaginationLayout.zoomRotate(offset: offset, child: child);
      case PaginationAnimationType.parallax:
        return PaginationLayout.parallaxItem(offset: offset, child: child);
      case PaginationAnimationType.wheel:
        return PaginationLayout.wheel(offset: offset, child: child);
      case PaginationAnimationType.flip:
        return PaginationLayout.flip(offset: offset, child: child);
      case PaginationAnimationType.skew:
        return PaginationLayout.skew(offset: offset, child: child);
      case PaginationAnimationType.coverFlow:
        return PaginationLayout.coverFlow(offset: offset, child: child);
      case PaginationAnimationType.accordion:
        return PaginationLayout.accordion(offset: offset, child: child);
      case PaginationAnimationType.door3D:
        return PaginationLayout.door3D(offset: offset, child: child);
      case PaginationAnimationType.perspectiveVertical:
        return PaginationLayout.perspectiveVertical(
            offset: offset, child: child);
      case PaginationAnimationType.fan3D:
        return PaginationLayout.fan3D(offset: offset, child: child);
      case PaginationAnimationType.tunnel3D:
        return PaginationLayout.tunnel3D(offset: offset, child: child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BasePaginationScaffold<String>(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        headerBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.only(top: 50, bottom: 10),
            child: Column(
              children: [
                Text(
                  'ADVANCED SCROLL ENGINE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: PaginationAnimationType.values.map((type) {
                      final isSelected = _animationType == type;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(type.name.toUpperCase()),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _animationType = type);
                          },
                          backgroundColor: Colors.white10,
                          selectedColor: Colors.blueAccent,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
        contentBuilder: (context, item, index) {
          return AnimatedBuilder(
            animation: _controller.pageController,
            builder: (context, child) {
              double offset = 0;
              if (_controller.pageController.hasClients) {
                offset = (_controller.pageController.page ?? 0) - index;
              }

              return _applyAnimation(
                offset,
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.8),
                        Colors.purpleAccent.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 80, color: Colors.white),
                        const SizedBox(height: 20),
                        Text(
                          item,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Animation: ${_animationType.name}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        footerBuilder: (context, index) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  (_controller.items.length / 5).ceil() * 5,
                  (dotIndex) {
                    if (dotIndex >= _controller.items.length) {
                      return const SizedBox();
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == dotIndex ? 12 : 8,
                      height: index == dotIndex ? 12 : 8,
                      decoration: BoxDecoration(
                        color: index == dotIndex
                            ? Colors.blueAccent
                            : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
