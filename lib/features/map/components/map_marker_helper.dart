import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Downloads [imageUrl] and renders it as a circular map marker
/// with a colored [borderColor] ring and a [label] below.
Future<BitmapDescriptor> buildAvatarMarker({
  required String imageUrl,
  required String label,
  Color borderColor = Colors.green,
  int size = 120,
}) async {
  // Download image bytes
  Uint8List imageBytes;
  try {
    final response = await http.get(Uri.parse(imageUrl));
    imageBytes = response.bodyBytes;
  } catch (_) {
    // Fallback to default marker on network error
    return BitmapDescriptor.defaultMarker;
  }

  // Decode image
  final codec = await ui.instantiateImageCodec(
    imageBytes,
    targetWidth: size,
    targetHeight: size,
  );
  final frame = await codec.getNextFrame();
  final photo = frame.image;

  // Canvas size: circle + label below
  const labelHeight = 28.0;
  final canvasSize = Size(size.toDouble(), size + labelHeight);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final center = Offset(size / 2, size / 2);
  final radius = size / 2;

  // Border ring
  canvas.drawCircle(
    center,
    radius,
    Paint()..color = borderColor,
  );

  // Clip to circle and draw photo
  final clipPath = Path()
    ..addOval(Rect.fromCircle(center: center, radius: radius - 4));
  canvas.clipPath(clipPath);
  canvas.drawImageRect(
    photo,
    Rect.fromLTWH(0, 0, photo.width.toDouble(), photo.height.toDouble()),
    Rect.fromCircle(center: center, radius: radius - 4),
    Paint(),
  );

  // Reset clip for label
  canvas.restore();

  // Label background + text
  final labelPaint = Paint()..color = borderColor;
  final labelRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(size / 2 - 30, size.toDouble() + 2, 60, 22),
    const Radius.circular(11),
  );
  canvas.drawRRect(labelRect, labelPaint);

  final tp = TextPainter(
    text: TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(
    canvas,
    Offset(size / 2 - tp.width / 2, size.toDouble() + 5),
  );

  // Convert to image bytes
  final picture = recorder.endRecording();
  final img = await picture.toImage(
    canvasSize.width.toInt(),
    canvasSize.height.toInt(),
  );
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}
