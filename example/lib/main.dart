import 'package:custom_dots_indicator/custom_dots_indicator.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: CustomDotsIndicatorExample(),
    ),
  );
}

class CustomDotsIndicatorExample extends StatefulWidget {
  const CustomDotsIndicatorExample({super.key});

  @override
  State<CustomDotsIndicatorExample> createState() =>
      // _CustomDotsIndicatorExampleState();
      _TabCustomDotsExampleState();
}

class _CustomDotsIndicatorExampleState
    extends State<CustomDotsIndicatorExample> {
  int itemCount = 20;
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Text(
          "+ 10",
        ),
        onPressed: () => setState(() {
          itemCount += 10;
        }),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: itemCount,
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Container(
                  width: itemWidth,
                  height: 60,
                  margin: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xff111151 + index * 10 + index * 1000),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text("Item $index",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Divider(),
                  const Text("Default "),
                  CustomDotsIndicator(
                    listLength: itemCount,
                    controller: _scrollController,
                    dotsCount: itemCount ~/ 2,
                    activeDotRadius: 8,
                  ),
                  const Divider(),
                  const Text("withLabel default"),
                  CustomDotsIndicator.withLabel(
                    listLength: itemCount,
                    controller: _scrollController,
                    dotsCount: 3,
                    customDotsTransition: (child, animation) => AnimatedOpacity(
                      duration: Duration.zero,
                      opacity: animation.value,
                      child: child,
                    ),
                  ),
                  const Text("withLabel selectedLabelBuilder"),
                  CustomDotsIndicator.withLabel(
                    listLength: itemCount,
                    controller: _scrollController,
                    dotsCount: 4,
                    inactiveDotRadius: 6,
                    selectedLabelBuilder: (currentIndex, dotIndex) => Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff112151),
                      ),
                      child: Text(
                        dotIndex.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    animationDuration: const Duration(milliseconds: 200),
                    customDotsTransition: (child, animation) => Transform.scale(
                      scaleY: animation.value,
                      child: child,
                    ),
                  ),
                  const Divider(),
                  const Text("custom"),
                  CustomDotsIndicator.custom(
                    listLength: itemCount,
                    controller: _scrollController,
                    dotsCount: 5,
                    dotsDistance: 4,
                    selectedLabelBuilder: (currentIndex, dotIndex) => Icon(
                      Icons.star,
                      size: 32,
                      color: Color(0xff333444 + 20000 * currentIndex),
                    ),
                    unselectedDotBuilder: (currentIndex, dotIndex) => Icon(
                      Icons.star_border,
                      size: 16,
                      color: Color(0xff337282 + 9000 * dotIndex),
                    ),
                  ),
                ]
                    .map((e) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: e,
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TabCustomDotsExampleState extends State<CustomDotsIndicatorExample>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int tabCount = 10;

  @override
  void initState() {
    _tabController = TabController(length: tabCount, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (int i = 0; i < tabCount; i++)
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xff000000 + i * 5000),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Item ${i + 1}",
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomDotsIndicator.withTabs(
              tabController: _tabController,
            ),
            const SizedBox(height: 10),
            CustomDotsIndicator.withTabs(
              tabController: _tabController,
              dotsCount: 7,
              showLabel: true,
              selectedLabelBuilder: (currentIndex, dotIndex) => Icon(
                Icons.color_lens,
                color: Color(0xff111111 - 200 * currentIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
