import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/src/luxury_card_stack/lib/luxury_card_stack.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/metarial_carousel/material_carousel.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';

class MaterialCarouselDetail extends StatefulWidget {
  const MaterialCarouselDetail({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialCarouselDetail> createState() => _MaterialCarouselDetailState();
}

class _MaterialCarouselDetailState extends State<MaterialCarouselDetail>
    with ComponentMaterialDetail {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialScreenDetail(
      title: widget.data.title,
      description: widget.data.description,
      contentWidget: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(DeviceDimension.padding),
              child: Text(
                'Hero',
                style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 100,
              child: M3Carousel(
                visible: 4,
                borderRadius: 20,
                slideAnimationDuration: 500,
                titleFadeAnimationDuration: 300,
                childClick: (int index) {
                  print("Clicked $index");
                },
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.pink,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.red,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.purple,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.black,
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(DeviceDimension.padding),
              child: Text(
                'Center - aligned - Hero',
                style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 100,
              child: M3Carousel(
                visible: 3,
                borderRadius: 20,
                slideAnimationDuration: 500,
                titleFadeAnimationDuration: 300,
                childClick: (int index) {
                  print("Clicked $index");
                },
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.pink,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.red,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.purple,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.black,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                child: CarouselTemp(),
              ),
            ),
            SizedBox(height: context.mediaQuery.size.height / 2, child: CarouselMultiBrowse()),
            SizedBox(
              height: DeviceDimension.padding,
            ),
            LuxuryCardStackView(
              items: [
                LuxuryCardItem(
                  title: 'Rolls Royce',
                  subtitle: 'Classic',
                  tag: 'LUXURY',
                  image: 'assets/images/ic_menu_acceptance.png',
                ),
                LuxuryCardItem(
                  title: 'Rolls Royce 1 ',
                  subtitle: 'Classic',
                  tag: 'LUXURY',
                  image: 'assets/images/ic_menu_acceptance.png',
                ),
                LuxuryCardItem(
                  title: 'Rolls Royce 2',
                  subtitle: 'Classic',
                  tag: 'LUXURY',
                  image: 'assets/images/ic_menu_acceptance.png',
                ),
                LuxuryCardItem(
                  title: 'Rolls Royce 3',
                  subtitle: 'Classic',
                  tag: 'LUXURY',
                  image: 'assets/images/ic_menu_acceptance.png',
                )
              ],
              // controller: controller,
              onSwipeEnd: (index) {},
              visibleCount: 4,
              cardBuilder: (context, item, index) {
                return LuxuryCardWidget(item: item);
              },
            ),
            // StackedCards(
            //   cards: [
            //     LuxuryCardData(
            //       title: 'Rolls Royce',
            //       subtitle: 'Classic',
            //       tag: 'LUXURY',
            //       image: 'assets/images/ic_menu_acceptance.png',
            //     ),
            //     LuxuryCardData(
            //       image: 'assets/images/ic_menu_acceptance.png',
            //     ),
            //     LuxuryCardData(
            //       image: 'assets/images/ic_menu_acceptance.png',
            //     ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}

class CarouselTemp extends StatelessWidget {
  final PageController _pageController = PageController(
    viewportFraction: 0.65,
  );

  CarouselTemp({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: 5,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 0.0;
            if (_pageController.position.haveDimensions) {
              value = index - _pageController.page!;
              value = (1 - (value.abs() * 0.25)).clamp(0.0, 1.0);
            } else {
              value = (index - 1).toDouble();
              value = (1 - (value.abs() * 0.25)).clamp(0.0, 1.0);
            }
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), // Tuỳ chỉnh lại margi
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'Page ${index + 1}',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CarouselMultiBrowse extends StatelessWidget {
  final PageController _pageController = PageController(
    viewportFraction: 0.9, // Giúp nhìn thấy một phần của trang kế bên
  );

  CarouselMultiBrowse({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: 5,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            return child!;
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (itemIndex) {
                return Container(
                  width: (MediaQuery.of(context).size.width * 0.25) - 10,
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Item ${index * 3 + itemIndex + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
// Trong code này:
