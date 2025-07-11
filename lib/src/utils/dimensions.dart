/// dimensions.dart
/// Utility for responsive screen-based dimensions in the app.
/// Use these helpers for consistent sizing, padding, and radius.

import 'package:flutter/material.dart';

class Dimensions {
  // Thêm các hàm cho product card đồng đều
  static double width150(BuildContext context) => screenWidth(context) * (150 / baseWidth);
  static double height220(BuildContext context) => screenHeight(context) * (220 / baseHeight);
  static double height4(BuildContext context) => screenHeight(context) * (4 / baseHeight);
  static double height2(BuildContext context) => screenHeight(context) * (2 / baseHeight);
  static double width4(BuildContext context) => screenWidth(context) * (4 / baseWidth);
  static double font12(BuildContext context) => screenHeight(context) * (12 / baseHeight);
  static double font14(BuildContext context) => screenHeight(context) * (14 / baseHeight);
  // Unified context-based responsive helpers
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  // Chuẩn thiết kế: height = 732, width = 360
  static const double baseHeight = 732.0;
  static const double baseWidth = 360.0;

  // Dynamic height padding and margin (chuẩn tỉ lệ)
  static double height10(BuildContext context) => screenHeight(context) * (10 / baseHeight);
  static double height15(BuildContext context) => screenHeight(context) * (15 / baseHeight);
  static double height20(BuildContext context) => screenHeight(context) * (20 / baseHeight);
  static double height25(BuildContext context) => screenHeight(context) * (25 / baseHeight);
  static double height30(BuildContext context) => screenHeight(context) * (30 / baseHeight);
  static double height35(BuildContext context) => screenHeight(context) * (35 / baseHeight);
  static double height40(BuildContext context) => screenHeight(context) * (40 / baseHeight);
  static double height45(BuildContext context) => screenHeight(context) * (45 / baseHeight);
  static double height50(BuildContext context) => screenHeight(context) * (50 / baseHeight);
  static double height55(BuildContext context) => screenHeight(context) * (55 / baseHeight);
  static double height60(BuildContext context) => screenHeight(context) * (60 / baseHeight);
  static double height65(BuildContext context) => screenHeight(context) * (65 / baseHeight);
  static double height70(BuildContext context) => screenHeight(context) * (70 / baseHeight);
  static double height75(BuildContext context) => screenHeight(context) * (75 / baseHeight);
  static double height80(BuildContext context) => screenHeight(context) * (80 / baseHeight);
  static double height85(BuildContext context) => screenHeight(context) * (85 / baseHeight);
  static double height90(BuildContext context) => screenHeight(context) * (90 / baseHeight);
  static double height95(BuildContext context) => screenHeight(context) * (95 / baseHeight);
  static double height100(BuildContext context) => screenHeight(context) * (100 / baseHeight);

  // Dynamic width padding and margin (chuẩn tỉ lệ)
  static double width10(BuildContext context) => screenWidth(context) * (10 / baseWidth);
  static double width15(BuildContext context) => screenWidth(context) * (15 / baseWidth);
  static double width20(BuildContext context) => screenWidth(context) * (20 / baseWidth);
  static double width25(BuildContext context) => screenWidth(context) * (25 / baseWidth);
  static double width30(BuildContext context) => screenWidth(context) * (30 / baseWidth);
  static double width35(BuildContext context) => screenWidth(context) * (35 / baseWidth);
  static double width40(BuildContext context) => screenWidth(context) * (40 / baseWidth);
  static double width45(BuildContext context) => screenWidth(context) * (45 / baseWidth);
  static double width50(BuildContext context) => screenWidth(context) * (50 / baseWidth);
  static double width55(BuildContext context) => screenWidth(context) * (55 / baseWidth);
  static double width60(BuildContext context) => screenWidth(context) * (60 / baseWidth);
  static double width65(BuildContext context) => screenWidth(context) * (65 / baseWidth);
  static double width70(BuildContext context) => screenWidth(context) * (70 / baseWidth);
  static double width75(BuildContext context) => screenWidth(context) * (75 / baseWidth);
  static double width80(BuildContext context) => screenWidth(context) * (80 / baseWidth);
  static double width85(BuildContext context) => screenWidth(context) * (85 / baseWidth);
  static double width90(BuildContext context) => screenWidth(context) * (90 / baseWidth);
  static double width95(BuildContext context) => screenWidth(context) * (95 / baseWidth);
  static double width100(BuildContext context) => screenWidth(context) * (100 / baseWidth);

  // Icon size (chuẩn tỉ lệ)
  static double iconSize8(BuildContext context) => screenHeight(context) * (8 / baseHeight);
  static double iconSize12(BuildContext context) => screenHeight(context) * (12 / baseHeight);
  static double iconSize16(BuildContext context) => screenHeight(context) * (16 / baseHeight);
  static double iconSize20(BuildContext context) => screenHeight(context) * (20 / baseHeight);
  static double iconSize24(BuildContext context) => screenHeight(context) * (24 / baseHeight);
  static double iconSize28(BuildContext context) => screenHeight(context) * (28 / baseHeight);
  static double iconSize32(BuildContext context) => screenHeight(context) * (32 / baseHeight);
  static double iconSize36(BuildContext context) => screenHeight(context) * (36 / baseHeight);
  static double iconSize40(BuildContext context) => screenHeight(context) * (40 / baseHeight);

  // Text size (chuẩn tỉ lệ)
  static double sizeText(BuildContext context) => screenHeight(context) * (20 / baseHeight);

  static double font16(BuildContext context) => screenHeight(context) * (16 / baseHeight);
  static double font18(BuildContext context) => screenHeight(context) * (18 / baseHeight);
  static double font20(BuildContext context) => screenHeight(context) * (20 / baseHeight);
  static double font22(BuildContext context) => screenHeight(context) * (22 / baseHeight);
  static double font24(BuildContext context) => screenHeight(context) * (24 / baseHeight);
  static double font26(BuildContext context) => screenHeight(context) * (26 / baseHeight);
  static double font28(BuildContext context) => screenHeight(context) * (28 / baseHeight);
  static double font30(BuildContext context) => screenHeight(context) * (30 / baseHeight);

  // Radius (chuẩn tỉ lệ)
  static double radius5(BuildContext context) => screenHeight(context) * (5 / baseHeight);
  static double radius10(BuildContext context) => screenHeight(context) * (10 / baseHeight);
  static double radius15(BuildContext context) => screenHeight(context) * (15 / baseHeight);
  static double radius20(BuildContext context) => screenHeight(context) * (20 / baseHeight);
  static double radius25(BuildContext context) => screenHeight(context) * (25 / baseHeight);
  static double radius30(BuildContext context) => screenHeight(context) * (30 / baseHeight);
  static double radius35(BuildContext context) => screenHeight(context) * (35 / baseHeight);
  static double radius40(BuildContext context) => screenHeight(context) * (40 / baseHeight);


}
