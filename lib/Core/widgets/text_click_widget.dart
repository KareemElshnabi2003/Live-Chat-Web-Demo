import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget textClick(
  dynamic text,
  bool? decoration,
  VoidCallback? onPress,
  Color color,
  double size, {
  FontWeight weight = FontWeight.w500,
}) {
  return InkWell(
    onTap: onPress,
    child: Text(
      text?.toString() ?? "",
      style: GoogleFonts.ibmPlexSansArabic(
        decoration: decoration == true ? TextDecoration.underline : null,
        decorationColor: color,
        color: color,
        fontSize: size,
        fontWeight: weight,
      ),
    ),
  );
}
