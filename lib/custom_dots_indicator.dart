library custom_dots_indicator;

import 'package:flutter/material.dart';

class CustomDotsIndicator extends StatefulWidget {
  /// Length of the list for which the [CustomDotsIndicator]
  /// is to be used.
  final int listLength;

  /// The [ScrollController] provided to the list for which
  /// the [CustomDotsIndicator] is to be used.
  final ScrollController controller;

  /// Amount of dots to use for the indicator. Defaults to 3.
  final int dotsCount;

  /// Amount of space in `px` between two dots. Defaults to 8 px.
  final double dotsDistance;

  /// Radius of the Dot to use for the active dot
  final double activeDotRadius;

  /// Radius of the Dot to use for the inactive dots
  final double inactiveDotRadius;

  /// Color of the Dot to use for the active dot
  final Color? activeDotColor;

  /// Color of the Dot to use for the inactive dots
  final Color? inactiveDotColor;

  /// [TextStyle] to use to draw text in the default label
  final TextStyle? labelStyle;

  /// Will override the default label widget when a
  /// non-null value is returned.
  ///
  /// Note: [labelStyle], [activeDotRadius] and [activeDotColor]
  /// are ignored.
  ///
  /// @param currentIndex is the tile index current calculated to be visible.
  ///
  /// @param dotIndex is the index of the dot
  final Widget Function(int currentIndex, int dotIndex)? selectedLabelBuilder;

  /// Allows for a complete replacement of the inactive dot widget
  /// for a widget of your choice.
  ///
  /// @param currentIndex is the tile index current calculated to be visible.
  ///
  /// @param dotIndex is the index of the dot
  final Widget Function(int currentIndex, int dotIndex)? unselectedDotBuilder;

  /// Allows for providing custom spacing between the dots.
  /// Starts with [dotIndex] = 0
  final double Function(int dotIndex)? customDotSpaceBuilder;

  /// Duration for which your [customDotsTransition] lasts
  final Duration animationDuration;

  /// Duration for which your [customDotsTransition] reverses
  final Duration reverseAnimationDuration;

  /// Specify your own transition if needed
  ///
  /// Note: Does not apply when using [CustomDotsIndicator.custom]
  final CustomDotsTransition? customDotsTransition;

  final bool _withLabel;

  /// Creates the default Dots Indicator
  ///
  /// If you need a label, check out [CustomDotsIndicator.withLabel]
  ///
  /// ![default](../screenshots/default.png)
  const CustomDotsIndicator({
    super.key,
    required this.listLength,
    required this.controller,
    this.dotsCount = 3,
    this.dotsDistance = 8,
    this.activeDotRadius = 4,
    this.inactiveDotRadius = 4,
    this.activeDotColor,
    this.inactiveDotColor,
    this.animationDuration = const Duration(milliseconds: 200),
    this.reverseAnimationDuration = Duration.zero,
    this.customDotsTransition,
    this.customDotSpaceBuilder,
  })  : assert(dotsCount <= listLength),
        _withLabel = false,
        labelStyle = null,
        selectedLabelBuilder = null,
        unselectedDotBuilder = null;

  /// Creates the Dots indicator with the default label widget. Also
  /// allows for customising the label widget through the
  /// implementation of [selectedLabelBuilder].
  ///
  /// ![default_label](../screenshots/default_label.png)
  ///
  /// If you also need to customise the inactive dots, check
  /// out [CustomDotsIndicator.custom]
  const CustomDotsIndicator.withLabel({
    super.key,
    required this.listLength,
    required this.controller,
    this.dotsCount = 3,
    this.dotsDistance = 16,
    this.activeDotRadius = 4,
    this.inactiveDotRadius = 4,
    this.activeDotColor,
    this.inactiveDotColor,
    this.labelStyle,
    this.selectedLabelBuilder,
    this.animationDuration = const Duration(milliseconds: 200),
    this.reverseAnimationDuration = Duration.zero,
    this.customDotsTransition,
    this.customDotSpaceBuilder,
  })  : assert(dotsCount <= listLength),
        _withLabel = true,
        unselectedDotBuilder = null;

  /// Allows for complete customisation of active and inactive dots.
  ///
  /// Uses the default label widget when custom not defined via the
  /// use of [selectedLabelBuilder].
  ///
  /// Uses the default inactive dot when custom not defined via the
  /// use of [unselectedDotBuilder]
  const CustomDotsIndicator.custom({
    super.key,
    required this.listLength,
    required this.controller,
    this.dotsCount = 3,
    this.dotsDistance = 16,
    this.activeDotRadius = 4,
    this.inactiveDotRadius = 4,
    this.activeDotColor,
    this.inactiveDotColor,
    this.selectedLabelBuilder,
    this.unselectedDotBuilder,
    this.animationDuration = const Duration(milliseconds: 200),
    this.reverseAnimationDuration = Duration.zero,
    this.customDotsTransition,
    this.customDotSpaceBuilder,
  })  : assert(dotsCount <= listLength),
        _withLabel = true,
        labelStyle = null;

