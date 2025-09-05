import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class HomeController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxInt selectProperty = 0.obs;
  RxInt selectCountry = 0.obs;
  RxList<bool> isTrendPropertyLiked = <bool>[].obs;
  // RxString userName = 'Francis'.obs; // Default/fallback value
  // If using GetStorage: final storage = GetStorage();
  RxString userName = 'Guest'.obs;
  final storage = GetStorage();
  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    try {
      String? token = storage.read('authToken');
      print('Retrieved token in HomeController: $token'); // Debug

      if (token == null || token.isEmpty) {
        print('No token found, redirecting to login');
        Get.snackbar('Error', 'No token found. Please log in.');
        Get.offNamed(AppRoutes.loginView);
        return;
      }

      final response = await http.get(
        Uri.parse('${AppString.apiBaseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response from /me: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        userName.value = userData['prenom']?.isNotEmpty == true
            ? userData['prenom']
            : userData['nom'] ?? 'Guest';
        print('User name set to: ${userName.value}'); // Debug
      } else {
        print(
            'Failed to fetch user: ${response.statusCode} ${response.reasonPhrase}');
        Get.snackbar('Error', 'Failed to fetch user: ${response.reasonPhrase}');
        if (response.statusCode == 401) {
          storage.remove('authToken');
          Get.offNamed(AppRoutes.loginView);
        }
      }
    } catch (e) {
      print('Network error in fetchCurrentUser: $e');
      Get.snackbar('Error', 'Network error: $e');
    }
  }

  void updateProperty(int index) {
    selectProperty.value = index;
  }

  void updateCountry(int index) {
    selectCountry.value = index;
  }

  RxList<String> propertyOptionList = [
    AppString.buy,
    AppString.rent,
    //AppString.plotLand,
    //AppString.pg,
    AppString.coWorkingSpace,
    AppString.byCommercial,
    AppString.leaseCommercial,
    AppString.postAProperty,
  ].obs;

  RxList<String> countryOptionList = [
    AppString.westernMumbai,
    AppString.switzerland,
    AppString.nepal,
    AppString.exploreNew,
  ].obs;

  RxList<String> projectImageList = [
    Assets.images.project1.path,
    Assets.images.project2.path,
    Assets.images.project1.path,
  ].obs;

  RxList<String> projectPriceList = [
    AppString.rupees4Cr,
    AppString.priceOnRequest,
    AppString.priceOnRequest,
  ].obs;

  RxList<String> projectTitleList = [
    AppString.residentialApart,
    AppString.residentialApart2,
    AppString.plot2000ft,
  ].obs;

  RxList<String> projectAddressList = [
    AppString.address1,
    AppString.address2,
    AppString.address3,
  ].obs;

  RxList<String> projectTimingList = [
    AppString.days2Ago,
    AppString.month2Ago,
    AppString.month2Ago,
  ].obs;

  RxList<String> project2ImageList = [
    Assets.images.project3.path,
    Assets.images.project4.path,
    Assets.images.project3.path,
  ].obs;

  RxList<String> project2PriceList = [
    AppString.rupees2Cr,
    AppString.rupees5Cr,
    AppString.rupees2Cr,
  ].obs;

  RxList<String> project2TitleList = [
    AppString.residentialApart,
    AppString.plot2000ft,
    AppString.residentialApart,
  ].obs;

  RxList<String> project2AddressList = [
    AppString.address4,
    AppString.address5,
    AppString.address4,
  ].obs;

  RxList<String> project2TimingList = [
    AppString.days2Ago,
    AppString.month2Ago,
    AppString.days2Ago,
  ].obs;

  RxList<String> responseImageList = [
    Assets.images.response1.path,
    Assets.images.response2.path,
    Assets.images.response3.path,
    Assets.images.response4.path,
  ].obs;

  RxList<String> responseNameList = [
    AppString.rudraProperties,
    AppString.claudeAnderson,
    AppString.rohitBhati,
    AppString.heerKher,
  ].obs;

  RxList<String> responseTimingList = [
    AppString.today,
    AppString.today,
    AppString.yesterday,
    AppString.days4Ago,
  ].obs;

  RxList<String> responseEmailList = [
    AppString.rudraEmail,
    AppString.rudraEmail,
    AppString.rudraEmail,
    AppString.heerEmail,
  ].obs;

  RxList<String> searchImageList = [
    Assets.images.searchProperty1.path,
    Assets.images.searchProperty2.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.semiModernHouse,
    AppString.modernHouse,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.address6,
    AppString.address7,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.rupees22Lakh,
  ].obs;

  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;

  RxList<String> searchPropertyTitleList = [
    AppString.point2,
    AppString.point1,
    AppString.sq456,
  ].obs;

  RxList<String> popularBuilderImageList = [
    Assets.images.builder1.path,
    Assets.images.builder2.path,
    Assets.images.builder3.path,
    Assets.images.builder4.path,
    Assets.images.builder5.path,
    Assets.images.builder6.path,
  ].obs;

  RxList<String> popularBuilderTitleList = [
    AppString.sobhaDevelopers,
    AppString.kalpataru,
    AppString.godrej,
    AppString.unitech,
    AppString.casagrand,
    AppString.brigade,
  ].obs;

  RxList<String> upcomingProjectImageList = [
    Assets.images.upcomingProject1.path,
    Assets.images.upcomingProject2.path,
    Assets.images.upcomingProject3.path,
  ].obs;

  RxList<String> upcomingProjectTitleList = [
    AppString.luxuryVilla,
    AppString.shreenathjiResidency,
    AppString.pramukhDevelopersSurat,
  ].obs;

  RxList<String> upcomingProjectAddressList = [
    AppString.address8,
    AppString.address9,
    AppString.address10,
  ].obs;

  RxList<String> upcomingProjectFlatSizeList = [
    AppString.bhk3Apartment,
    AppString.bhk4Apartment,
    AppString.bhk5Apartment,
  ].obs;

  RxList<String> upcomingProjectPriceList = [
    AppString.lakh45,
    AppString.lakh85,
    AppString.lakh85,
  ].obs;

  RxList<String> popularCityImageList = [
    Assets.images.city1.path,
    Assets.images.city2.path,
    Assets.images.city3.path,
    Assets.images.city4.path,
    Assets.images.city5.path,
    Assets.images.city6.path,
    Assets.images.city7.path,
  ].obs;

  RxList<String> popularCityTitleList = [
    AppString.mumbai,
    AppString.newDelhi,
    AppString.gurgaon,
    AppString.noida,
    AppString.bangalore,
    AppString.ahmedabad,
    AppString.kolkata,
  ].obs;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }
}
