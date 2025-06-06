import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class FoxyTable extends StatelessWidget {
  final List<FoxyTableRow>? body;
  final FoxyTableHeader header;

  const FoxyTable({super.key, this.body, required this.header});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final outline = colorScheme.outline;
    final borderSide = BorderSide(color: outline.withValues(alpha: 0.25));
    final boxDecoration = BoxDecoration(border: Border(bottom: borderSide));
    final defaultBody = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: Text('暂无数据')),
    );
    return Column(
      children: [
        Container(decoration: boxDecoration, child: header),
        if (body == null) defaultBody else ...body!,
      ],
    );
  }
}

class FoxyTableCell extends StatelessWidget {
  final double? width;
  final Widget? child;
  const FoxyTableCell({super.key, this.width, this.child});

  @override
  Widget build(BuildContext context) {
    const edgeInsets = EdgeInsets.symmetric(horizontal: 8, vertical: 16);
    var defaultTextStyle = DefaultTextStyle.merge(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: child ?? const SizedBox(),
    );
    final cell = Container(
      padding: edgeInsets,
      width: width,
      child: defaultTextStyle,
    );
    return Expanded(flex: width == null ? 1 : 0, child: cell);
  }
}

class FoxyTableHeader extends StatelessWidget {
  final List<FoxyTableCell> children;
  const FoxyTableHeader({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final outline = colorScheme.outline;
    final textStyle = TextStyle(color: outline, fontWeight: FontWeight.bold);
    final row = Row(children: children);
    return DefaultTextStyle.merge(style: textStyle, child: row);
  }
}

class FoxyTableRow extends StatefulWidget {
  final void Function(FoxyContextMenuOption)? onContextMenuTap;
  final void Function()? onDoubleTap;
  final List<FoxyTableCell> children;
  const FoxyTableRow({
    super.key,
    this.onContextMenuTap,
    this.onDoubleTap,
    required this.children,
  });

  @override
  State<FoxyTableRow> createState() => _FoxyTableRowState();
}

enum FoxyContextMenuOption { read, edit, duplicate, destroy }

class _FoxyTableRowState extends State<FoxyTableRow> {
  bool hovered = false;

  OverlayEntry? entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryContainer = colorScheme.primaryContainer;
    final outline = colorScheme.outline;
    final borderSide = BorderSide(color: outline.withValues(alpha: 0.25));
    final boxDecoration = BoxDecoration(
      border: Border(bottom: borderSide),
      color: hovered ? primaryContainer : null,
    );
    final row = Container(
      decoration: boxDecoration,
      child: Row(children: widget.children),
    );
    final gestureDetector = GestureDetector(
      onDoubleTap: widget.onDoubleTap,
      child: row,
    );
    final listener = Listener(
      onPointerDown: handlePointerDown,
      child: gestureDetector,
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: handleEnter,
      onExit: handleExit,
      child: listener,
    );
  }

  void handleEnter(PointerEnterEvent event) {
    setState(() {
      hovered = true;
    });
  }

  void handleExit(PointerExitEvent event) {
    setState(() {
      hovered = false;
    });
  }

  void handlePointerDown(PointerDownEvent event) {
    if (event.buttons != kSecondaryMouseButton) return;
    final positioned = Positioned(
      left: event.position.dx - 84,
      top: event.position.dy,
      width: 200,
      child: _ContextMenu(onTap: handleTap),
    );
    final stack = Stack(children: [_Barrier(onTap: removeEntry), positioned]);
    entry = OverlayEntry(builder: (_) => stack);
    Overlay.of(context).insert(entry!);
  }

  void handleTap(FoxyContextMenuOption option) {
    entry?.remove();
    widget.onContextMenuTap?.call(option);
  }

  void removeEntry() {
    entry?.remove();
  }
}

class _Barrier extends StatelessWidget {
  final void Function()? onTap;
  const _Barrier({this.onTap});

  @override
  Widget build(BuildContext context) {
    final container = Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.transparent,
    );
    return GestureDetector(
      onSecondaryTap: onTap,
      onTap: onTap,
      child: container,
    );
  }
}

class _ContextMenu extends StatelessWidget {
  final void Function(FoxyContextMenuOption)? onTap;
  const _ContextMenu({this.onTap});

  @override
  Widget build(BuildContext context) {
    final children = [
      ListTile(onTap: () => handleTap(0), title: Text('预览')),
      ListTile(onTap: () => handleTap(1), title: Text('编辑')),
      ListTile(onTap: () => handleTap(2), title: Text('复制')),
      Divider(),
      ListTile(onTap: () => handleTap(3), title: Text('删除')),
    ];
    return Material(
      borderRadius: BorderRadius.circular(8),
      elevation: 8,
      child: Column(children: children),
    );
  }

  void handleTap(int index) {
    final option = switch (index) {
      0 => FoxyContextMenuOption.read,
      1 => FoxyContextMenuOption.edit,
      2 => FoxyContextMenuOption.duplicate,
      3 => FoxyContextMenuOption.destroy,
      _ => throw Exception('Unhandled context menu option $index'),
    };
    onTap?.call(option);
  }
}
