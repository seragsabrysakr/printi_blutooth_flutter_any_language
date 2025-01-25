import 'dart:ui' as ui;

import 'package:bluetooth_printing/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Create an image from given [GlobalKey], which is attached to an exist
/// [RepaintBoundary].
///
/// [imageSize] can define what size the generated image will be (in pixels).
Future<Uint8List?> createImageFromRepaintBoundary(
  GlobalKey boundaryKey, {
  double? pixelRatio,
  Size? imageSize,
}) async {
  assert(
    boundaryKey.currentContext?.findRenderObject() is RenderRepaintBoundary,
  );
  final RenderRepaintBoundary boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
  final BoxConstraints constraints = boundary.constraints;
  double? outputRatio = pixelRatio;
  if (imageSize != null) {
    outputRatio = imageSize.width / constraints.maxWidth;
  }
  final ui.Image image = await boundary.toImage(
    pixelRatio:
        outputRatio ?? MediaQueryData.fromWindow(ui.window).devicePixelRatio,
  );
  final ByteData? byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  final Uint8List? imageData = byteData?.buffer.asUint8List();
  return imageData;
}

/// Creates an image from the given widget by first spinning up a element and
/// render tree, then waiting for the given [wait] amount of time and then
/// creating an image via a [RepaintBoundary].
///
/// The final image will be of size [imageSize] and the the widget will be
/// layout, with the given [logicalSize].

Future<Uint8List?> createImageFromWidget(Widget widget,
    {Duration? wait, Size? logicalSize, Size? imageSize}) async {
  var cxt = appNavigatorKey.currentState!.context;
// Create a repaint boundary to capture the image
  final repaintBoundary = RenderRepaintBoundary();

// Calculate logicalSize and imageSize if not provided
  logicalSize ??= View.of(cxt).physicalSize / View.of(cxt).devicePixelRatio;
  imageSize ??= View.of(cxt).physicalSize;

// Ensure logicalSize and imageSize have the same aspect ratio
//   assert(logicalSize.aspectRatio == imageSize.aspectRatio,
//       'logicalSize and imageSize must not be the same');

// Create the render tree for capturing the widget as an image
  final renderView = RenderView(
    view: View.of(cxt),
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: const ViewConfiguration(
      logicalConstraints: BoxConstraints(),
      devicePixelRatio: 1,
    ),
  );

  final pipelineOwner = PipelineOwner();
  final buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

// Attach the widget's render object to the render tree
  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      )).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);

// Delay if specified
  if (wait != null) {
    await Future.delayed(wait);
  }

// Build and finalize the render tree
  buildOwner
    ..buildScope(rootElement)
    ..finalizeTree();

// Flush layout, compositing, and painting operations
  pipelineOwner
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();

// Capture the image and convert it to byte data
  final image = await repaintBoundary.toImage(
      pixelRatio: imageSize.width / logicalSize.width);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

// Return the image data as Uint8List
  return byteData?.buffer.asUint8List();
}
