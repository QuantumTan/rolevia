import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Original product artwork, decorative when adjacent text explains the state.
class ProductIllustration extends StatelessWidget {
  const ProductIllustration(this.name, {super.key, this.height = 120});
  final String name;
  final double height;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.asset(
      'assets/images/illustrations/$name.svg',
      height: height,
      fit: BoxFit.contain,
    ),
  );
}