  @override
  State<CustomDotsIndicator> createState() => _CustomDotsIndicatorState();
}

class _CustomDotsIndicatorState extends State<CustomDotsIndicator> {
  bool isScrollControllerAttached = false;
  final TextStyle _defaultLabelStyle = const TextStyle(
    fontSize: 10,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onListen);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onListen);
    super.dispose();
  }

  void onListen() {
    setState(() {
      isScrollControllerAttached = widget.controller.hasClients;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> rowChildren = [];
    if (isScrollControllerAttached) {
      final currentScrollIndex = widget.controller.offset;
      double totalScrollExtent = widget.controller.position.maxScrollExtent;
      if (totalScrollExtent == 0) {
        /// `maxScrollExtent` may be `0` if there isn't any element beyond the
        /// scroll viewport. Giving it a small number, i.e., making it `1`
        /// helps by avoiding the Null conditions
        totalScrollExtent++;
      }
      final itemExtent = totalScrollExtent / (widget.listLength);
      final currentIndex = (currentScrollIndex ~/ itemExtent) + 1;

      /// [range] helps determine the min and max index in which
      /// the dot must be set to active
      int range = widget.listLength ~/ widget.dotsCount;
      for (int dotIndex = 1; dotIndex <= widget.dotsCount; dotIndex++) {
        int rangeStart = 1 + range * (dotIndex - 1);
        int rangeEnd = (dotIndex == widget.dotsCount)
            ? widget.listLength
            : dotIndex * range;
        if (currentIndex > widget.listLength) {
          /// check whether the current index is for the widget at the list end
          /// which will very likely be the fetch button or the shimmer
          rowChildren.add(
            _IndicatorDot(
              currentIndex: currentIndex - 1,
              dotIndex: dotIndex,
              total: widget.listLength,
              rangeStart: rangeStart,
              rangeEnd: rangeEnd,
              labelForActiveDot: widget._withLabel,
              labelStyle: widget.labelStyle ?? _defaultLabelStyle,
              activeDotRadius: widget.activeDotRadius,
              inactiveDotRadius: widget.inactiveDotRadius,
              activeDotColor:
                  widget.activeDotColor ?? Theme.of(context).primaryColor,
              inactiveDotColor: widget.inactiveDotColor ??
                  Theme.of(context).unselectedWidgetColor,
              selectedLabelBuilder: widget.selectedLabelBuilder,
              unselectedDotBuilder: widget.unselectedDotBuilder,
              animationDuration: widget.animationDuration,
              reverseAnimationDuration: widget.reverseAnimationDuration,
              customDotsTransition: widget.customDotsTransition,
            ),
          );
          continue;
        }
        rowChildren.add(
          _IndicatorDot(
            currentIndex: currentIndex,
            dotIndex: dotIndex,
            total: widget.listLength,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd,
            labelForActiveDot: widget._withLabel,
            labelStyle: widget.labelStyle ?? _defaultLabelStyle,
            activeDotRadius: widget.activeDotRadius,
            inactiveDotRadius: widget.inactiveDotRadius,
            activeDotColor:
                widget.activeDotColor ?? Theme.of(context).primaryColor,
            inactiveDotColor: widget.inactiveDotColor ??
                Theme.of(context).unselectedWidgetColor,
            selectedLabelBuilder: widget.selectedLabelBuilder,
            unselectedDotBuilder: widget.unselectedDotBuilder,
            animationDuration: widget.animationDuration,
            reverseAnimationDuration: widget.reverseAnimationDuration,
            customDotsTransition: widget.customDotsTransition,
          ),
        );
      }
    } else {
      rowChildren.add(
        _IndicatorDot(
          currentIndex: 1,
          dotIndex: 1,
          total: widget.listLength,
          rangeStart: 1,
          rangeEnd: 1,
          labelForActiveDot: widget._withLabel,
          labelStyle: widget.labelStyle ?? _defaultLabelStyle,
          activeDotRadius: widget.activeDotRadius,
          inactiveDotRadius: widget.inactiveDotRadius,
          activeDotColor:
              widget.activeDotColor ?? Theme.of(context).primaryColor,
          inactiveDotColor: widget.inactiveDotColor ??
              Theme.of(context).unselectedWidgetColor,
          selectedLabelBuilder: widget.selectedLabelBuilder,
          unselectedDotBuilder: widget.unselectedDotBuilder,
          animationDuration: widget.animationDuration,
          reverseAnimationDuration: widget.reverseAnimationDuration,
          customDotsTransition: null, // Needs null to draw widget on boot up
        ),
      );
      for (int dotIndex = 2; dotIndex <= widget.dotsCount; dotIndex++) {
        rowChildren.add(
          _IndicatorDot(
            currentIndex: 1,
            dotIndex: dotIndex,
            total: widget.listLength,
            rangeStart: 2,
            rangeEnd: 2,
            labelForActiveDot: widget._withLabel,
            labelStyle: widget.labelStyle ?? _defaultLabelStyle,
            activeDotRadius: widget.activeDotRadius,
            inactiveDotRadius: widget.inactiveDotRadius,
            activeDotColor:
                widget.activeDotColor ?? Theme.of(context).primaryColor,
            inactiveDotColor: widget.inactiveDotColor ??
                Theme.of(context).unselectedWidgetColor,
            selectedLabelBuilder: widget.selectedLabelBuilder,
            unselectedDotBuilder: widget.unselectedDotBuilder,
            animationDuration: widget.animationDuration,
            reverseAnimationDuration: widget.reverseAnimationDuration,
            customDotsTransition: null, // Needs null to draw widget on boot up
          ),
        );
      }
    }

    /// to provide distances between dots
    final List<Widget> transformedRow = [];
    for (int index = 0; index < rowChildren.length - 1; index++) {
      transformedRow.add(rowChildren.elementAt(index));
      if (widget.customDotSpaceBuilder != null) {
        transformedRow.add(
          SizedBox(
            width: widget.customDotSpaceBuilder!(index),
          ),
        );
      } else {
        transformedRow.add(
          SizedBox(
            width: widget.dotsDistance,
          ),
        );
      }
    }
    transformedRow.add(rowChildren.last);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: transformedRow,
    );
  }
}

