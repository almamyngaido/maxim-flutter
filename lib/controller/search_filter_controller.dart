import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';

enum SearchContentType {
  searchFilter,
  search,
}

class SearchFilterController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxInt selectProperty = 0.obs;
  RxInt selectPropertyLooking = 0.obs;
  RxInt selectBedrooms = 0.obs;
  RxInt selectLookingFor = 0.obs;
  RxInt selectTypesOfProperty = 0.obs;
  Rx<RangeValues> values = const RangeValues(50, 500).obs;
  String get startValueText => "₹ ${convertToText(values.value.start)}";
  String get endValueText => "₹ ${convertToText(values.value.end)}";
  Rx<SearchContentType> contentType = SearchContentType.searchFilter.obs;

  String convertToText(double value) {
    if (value >= 100) {
      return "${(value / 100).toStringAsFixed(2)} crores";
    } else {
      return "${value.toStringAsFixed(2)} lakhs";
    }
  }

  void updateProperty(int index) {
    selectProperty.value = index;
  }

  void updatePropertyLooking(int index) {
    selectPropertyLooking.value = index;
  }

  void updateBedrooms(int index) {
    selectBedrooms.value = index;
  }

  void updateLookingFor(int index) {
    selectLookingFor.value = index;
  }

  void updateTypesOfProperty(int index) {
    selectTypesOfProperty.value = index;
  }

  void updateValues(RangeValues newValues) {
    values.value = newValues;
  }

  void setContent(SearchContentType type) {
    contentType.value = type;
  }

  RxList<String> propertyList = [
    AppString.residential,
    AppString.commercial,
  ].obs;

  RxList<String> propertyLookingList = [
    AppString.buy,
    AppString.rentPg,
    AppString.room,
  ].obs;

  RxList<String> propertyTypeList = [
    AppString.residentialApartment,
    AppString.independentVilla,
    AppString.plotLandAdd,
  ].obs;

  RxList<String> bedroomsList = [
    AppString.add1BHK,
    AppString.add2BHK,
    AppString.add3BHK,
    AppString.add4BHK,
    AppString.add4PlusBHK,
  ].obs;

  RxList<String> propertyLookingForList = [
    AppString.yes,
    AppString.no,
  ].obs;

  RxList<String> recentSearchedList = [
    AppString.amroli,
    AppString.palanpura,
  ].obs;

  RxList<String> recentSearched2List = [
    AppString.vesu,
    AppString.palanpura,
    AppString.pal,
    AppString.adajan,
    AppString.althana,
    AppString.dindoli,
    AppString.vipRoad,
    AppString.piplod,
  ].obs;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }
}