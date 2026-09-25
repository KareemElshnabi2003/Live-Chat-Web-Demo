import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget textNormal(
  dynamic text,
  Color color,
  double size,
  FontWeight weight, {
  bool center = false,
  bool multi = false,
  int numOfRow = 0,
  bool bgcolor = false,
  int? maxLines,
  TextOverflow? overflow,
  TextDirection? textDirection,
  TextAlign? textAlign,
}) {
  return Text(
    text?.toString() ?? "",
    textAlign: center ? TextAlign.center : textAlign,
    textDirection: textDirection,
    maxLines: multi
        ? (numOfRow > 0 ? numOfRow : null)
        : (maxLines ?? 2),
    overflow: overflow ?? TextOverflow.ellipsis,
    style: GoogleFonts.ibmPlexSansArabic(
      decoration: TextDecoration.none,
      backgroundColor: bgcolor ? Colors.black12 : null,
      color: color,
      fontSize: size,
      fontWeight: weight,
    ),
  );
}

class TextNormalWidget extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final TextDecoration decoration;
  final Color decorationColor;
  final int maxLines;
  final FontWeight weight;

  const TextNormalWidget({
    super.key,
    required this.text,
    required this.size,
    required this.color,
    this.decoration = TextDecoration.none,
    this.decorationColor = Colors.transparent,
    this.maxLines = 1,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.ibmPlexSansArabic(
        fontWeight: weight,
        fontSize: size,
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
      ),
    );
  }
}
