import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
// import 'package:screen_go/extensions/responsive_nums.dart';

abstract class StylesManager {
  StylesManager._();

  static String fontFamile = "Almarai";

  static TextStyle textStyle22 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static TextStyle textStyle16v3FontFamile = TextStyle(
    fontFamily: StylesManager.fontFamile,
    fontSize: 16.3,
  );

  static TextStyle textStyle18None = TextStyle(fontSize: 18);

  static TextStyle textStyle16None = TextStyle(fontSize: 16);

  static TextStyle textStyle17White = TextStyle(
    color: ColorManager.white,
    fontSize: 17,
  );
  static TextStyle textStyle14White = TextStyle(
    fontSize: 14,
    color: ColorManager.white,
  );

  static TextStyle textStyle20White = TextStyle(
    fontSize: 19,
    color: ColorManager.white,
  );

  static TextStyle textStyle17FontFamile = TextStyle(
    fontFamily: StylesManager.fontFamile,
    fontSize: 17,
  );

  static TextStyle textStyle16FontFamile = TextStyle(
    fontFamily: StylesManager.fontFamile,
    fontSize: 16,
    color: ColorManager.white,
  );

  static TextStyle textStyle16GrayNone = TextStyle(
    fontSize: 16,
    color: ColorManager.gray,
  );

  static TextStyle textStyle15BlackW700FontFamile = TextStyle(
    color: ColorManager.black,
    fontWeight: FontWeight.w700,
    fontFamily: StylesManager.fontFamile,
    fontSize: 15,
    overflow: TextOverflow.ellipsis,
  );
  static TextStyle textStyle14V5BlackW500FontFamile = TextStyle(
    color: ColorManager.black,
    fontWeight: FontWeight.w500,
    fontFamily: StylesManager.fontFamile,
    overflow: TextOverflow.ellipsis,
    fontSize: 14.5,
  );
  static TextStyle textStyle13BlackW500FontFamile = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    fontFamily: StylesManager.fontFamile,
    color: const Color.fromARGB(255, 234, 137, 243),
  );
  static TextStyle textStyle18W500 = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
}