typedef CustomDotsTransition = Widget Function(
    Widget child, Animation<double> animation);

class _IndicatorDot extends StatelessWidget {
  final int currentIndex;
  final int dotIndex;
  final int total;
  final int rangeStart, rangeEnd;
  final double activeDotRadius, inactiveDotRadius;
  final bool labelForActiveDot;
  final Color activeDotColor, inactiveDotColor;
  final TextStyle labelStyle;
  final Widget Function(int currentIndex, int dotIndex)? selectedLabelBuilder;
  final Widget Function(int currentIndex, int dotIndex)? unselectedDotBuilder;
  final Duration animationDuration;
  final Duration reverseAnimationDuration;
  final CustomDotsTransition? customDotsTransition;

  const _IndicatorDot({
    required this.currentIndex,
    required this.dotIndex,
    required this.total,
    required this.rangeStart,
    required this.rangeEnd,
    required this.activeDotRadius,
    required this.inactiveDotRadius,
    required this.labelForActiveDot,
    required this.labelStyle,
    required this.selectedLabelBuilder,
    required this.unselectedDotBuilder,
    required this.activeDotColor,
    required this.inactiveDotColor,
    required this.animationDuration,
    required this.reverseAnimationDuration,
    required this.customDotsTransition,
  });

  @override
  Widget build(BuildContext context) {
    final isInRange = currentIndex >= rangeStart && currentIndex <= rangeEnd;
    final dot = isInRange
        ? labelForActiveDot
            ? selectedLabelBuilder != null
                ? selectedLabelBuilder!(currentIndex, dotIndex)
                : __InfoDot(
                    currentIndex: currentIndex,
                    totalCount: total,
                    textStyle: labelStyle,
                  )
            : __ActiveDot(
                dotRadius: activeDotRadius,
                activeDotColor: activeDotColor,
              )
        : unselectedDotBuilder != null
            ? unselectedDotBuilder!(currentIndex, dotIndex)
            : __EmptyDot(
                dotRadius: inactiveDotRadius,
                inactiveDotColor: inactiveDotColor,
              );
    return customDotsTransition == null
        ? dot
        : AnimatedSwitcher(
            duration: animationDuration,
            reverseDuration: reverseAnimationDuration,
            transitionBuilder: customDotsTransition!,
            child: dot,
          );
  }
}

class __InfoDot extends StatelessWidget {
  final int currentIndex, totalCount;
  final TextStyle? textStyle;

  const __InfoDot({
    required this.currentIndex,
    required this.totalCount,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "$currentIndex/$totalCount",
        style: textStyle,
      ),
    );
  }
}

class __EmptyDot extends StatelessWidget {
  final double dotRadius;
  final Color inactiveDotColor;
  const __EmptyDot({
    required this.dotRadius,
    required this.inactiveDotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: dotRadius * 2,
      width: dotRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: inactiveDotColor,
      ),
    );
  }
}

class __ActiveDot extends StatelessWidget {
  final double dotRadius;
  final Color activeDotColor;
  const __ActiveDot({
    required this.dotRadius,
    required this.activeDotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: dotRadius * 2,
      width: dotRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: activeDotColor,
      ),
    );
  }
}
