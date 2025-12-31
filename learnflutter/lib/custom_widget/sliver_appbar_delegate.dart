import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learnflutter/component/sliver_appbar/action_and_balance_card.dart';
import 'package:learnflutter/component/sliver_appbar/icon_img_button.dart';
import 'package:learnflutter/component/sliver_appbar/main-appbar.dart';
import 'package:learnflutter/component/sliver_appbar/notification_handler.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  const SliverAppBarDelegate({
    required this.minExtent,
    required this.maxExtent,
  });

  @override
  final double minExtent;

  @override
  final double maxExtent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return minExtent != oldDelegate.minExtent || maxExtent != oldDelegate.maxExtent;
  }

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration();

  double get deltaExtent => maxExtent - minExtent;

  static const imgBgr =
      Image(image: AssetImage('assets/images/slier_appbar_bgr.webp'), fit: BoxFit.cover);

  double transform(double begin, double end, double t, [double x = 1]) {
    return Tween<double>(begin: begin, end: end).transform(x == 1 ? t : min(1.0, t * x));
  }

  Color transformColor(Color? begin, Color? end, double t, [double x = 1]) {
    return ColorTween(begin: begin, end: end).transform(x == 1 ? t : min(1.0, t * x)) ??
        Colors.transparent;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final currentExtent = max(minExtent, maxExtent - shrinkOffset);
    // 0.0 -> Expanded
    // 1.0 -> Collapsed
    double t = clampDouble(1.0 - (currentExtent - minExtent) / deltaExtent, 0, 1);
    CollapsingNotification(t).dispatch(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final List<Widget> children = <Widget>[];
            final splashColoredBox = ColoredBox(color: transformColor(null, Colors.white, t, 3));

            double imgBgrHeight = maxExtent;

            // Background image
            if (constraints.maxHeight > imgBgrHeight) imgBgrHeight = constraints.maxHeight;
            children
              ..add(Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: imgBgrHeight - deltaExtent / 2,
                child: imgBgr,
              ))

              // Splash transform color bottom
              ..add(Positioned(
                bottom: 0,
                width: constraints.maxWidth,
                height: deltaExtent,
                child: splashColoredBox,
              ));

            // Card
            const double cardPadding = 8;
            const double cardMarginHorizontal = 16;
            children
              ..add(
                Positioned(
                    left: cardMarginHorizontal,
                    right: cardMarginHorizontal,
                    bottom: 0,
                    height: deltaExtent,
                    child: Container()
                    // ActionAndOverviewInfoCard(
                    //   contentPadding: const EdgeInsets.all(cardPadding),
                    //   borderRadius: BorderRadius.circular(transform(12, 0, t, 2)),
                    // ),
                    ),
              )

              // Background image Clipped
              ..add(Positioned(
                top: 0,
                height: imgBgrHeight - deltaExtent / 2,
                width: constraints.maxWidth,
                child: ClipRect(
                  clipper: RectClipper(minExtent),
                  child: imgBgr,
                ),
              ))

              // Splash transform color top
              ..add(Positioned(
                top: 0,
                height: minExtent,
                width: constraints.maxWidth,
                child: splashColoredBox,
              ));

            // App bar
            const appBarPadding = SizedBox(width: 8);
            final appBarContentWidth = constraints.maxWidth - (appBarPadding.width! * 2);
            const totalIconImgButtonSize = IconImgButton.tapTargetSize * 7;
            final appBarSpace = SizedBox(width: (appBarContentWidth - totalIconImgButtonSize) / 6);

            //App bar fixed position
            Color iconBgrColor = transformColor(Colors.black54, null, t, 4);
            children.add(Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                height: minExtent,
                color: transformColor(null, const Color(0xFFFDA758).withOpacity(0.2), t, 2),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      appBarPadding,
                      appBarSpace,
                      const Spacer(),
                      appBarSpace,
                      appBarSpace,
                      // IconImgButton(
                      //   'chat_comment.webp',
                      //   backgroundColor: iconBgrColor,
                      // ),
                      appBarPadding,
                    ],
                  ),
                ),
              ),
            ));

            // App bar transform position
            iconBgrColor = transformColor(const Color(0xff395241), null, t, 2);
            final iconSize = transform(44, 32, t, 2);
            final iconPadding = transform(8, 4, t, 2);
            final double cardWidth = constraints.maxWidth - (cardMarginHorizontal * 2);
            final cardSpace = (cardWidth - (IconImgButton.tapTargetSize * 4)) / 5;

            children.add(
              Positioned(
                left: transform(
                  cardSpace + cardPadding,
                  appBarPadding.width! + IconImgButton.tapTargetSize + appBarSpace.width!,
                  t,
                  2,
                ),
                right: transform(
                  cardSpace + cardPadding,
                  appBarPadding.width! + IconImgButton.tapTargetSize * 2 + appBarSpace.width! * 2,
                  t,
                  2,
                ),
                top: constraints.maxHeight > maxExtent
                    ? null
                    : transform(
                        minExtent + cardPadding, minExtent - IconImgButton.tapTargetSize - 4, t, 2),
                bottom: constraints.maxHeight < maxExtent
                    ? null
                    : deltaExtent - IconImgButton.tapTargetSize - cardPadding,
                child: Container(),
              ),
            );

            return Stack(children: children);
          },
        ),
        // Positioned(
        //   top: minExtent,
        //   left: 0,
        //   right: 0,
        //   child: FloatingBalanceBar(isShowWhen: t == 1),
        // ),
      ],
    );
  }
}
