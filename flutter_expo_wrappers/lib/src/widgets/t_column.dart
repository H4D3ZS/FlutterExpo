import 'package:flutter/material.dart';
import '../core/ui_ast.dart';

/// FlutterExpo wrapper for Column widget that emits UI AST
class TColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final String? id;

  const TColumn({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Emit UI AST for this column widget
    
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  /// Generate UI AST node for this column widget
  UIASTNode toUIASTNode() {
    return UIASTNode(
      id: id,
      type: 'Column',
      props: {
        'mainAxisAlignment': mainAxisAlignment.toString(),
        'crossAxisAlignment': crossAxisAlignment.toString(),
      },
      style: {
        'display': 'flex',
        'flexDirection': 'column',
        'justifyContent': _mapMainAxisAlignment(mainAxisAlignment),
        'alignItems': _mapCrossAxisAlignment(crossAxisAlignment),
      },
      children: _convertChildren(children),
    );
  }

  List<UIASTNode>? _convertChildren(List<Widget> children) {
    // TODO: Implement proper children conversion
    return null;
  }

  String _mapMainAxisAlignment(MainAxisAlignment alignment) {
    switch (alignment) {
      case MainAxisAlignment.start:
        return 'flex-start';
      case MainAxisAlignment.end:
        return 'flex-end';
      case MainAxisAlignment.center:
        return 'center';
      case MainAxisAlignment.spaceBetween:
        return 'space-between';
      case MainAxisAlignment.spaceAround:
        return 'space-around';
      case MainAxisAlignment.spaceEvenly:
        return 'space-evenly';
    }
  }

  String _mapCrossAxisAlignment(CrossAxisAlignment alignment) {
    switch (alignment) {
      case CrossAxisAlignment.start:
        return 'flex-start';
      case CrossAxisAlignment.end:
        return 'flex-end';
      case CrossAxisAlignment.center:
        return 'center';
      case CrossAxisAlignment.stretch:
        return 'stretch';
      case CrossAxisAlignment.baseline:
        return 'baseline';
    }
  }
}