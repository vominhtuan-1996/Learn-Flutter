import 'package:flutter/material.dart';
import 'package:learnflutter/component/balance_bar/balance_bar.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/main_balance.dart';
import 'package:learnflutter/src/lib/tab_controler/tab_container.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_string.dart';

class BalanceBarScreen extends StatefulWidget {
  const BalanceBarScreen({super.key});
  @override
  State<BalanceBarScreen> createState() => BalanceBarScreenState();
}

class BalanceBarScreenState extends State<BalanceBarScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> _getChildren1() {
    List<CreditCardData> cards = kCreditCards
        .map(
          (e) => CreditCardData.fromJson(e),
        )
        .toList();

    return cards.map((e) => CreditCard(data: e)).toList();
  }

  List<Widget> _getTabs1() {
    List<CreditCardData> cards = kCreditCards
        .map(
          (e) => CreditCardData.fromJson(e),
        )
        .toList();

    return cards
        .map(
          (e) => Text('*${e.number.substring(e.number.length - 4, e.number.length)}'),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      child: TabContainer(
        borderRadius: BorderRadius.circular(20),
        tabEdge: TabEdge.top,
        // tabExtent: 100,
        // tabMaxLength: 100,
        curve: Curves.decelerate,
        transitionBuilder: (child, animation) {
          animation = CurvedAnimation(curve: Curves.easeIn, parent: animation);
          return SlideTransition(
            position: Tween(
              begin: const Offset(0.2, 0.0),
              end: const Offset(0.0, 0.0),
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        color: context.colorScheme.primaryFixedDim,
        // colors: const <Color>[
        //   Colors.white,
        //   Color(0xffa275e3),
        //   Color(0xff9aebed),
        //   Color(0xfffa86be),
        //   Color(0xffa275e3),
        //   Color(0xff9aebed),
        //   Color(0xfffa86be),
        //   Color(0xffa275e3),
        //   Color(0xff9aebed),
        //   Color(0xff9aebed),
        // ],
        selectedTextStyle: context.text.bodyMedium?.copyWith(fontSize: 15.0),
        unselectedTextStyle: context.text.bodyMedium?.copyWith(fontSize: 13.0),
        tabs: List.generate(
          3,
          (index) {
            return Text(
              'Danh sách $index',
              style: context.text.bodyMedium,
            );
          },
        ),
        children: List.generate(3, (index) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                100,
                (index) {
                  return Container(
                    width: context.mediaQuery.size.width,
                    // color: Colors.primaries[index % Colors.primaries.length],
                    child: Text(
                      'Tab $index',
                      style: context.text.bodyMedium,
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
