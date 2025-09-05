import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddReviewsForPropertyController extends GetxController {
  TextEditingController writeAReviewController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    writeAReviewController.clear();
  }
}