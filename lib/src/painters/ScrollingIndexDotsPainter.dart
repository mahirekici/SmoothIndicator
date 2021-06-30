import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'indicator_painter.dart';

class ScrollingIndexDotsPainter extends IndicatorPainter {
  final ScrollingDotsEffect effect;
  final TextStyle? visibleIndexStyle;
  ScrollingIndexDotsPainter(
      {required this.effect,
      required int count,
      required double offset,
      this.visibleIndexStyle})
      : super(offset, count, effect);

  @override
  void paint(Canvas canvas, Size size) {
    final current = super.offset.floor();
    final switchPoint = (effect.maxVisibleDots / 2).floor();
    final firstVisibleDot =
        (current < switchPoint || count - 1 < effect.maxVisibleDots)
            ? 0
            : min(current - switchPoint, count - effect.maxVisibleDots);
    final lastVisibleDot =
        min(firstVisibleDot + effect.maxVisibleDots, count - 1);
    final inPreScrollRange = current < switchPoint;
    final inAfterScrollRange = current >= (count - 1) - switchPoint;
    final willStartScrolling = (current + 1) == switchPoint + 1;
    final willStopScrolling = current + 1 == (count - 1) - switchPoint;

    final dotOffset = offset - offset.toInt();
    final dotPaint = Paint()
      ..strokeWidth = effect.strokeWidth
      ..style = effect.paintStyle;

    final drawingAnchor = (inPreScrollRange || inAfterScrollRange)
        ? -(firstVisibleDot * distance)
        : -((offset - switchPoint) * distance);

    final smallDotScale = 0.66;
    final activeScale = effect.activeDotScale - 1.0;

    for (var index = firstVisibleDot; index <= lastVisibleDot; index++) {
      var color = effect.dotColor;

      var scale = 1.0;

      if (index == current) {
        // ! Both a and b are non nullable
        color = Color.lerp(effect.activeDotColor, effect.dotColor, dotOffset)!;
        scale = effect.activeDotScale - (activeScale * dotOffset);
      } else if (index - 1 == current) {
        // ! Both a and b are non nullable
        color = Color.lerp(effect.dotColor, effect.activeDotColor, dotOffset)!;
        scale = 1.0 + (activeScale * dotOffset);
      } else if (count - 1 < effect.maxVisibleDots) {
        scale = 1.0;
      } else if (index == firstVisibleDot) {
        if (willStartScrolling) {
          scale = (1.0 * (1.0 - dotOffset));
        } else if (inAfterScrollRange) {
          scale = smallDotScale;
        } else if (!inPreScrollRange) {
          scale = smallDotScale * (1.0 - dotOffset);
        }
      } else if (index == firstVisibleDot + 1 &&
          !(inPreScrollRange || inAfterScrollRange)) {
        scale = 1.0 - (dotOffset * (1.0 - smallDotScale));
      } else if (index == lastVisibleDot - 1.0) {
        if (inPreScrollRange) {
          scale = smallDotScale;
        } else if (!inAfterScrollRange) {
          scale = smallDotScale + ((1.0 - smallDotScale) * dotOffset);
        }
      } else if (index == lastVisibleDot) {
        if (inPreScrollRange) {
          scale = 0.0;
        } else if (willStopScrolling) {
          scale = dotOffset;
        } else if (!inAfterScrollRange) {
          scale = smallDotScale * dotOffset;
        }
      }

      final scaledWidth = (effect.dotWidth * scale);
      final scaledHeight = effect.dotHeight * scale;
      final yPos = size.height / 2;
      final xPos = effect.dotWidth / 2 + drawingAnchor + (index * distance);

      final rRect = RRect.fromLTRBR(
        xPos - scaledWidth / 2 + effect.spacing / 2,
        yPos - scaledHeight / 2,
        xPos + scaledWidth / 2 + effect.spacing / 2,
        yPos + scaledHeight / 2,
        dotRadius * scale,
      );
      canvas.drawRRect(rRect, dotPaint..color = color);

      if (color == effect.activeDotColor) {
        var painter = drawtext((index + 1).toString());

        var painterRealWidth = (scaledWidth - (painter.size.width)) * 0.5;

        var xp = xPos - scaledWidth / 2 + effect.spacing / 2;

        xp += painterRealWidth;

        // çift haneli sayılarda manuel hesaplama verdik
        if ((index + 1).toString().length > 1) {
          xp += painterRealWidth / 2 - 1;
        }
        painter
          ..paint(
              canvas,
              Offset(
                xp,
                yPos - scaledHeight / 2 + 1,
              ));
      }
    }
  }

  TextPainter drawtext(String text) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 9,
    );
    final textSpan = TextSpan(
      text: text,
      style: visibleIndexStyle ?? textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.justify,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: 12,
    );
    return textPainter;
  }

  // void _paintText(Canvas canvas, Size size) {
  //   final textSpan = TextSpan(
  //     text: 'n/a',
  //   );
  //   final textPainter = TextPainter(
  //     text: textSpan,
  //     textDirection: TextDirection.ltr,
  //   );
  //   textPainter.layout();
  //   textPainter.paint(
  //     canvas,
  //     Offset(
  //       // Do calculations here:
  //       (size.width - textPainter.width) * 0.5,
  //       (size.height - textPainter.height) * 0.5,
  //     ),
  //   );
  // }
}
