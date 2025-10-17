import 'package:flutter/material.dart';
import '../core/ui_ast.dart';

/// FlutterExpo wrapper for Text widget that emits UI AST
class TText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final String? textId;

  const TText(
    this.data, {
    Key? key,
    this.style,
    this.textAlign,
    this.textId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Emit UI AST for this text widget
    
    return Text(
      data,
      style: style,
      textAlign: textAlign,
    );
  }

  /// Generate UI AST node for this text widget
  UIASTNode toUIASTNode() {
    return UIASTNode(
      type: 'Text',
      props: {
        'data': data,
        if (textAlign != null) 'textAlign': textAlign.toString(),
      },
      style: _convertTextStyle(style),
      textId: textId,
      text: data,
    );
  }

  Map<String, dynamic>? _convertTextStyle(TextStyle? style) {
    if (style == null) return null;
    
    return {
      if (style.fontSize != null) 'fontSize': style.fontSize,
      if (style.color != null) 'color': '#${((style.color!.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((style.color!.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((style.color!.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}',
      if (style.fontWeight != null) 'fontWeight': style.fontWeight.toString(),
      if (style.fontStyle != null) 'fontStyle': style.fontStyle.toString(),
    };
  }
}