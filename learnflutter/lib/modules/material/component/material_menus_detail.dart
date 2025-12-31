import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MaterialMenuDetailScreen extends StatefulWidget {
  const MaterialMenuDetailScreen({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialMenuDetailScreen> createState() => _MaterialMenuDetailScreenState();
}

void launchUrlExternally(String url) {
  launchUrlString(url, mode: LaunchMode.externalApplication);
}

class _MaterialMenuDetailScreenState extends State<MaterialMenuDetailScreen>
    with ComponentMaterialDetail {
  bool light = true;
  var _navigationIndex = 0;
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
    return PieCanvas(
      theme: const PieTheme(
        rightClickShowsMenu: true,
        tooltipTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: BaseLoading(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _navigationIndex,
          onTap: (index) => setState(() => _navigationIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.add_ic_call_outlined),
              label: 'Styling',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_ic_call_outlined),
              label: 'ListView',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_ic_call_outlined),
              label: 'About',
            ),
          ],
        ),
        child: IndexedStack(
          index: _navigationIndex,
          children: const [
            StylingPage(),
            ListViewPage(),
            AboutPage(),
          ],
        ),
      ),
    );
  }
}

//* different styles *//
class StylingPage extends StatelessWidget {
  const StylingPage({super.key});

  static const double spacing = 20;

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: const PieTheme(
        delayDuration: Duration.zero,
        tooltipTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Builder(
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(spacing),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: PieMenu(
                            actions: [
                              PieAction(
                                tooltip: const Text('Play'),
                                onSelect: () => context.showSnackBar('Play'),

                                /// Optical correction
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.play_arrow),
                                ),
                              ),
                              PieAction(
                                tooltip: const Text('Like'),
                                onSelect: () => context.showSnackBar('Like'),
                                child: const Icon(
                                  Icons.abc,
                                ),
                              ),
                              PieAction(
                                tooltip: const Text('Share'),
                                onSelect: () => context.showSnackBar('Share'),
                                child: const Icon(Icons.share),
                              ),
                            ],
                            child: _buildCard(
                              color: Colors.orangeAccent,
                              iconData: Icons.sos_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing),
                        Expanded(
                          child: PieMenu(
                            theme: PieTheme.of(context).copyWith(
                              buttonTheme: const PieButtonTheme(
                                backgroundColor: Colors.red,
                                iconColor: Colors.white,
                              ),
                              buttonThemeHovered: const PieButtonTheme(
                                backgroundColor: Colors.orangeAccent,
                                iconColor: Colors.black,
                              ),
                              brightness: Brightness.dark,
                            ),
                            actions: [
                              PieAction.builder(
                                tooltip: const Text('how'),
                                onSelect: () => context.showSnackBar('1'),
                                builder: (hovered) {
                                  return _buildTextButton('1', hovered);
                                },
                              ),
                              PieAction.builder(
                                tooltip: const Text('cool'),
                                onSelect: () => context.showSnackBar('2'),
                                builder: (hovered) {
                                  return _buildTextButton('2', hovered);
                                },
                              ),
                              PieAction.builder(
                                tooltip: const Text('is'),
                                onSelect: () => context.showSnackBar('3'),
                                builder: (hovered) {
                                  return _buildTextButton('3', hovered);
                                },
                              ),
                              PieAction.builder(
                                tooltip: const Text('this?!'),
                                onSelect: () => context.showSnackBar('Pretty cool :)'),
                                builder: (hovered) {
                                  return _buildTextButton('4', hovered);
                                },
                              ),
                            ],
                            child: _buildCard(
                              color: Colors.deepPurple,
                              iconData: Icons.mood,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: spacing),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: PieMenu(
                            theme: PieTheme.of(context).copyWith(
                              tooltipTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              overlayColor: Colors.transparent,
                              pointerSize: 40,
                              pointerDecoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              buttonTheme: const PieButtonTheme(
                                backgroundColor: Colors.black,
                                iconColor: Colors.white,
                              ),
                              buttonThemeHovered: const PieButtonTheme(
                                backgroundColor: Colors.white,
                                iconColor: Colors.black,
                              ),
                              buttonSize: 84,
                              leftClickShowsMenu: false,
                              rightClickShowsMenu: true,
                            ),
                            onPressedWithDevice: (kind) {
                              HapticFeedback.heavyImpact();
                              if (kind == PointerDeviceKind.mouse) {
                                context.showSnackBar(
                                  'Right click to show the menu',
                                );
                              }
                            },
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                            },
                            onToggle: (menuOpen) {
                              HapticFeedback.heavyImpact();
                            },
                            actions: [
                              PieAction(
                                tooltip: const Text('Available on pub.dev'),
                                onSelect: () {
                                  launchUrlExternally(
                                    'https://pub.dev/packages/pie_menu',
                                  );
                                },
                                child: const Icon(Icons.open_in_browser),
                              ),
                              PieAction(
                                tooltip: const Text('Highly customizable'),
                                onSelect: () {
                                  launchUrlExternally(
                                    'https://pub.dev/packages/pie_menu',
                                  );
                                },

                                /// Custom background color
                                buttonTheme: PieButtonTheme(
                                  backgroundColor: Colors.black.withOpacity(0.7),
                                  iconColor: Colors.white,
                                ),
                                child: const Icon(Icons.palette),
                              ),
                              PieAction(
                                tooltip: const Text('Now with right click support!'),
                                buttonTheme: PieButtonTheme(
                                  backgroundColor: Colors.black.withOpacity(0.5),
                                  iconColor: Colors.white,
                                ),
                                onSelect: () {
                                  launchUrlExternally(
                                    'https://pub.dev/packages/pie_menu',
                                  );
                                },
                                child: const Icon(
                                  Icons.mouse,
                                ),
                              ),
                            ],
                            child: _buildCard(
                              color: Colors.teal,
                              iconData: Icons.hearing,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    Color? color,
    required IconData iconData,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, bool hovered) {
    return Text(
      text,
      style: TextStyle(
        color: hovered ? Colors.black : Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

//* list view example *//
class ListViewPage extends StatelessWidget {
  const ListViewPage({super.key});

  static const spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(
        top: spacing,
        bottom: spacing,
        left: MediaQuery.of(context).padding.left + spacing,
        right: MediaQuery.of(context).padding.right + spacing,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: 16,
      separatorBuilder: (context, index) => const SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return SizedBox(
          height: 200,
          child: PieMenu(
            onPressed: () {
              context.showSnackBar(
                '#$index — Long press or right click to show the menu',
              );
            },
            actions: [
              PieAction(
                tooltip: const Text('Like'),
                onSelect: () => context.showSnackBar('Like #$index'),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    print('object');
                  },
                  label: Text('+'),
                  icon: Icon(Icons.heart_broken),
                ),
              ),
              PieAction(
                tooltip: const Text('Comment'),
                onSelect: () => context.showSnackBar('Comment #$index'),
                child: const Icon(Icons.comment),
              ),
              PieAction(
                tooltip: const Text('Save'),
                onSelect: () => context.showSnackBar('Save #$index'),
                child: const Icon(Icons.bookmark),
              ),
              PieAction(
                tooltip: const Text('Share'),
                onSelect: () => context.showSnackBar('Share #$index'),
                child: const Icon(Icons.share),
              ),
            ],
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '#$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 64,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

//* about the developer *//
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: PieTheme(
        delayDuration: Duration.zero,
        tooltipTextStyle: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        tooltipUseFittedBox: true,
        buttonTheme: const PieButtonTheme(
          backgroundColor: Colors.black,
          iconColor: Colors.white,
        ),
        buttonThemeHovered: PieButtonTheme(
          backgroundColor: Colors.lime[200],
          iconColor: Colors.black,
        ),
        overlayColor: Colors.blue[200]?.withOpacity(0.7),
        rightClickShowsMenu: true,
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlutterLogo(size: 100),
                  SizedBox(width: 16),
                  Text(
                    '🥧',
                    style: TextStyle(
                      fontSize: 100,
                      height: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: PieMenu(
                  actions: [
                    PieAction(
                      tooltip: const Text('github/rasitayaz'),
                      onSelect: () {
                        launchUrlExternally('https://github.com/rasitayaz');
                      },
                      child: const Icon(Icons.gite),
                    ),
                    PieAction(
                      tooltip: const Text('linkedin/rasitayaz'),
                      onSelect: () {
                        launchUrlExternally(
                          'https://linkedin.com/in/rasitayaz/',
                        );
                      },
                      child: const Icon(Icons.linked_camera),
                    ),
                    PieAction(
                      tooltip: const Text('mrasitayaz@gmail.com'),
                      onSelect: () {
                        launchUrlExternally('mailto:mrasitayaz@gmail.com');
                      },
                      child: const Icon(Icons.event_note_rounded),
                    ),
                    PieAction(
                      tooltip: const Text('buy me a coffee'),
                      onSelect: () {
                        launchUrlExternally(
                          'https://buymeacoffee.com/rasitayaz',
                        );
                      },
                      child: const Icon(Icons.mouse),
                    ),
                  ],
                  child: FittedBox(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'created by',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                          Text(
                            'Raşit Ayaz',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
