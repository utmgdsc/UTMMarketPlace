import 'package:flutter/material.dart';

final appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
);

SliverGridDelegateWithFixedCrossAxisCount itemCardDelegate() {
  return const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.75,
    crossAxisSpacing: 8,
    mainAxisSpacing: 1,
    mainAxisExtent: 310,
  );
}

// This class is for storing text styles that are used throughout the app
// The label style is used for smaller text, such as form labels
// The header style is used for larger text, such as titles
class ThemeText {
  static const TextStyle header = TextStyle(
    fontSize: 40.0,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
  );

  static const TextStyle label = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
  );
}

// This class is a custom text widget that uses the theme text style provided above
// This simplifies the process of creating text widgets with consistent styling
// To use, simply provide the text, style, and optional text alignment
// Will most likely be modified as we continue to develop the app
class StyleText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  const StyleText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
    );
  }
}
