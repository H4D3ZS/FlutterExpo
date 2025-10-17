import 'package:flutter/material.dart';
import '../core/ui_ast.dart';

/// FlutterExpo wrapper for Image widget that emits UI AST
class TImage extends StatelessWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String? semanticLabel;
  final String? id;

  const TImage({
    Key? key,
    required this.image,
    this.width,
    this.height,
    this.fit,
    this.semanticLabel,
    this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Emit UI AST for this image widget
    
    return Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
    );
  }

  /// Generate UI AST node for this image widget
  UIASTNode toUIASTNode() {
    return UIASTNode(
      id: id,
      type: 'Image',
      props: {
        'src': _getImageUrl(),
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (fit != null) 'fit': fit.toString(),
        if (semanticLabel != null) 'alt': semanticLabel,
      },
    );
  }

  String _getImageUrl() {
    // TODO: Implement proper image URL extraction
    if (image is NetworkImage) {
      return (image as NetworkImage).url;
    } else if (image is AssetImage) {
      return (image as AssetImage).assetName;
    }
    return '';
  }
}