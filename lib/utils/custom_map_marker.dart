import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'dart:ui' as ui;
import 'dart:typed_data';

/// A utility class for creating custom map markers.
/// This is currently not in use but preserved for future implementation.
class CustomMapMarker {
  /// Creates a custom circular marker with a number inside.
  /// The marker is styled with the provided color and has a white border.
  static Future<gmap.BitmapDescriptor> createNumberedMarker({
    required int number,
    required Color color,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(24, 24); // Smaller circle size

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw circle background
    canvas.drawCircle(const Offset(12, 12), 12, paint);

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(const Offset(12, 12), 11, borderPaint);

    // Add number text
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Gilroy-SemiBold',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        12 - textPainter.width / 2,
        12 - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return gmap.BitmapDescriptor.bytes(uint8List);
  }
}
