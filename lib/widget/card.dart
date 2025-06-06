import 'package:flutter/material.dart';

class FoxyCard extends StatefulWidget {
  final Widget? title;
  final Widget child;

  const FoxyCard({super.key, this.title, required this.child});

  @override
  State<FoxyCard> createState() => _FoxyCardState();
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final outline = colorScheme.outline;
    return Divider(color: outline.withValues(alpha: 0.2), height: 1);
  }
}

class _FoxyCardState extends State<FoxyCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final outline = colorScheme.outline;
    final surface = colorScheme.surface;
    final boxShadow = BoxShadow(
      blurRadius: 8,
      color: outline.withValues(alpha: 0.1),
      spreadRadius: 8,
    );
    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      boxShadow: [boxShadow],
      color: surface,
    );
    final title = _buildTitle();
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...title, widget.child],
    );
    return Container(decoration: boxDecoration, child: column);
  }

  List<Widget> _buildTitle() {
    if (widget.title == null) return [];
    const textStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    final title = DefaultTextStyle.merge(
      style: textStyle,
      child: widget.title!,
    );
    final padding = Padding(padding: EdgeInsets.all(16), child: title);
    return [padding, const _Divider()];
  }
}
