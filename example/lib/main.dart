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
      _CustomDotsIndicatorExampleState();
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
                  ),
                  const Divider(),
                  const Text("withLabel default"),
                  CustomDotsIndicator.withLabel(
                    listLength: itemCount,
                    controller: _scrollController,
                    dotsCount: 3,
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
