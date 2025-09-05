import 'package:flutter/cupertino.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

postPropertySuccessDialogue() {
  return buildPostPropertySuccessLoader();
}

Widget buildPostPropertySuccessLoader() {
  return Center(
  child: Image.asset(
    Assets.images.loader.path,
    width: AppSize.appSize150,
  ),
);
}