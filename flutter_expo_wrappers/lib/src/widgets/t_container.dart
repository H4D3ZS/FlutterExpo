import 'package:flutter/material.dart';
import '../core/ui_ast.dart';

/// FlutterExpo wrapper for Container widget that emits UI AST
class TContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final String? id;

  const TContainer({
    Key? key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Emit UI AST for this container widget
    
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      child: child,
    );
  }

  /// Generate UI AST node for this container widget
  UIASTNode toUIASTNode() {
    return UIASTNode(
      id: id,
      type: 'Container',
      props: {
        if (width != null) 'width': width,
        if (height != null) 'height': height,
      },
      style: _convertContainerStyle(),
      children: child != null ? _convertChild(child!) : null,
    );
  }

  List<UIASTNode>? _convertChild(Widget child) {
    // TODO: Implement proper child conversion
    return null;
  }

  Map<String, dynamic> _convertContainerStyle() {
    final style = <String, dynamic>{};
    
    if (color != null) {
      final r = ((color!.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
      final g = ((color!.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
      final b = ((color!.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
      style['backgroundColor'] = '#$r$g$b';
    }
    
    if (padding != null && padding is EdgeInsets) {
      final p = padding as EdgeInsets;
      style['padding'] = '${p.top}px ${p.right}px ${p.bottom}px ${p.left}px';
    }
    
    if (margin != null && margin is EdgeInsets) {
      final m = margin as EdgeInsets;
      style['margin'] = '${m.top}px ${m.right}px ${m.bottom}px ${m.left}px';
    }
    
    return style;
  }
}