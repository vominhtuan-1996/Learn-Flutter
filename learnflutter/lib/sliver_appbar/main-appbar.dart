import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/https/MBMHttpHelper.dart';
import 'package:learnflutter/custom_widget/smart_refresh/lib/pull_to_refresh.dart';
import 'package:learnflutter/helpper/Bitmap_Utils.dart';
import 'package:learnflutter/helpper/define_constraint.dart';
import 'package:learnflutter/modules/menu/model/model_menu.dart';
import 'package:learnflutter/modules/shimmer/widget/shimmer_loading_widget.dart';
import 'package:learnflutter/sliver_appbar/action_and_balance_card.dart';
import 'package:learnflutter/sliver_appbar/balance_bar.dart';
import 'package:learnflutter/sliver_appbar/icon_img_button.dart';
import 'package:learnflutter/sliver_appbar/notification_handler.dart';
import 'package:learnflutter/sliver_appbar/search_area.dart';
import 'package:learnflutter/src/app_colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SliverAppMenu extends StatefulWidget {
  const SliverAppMenu({super.key});

  @override
  State<SliverAppMenu> createState() => _SliverAppMenuState();
}

class _SliverAppMenuState extends State<SliverAppMenu> {
  bool isLoading = true;
  late double minExtent;
  late double maxExtent;
  final ScrollController scrollController = ScrollController();
  ItemScrollController _controllerScrollView = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  List categories = [];
  List menus = [];
  @override
  void initState() {
    getListCategories();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void getListCategories() {
    getHttp().then((value) => {
          categories = value.categories,
          menus = value.menus,
          setState(() {
            isLoading = false;
          }),
        });
  }

  int caculatorHeightWithCount(int count) {
    return count % 4 != 0 ? (count / 4).toInt() + 1 : (count / 4).toInt();
  }

  GestureDetector childMenusCell(ChildMenusModel data, bool isRecentlyUsed) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              height: 50,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFDA758).withOpacity(0.2)),
              child: Center(
                child: Image.asset(loadImageWithImageName(data.iconChildMenu, TypeImage.png)),
              )),
          SizedBox(
            height: 6,
          ),
          Container(
              child: Center(
            child: Text(data.titleChildMenu, textAlign: TextAlign.center, style: textStyleManrope(Color(0xFF795675), 12, FontWeight.normal)),
          ))
        ],
      ),
    );
  }

  Widget initUIMenus() {
    return ScrollablePositionedList.builder(
      itemScrollController: _controllerScrollView,
      itemPositionsListener: itemPositionsListener,
      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
      scrollDirection: Axis.vertical,
      itemCount: menus.length,
      reverse: false,
      itemBuilder: (BuildContext ctxt, int index) {
        ModelMenusItem item = menus[index];
        return Container(
            alignment: Alignment.center,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              Text(item.parentMenuTitle, textAlign: TextAlign.left, style: textStyleManrope(Color(0xFF795675), 14, FontWeight.w600)),
              SizedBox(height: 10),
              Container(
                height: item.childMenus.length / 4 > 1 ? caculatorHeightWithCount(item.childMenus.length) * 110 : 110,
                child: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 5 / 6, crossAxisSpacing: 7),
                  itemBuilder: (BuildContext ctxt, int index) {
                    ChildMenusModel childMenusModel = item.childMenus[index];
                    return childMenusCell(childMenusModel, false);
                  },
                  itemCount: item.childMenus.length,
                ),
              ),
            ]));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    minExtent = kToolbarHeight + MediaQuery.paddingOf(context).top;
    maxExtent = Platform.isAndroid ? 216 : 256;
    maxExtent = maxExtent - 40;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: AppBarScrollHandler(
        minExtent: minExtent,
        maxExtent: maxExtent,
        controller: scrollController,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverAppBarDelegate(
                minExtent: minExtent,
                maxExtent: maxExtent,
              ),
            ),
            SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 5 / 6, crossAxisSpacing: 7),
              itemBuilder: (BuildContext ctxt, int index) {
                // ChildMenusModel childMenusModel = item.childMenus[index];
                return Text('childMenusModel.titleChildMenu', textAlign: TextAlign.center, style: textStyleManrope(Color(0xFF795675), 12, FontWeight.normal));
              },
              itemCount: 50,
            ),

            // SliverList.list(
            //   children: List<Widget>.generate(
            //     20,
            //     (int index) => Card(
            //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            //       child: Container(
            //         alignment: Alignment.center,
            //         padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            //         child: Text(index.toString()),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

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
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => OverScrollHeaderStretchConfiguration();

  double get deltaExtent => maxExtent - minExtent;

  static const imgBgr = Image(image: AssetImage('assets/images/slier_appbar_bgr.webp'), fit: BoxFit.cover);

  double transform(double begin, double end, double t, [double x = 1]) {
    return Tween<double>(begin: begin, end: end).transform(x == 1 ? t : min(1.0, t * x));
  }

  Color transformColor(Color? begin, Color? end, double t, [double x = 1]) {
    return ColorTween(begin: begin, end: end).transform(x == 1 ? t : min(1.0, t * x)) ?? Colors.transparent;
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
                  child: ActionAndOverviewInfoCard(
                    contentPadding: const EdgeInsets.all(cardPadding),
                    borderRadius: BorderRadius.circular(transform(12, 0, t, 2)),
                  ),
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
                      SearchArea(
                        appBarContentWidth: appBarContentWidth,
                        appBarSpace: appBarSpace,
                        iconBgrColor: iconBgrColor,
                      ),
                      appBarSpace,
                      const Spacer(),
                      appBarSpace,

                      initUiNotification(context),
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

            children.add(Positioned(
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
              top: constraints.maxHeight > maxExtent ? null : transform(minExtent + cardPadding, minExtent - IconImgButton.tapTargetSize - 4, t, 2),
              bottom: constraints.maxHeight < maxExtent ? null : deltaExtent - IconImgButton.tapTargetSize - cardPadding,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    10,
                    (index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Container(
                            padding: EdgeInsets.all(8),
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.0), color: Color(0xFFFDA758)),
                            child: const Center(
                              child: Text(
                                'Nghiệm Thu',
                                textAlign: TextAlign.center,
                              ),
                            )),
                      );
                      // IconImgButton(
                      //   'momomain_money_in.webp',
                      //   size: iconSize,
                      //   padding: iconPadding,
                      //   backgroundRadius: 16,
                      //   backgroundColor: iconBgrColor,
                      // );
                    },
                  ),
                  //  [
                  //   IconImgButton(
                  //     'momomain_money_in.webp',
                  //     size: iconSize,
                  //     padding: iconPadding,
                  //     backgroundRadius: 16,
                  //     backgroundColor: iconBgrColor,
                  //   ),
                  //   IconImgButton(
                  //     'momomain_withdraw.webp',
                  //     size: iconSize,
                  //     padding: iconPadding,
                  //     backgroundRadius: 16,
                  //     backgroundColor: iconBgrColor,
                  //   ),
                  //   IconImgButton(
                  //     'navigation_qrcode.webp',
                  //     size: iconSize,
                  //     padding: iconPadding,
                  //     backgroundRadius: 16,
                  //     backgroundColor: iconBgrColor,
                  //   ),
                  //   IconImgButton(
                  //     'home_wallet_inactive.webp',
                  //     size: iconSize,
                  //     padding: iconPadding,
                  //     backgroundRadius: 16,
                  //     backgroundColor: iconBgrColor,
                  //   ),
                  // ],
                ),
              ),
            ));

            return Stack(children: children);
          },
        ),
        Positioned(
          top: minExtent,
          left: 0,
          right: 0,
          child: FloatingBalanceBar(isShowWhen: t == 1),
        ),
      ],
    );
  }

  GestureDetector initUiNotification(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          print('action notification');
          Uint8List bitmap = await BitmapUtils().generateImagePngAsBytes('action notification');
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              child: Image.memory(bitmap),
            ),
          );
        },
        child: Container(
            height: 48,
            width: 48,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(48.0 / 4), color: Colors.white),
            child: Center(
              child: Image.asset(loadImageWithImageName('ic_notification', TypeImage.png)),
            )));
  }
}

class FloatingBalanceBar extends StatelessWidget {
  const FloatingBalanceBar({
    super.key,
    required this.isShowWhen,
  });

  final bool isShowWhen;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: isShowWhen
          ? BalanceBar(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 8),
                    blurRadius: 20,
                    spreadRadius: -2,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class RectClipper extends CustomClipper<Rect> {
  final double maxHeight;

  RectClipper(this.maxHeight);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, maxHeight);
  }

  @override
  bool shouldReclip(RectClipper oldClipper) => oldClipper.maxHeight != maxHeight;
}
