import 'package:flutter/material.dart';

class CollapsingHeaderPage extends StatelessWidget {
  const CollapsingHeaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double top = constraints.biggest.height;
                final bool isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;

                return FlexibleSpaceBar(
                  centerTitle: true,
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isCollapsed ? 1.0 : 0.0,
                    child: const Text('Profile Name'),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1503264116251-35a269479413?auto=format&fit=crop&w=1000&q=80',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(16),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isCollapsed ? 0.0 : 1.0,
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 32,
                                backgroundImage: NetworkImage(
                                  'https://avatars.githubusercontent.com/u/9919?s=200&v=4',
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Profile Name',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text('Item #$index')),
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
