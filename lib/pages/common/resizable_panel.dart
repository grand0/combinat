import 'dart:ui';

import 'package:flutter/material.dart';

class ResizablePanel extends StatefulWidget {
  const ResizablePanel({
    super.key,
    this.initialWidth = 0,
    this.minWidth = 0,
    this.maxWidth = 0,
    this.child,
    this.show = true,
  });

  final double initialWidth;
  final double minWidth;
  final double maxWidth;
  final Widget? child;
  final bool show;

  @override
  State<ResizablePanel> createState() => _ResizablePanelState();
}

class _ResizablePanelState extends State<ResizablePanel> {
  late double width;
  bool hoveringDragIndicator = false;
  bool dragging = false;

  @override
  void initState() {
    super.initState();
    width = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return widget.show ? Stack(
      children: [
        Material(
          elevation: 2.0,
          child: SizedBox(
            width: width,
            height: double.infinity,
            child: widget.child,
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          opaque: false,
          onEnter: (_) {
            setState(() {
              hoveringDragIndicator = true;
            });
          },
          onExit: (_) {
            setState(() {
              hoveringDragIndicator = false;
            });
          },
          child: GestureDetector(
            onHorizontalDragDown: (_) {
              setState(() {
                dragging = true;
              });
            },
            onHorizontalDragCancel: () {
              setState(() {
                dragging = false;
              });
            },
            onHorizontalDragEnd: (_) {
              setState(() {
                dragging = false;
              });
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                width = clampDouble(width - details.delta.dx, widget.minWidth,
                    widget.maxWidth);
              });
            },
            child: Container(
              width: 8.0,
              height: double.infinity,
              color: hoveringDragIndicator || dragging
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ),
      ],
    ) : const SizedBox();
  }
}
