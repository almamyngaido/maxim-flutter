import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/search_filter_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class SearchView extends StatelessWidget {
  SearchView({super.key});

  final SearchFilterController searchFilterController = Get.put(SearchFilterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildSearch(),
      bottomNavigationBar: buildButton(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      scrolledUnderElevation: AppSize.appSize0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Image.asset(
            Assets.images.backArrow.path,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Text(
        AppString.search,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildSearch() {
    return Obx(() {
      switch (searchFilterController.contentType.value) {
        case SearchContentType.searchFilter:
          return _searchFilterContent();
        case SearchContentType.search:
          return _searchContent();
      }
    });
  }

  Widget buildButton() {
    return Obx(() => Padding(
      padding: const EdgeInsets.only(
        left: AppSize.appSize16, right: AppSize.appSize16,
        bottom: AppSize.appSize26,
      ),
      child: searchFilterController.contentType.value == SearchContentType.search ? CommonButton(
        onPressed: () {
          searchFilterController.setContent(SearchContentType.searchFilter);
        },
        backgroundColor: AppColor.primaryColor,
        child: Text(
          AppString.continueButton,
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      ) : CommonButton(
        onPressed: () {
          Get.toNamed(AppRoutes.propertyListView);
        },
        backgroundColor: AppColor.primaryColor,
        child: Text(
          AppString.seeAllPropertyButton,
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      ),
    ));
  }

  _searchFilterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(searchFilterController.propertyList.length, (index) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  searchFilterController.updateProperty(index);
                },
                child: Obx(() => Container(
                  height: AppSize.appSize25,
                  padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: searchFilterController.selectProperty.value == index
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                      right: BorderSide(
                        color: index == AppSize.size1
                            ? Colors.transparent
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      searchFilterController.propertyList[index],
                      style: AppStyle.heading5Medium(
                        color: searchFilterController.selectProperty.value == index
                            ? AppColor.primaryColor
                            : AppColor.textColor,
                      ),
                    ),
                  ),
                )),
              ),
            );
          }),
        ).paddingOnly(
          top: AppSize.appSize10,
          left: AppSize.appSize16, right: AppSize.appSize16,
        ),
        Expanded(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSize.appSize20),
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  color: AppColor.whiteColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: AppSize.appSizePoint1,
                      blurRadius: AppSize.appSize2,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: searchFilterController.searchController,
                  cursorColor: AppColor.primaryColor,
                  style: AppStyle.heading4Regular(color: AppColor.textColor),
                  readOnly: true,
                  onTap: () {
                    searchFilterController.setContent(SearchContentType.search);
                  },
                  decoration: InputDecoration(
                    hintText: AppString.searchCity,
                    hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSize.appSize16, right: AppSize.appSize16,
                      ),
                      child: Image.asset(
                        Assets.images.search.path,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      maxWidth: AppSize.appSize51,
                    ),
                  ),
                ),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
              Text(
                AppString.lookingTo,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
              Row(
                children: List.generate(searchFilterController.propertyLookingList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      searchFilterController.updatePropertyLooking(index);
                    },
                    child: Obx(() => Container(
                      margin: const EdgeInsets.only(right: AppSize.appSize16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: searchFilterController.selectPropertyLooking.value == index
                              ? AppColor.primaryColor
                              : AppColor.borderColor,
                          width: AppSize.appSize1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          searchFilterController.propertyLookingList[index],
                          style: AppStyle.heading5Medium(
                            color: searchFilterController.selectPropertyLooking.value == index
                                ? AppColor.primaryColor
                                : AppColor.descriptionColor,
                          ),
                        ),
                      ),
                    )),
                  );
                }),
              ).paddingOnly(
                top: AppSize.appSize16,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
              Text(
                AppString.budget,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
              Theme(
                data: ThemeData(
                  sliderTheme: SliderThemeData(
                    activeTrackColor: AppColor.primaryColor,
                    disabledActiveTrackColor: AppColor.secondaryColor,
                    inactiveTrackColor: AppColor.secondaryColor,
                    overlayShape: SliderComponentShape.noOverlay,
                    trackHeight: AppSize.appSize3,
                    thumbColor: AppColor.primaryColor,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: AppSize.appSize3,
                      disabledThumbRadius: AppSize.appSize3,
                    ),
                  ),
                ),
                child: Obx(() => RangeSlider(
                  values: searchFilterController.values.value,
                  min: AppSize.appSize50,
                  max: AppSize.appSize500,
                  onChanged: (value) {
                    searchFilterController.updateValues(value);
                  },
                )),
              ).paddingOnly(
                top: AppSize.appSize20,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: AppSize.appSize37,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: AppColor.descriptionColor,
                          width: AppSize.appSizePoint7,
                        ),
                      ),
                      child: Center(
                        child: Obx(() => Text(
                          searchFilterController.startValueText,
                          style: AppStyle.heading5Medium(color: AppColor.textColor),
                        )),
                      ),
                    ),
                  ),
                  Text(
                    AppString.toText,
                    style: AppStyle.heading5Medium(color: AppColor.textColor),
                  ).paddingSymmetric(horizontal: AppSize.appSize26),
                  Expanded(
                    child: Container(
                      height: AppSize.appSize37,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: AppColor.descriptionColor,
                          width: AppSize.appSizePoint7,
                        ),
                      ),
                      child: Center(
                        child: Obx(() => Text(
                          searchFilterController.endValueText,
                          style: AppStyle.heading5Medium(color: AppColor.textColor),
                        )),
                      ),
                    ),
                  ),
                ],
              ).paddingOnly(
                top: AppSize.appSize18,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
              Text(
                AppString.typesOfProperty,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(searchFilterController.propertyTypeList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      searchFilterController.updateTypesOfProperty(index);
                    },
                    child: Obx(() => Container(
                      margin: const EdgeInsets.only(bottom: AppSize.appSize6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: searchFilterController.selectTypesOfProperty.value == index
                              ? AppColor.primaryColor
                              : AppColor.borderColor,
                          width: AppSize.appSize1,
                        ),
                      ),
                      child: Text(
                        searchFilterController.propertyTypeList[index],
                        style: AppStyle.heading5Medium(
                          color: searchFilterController.selectTypesOfProperty.value == index
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    )),
                  );
                }),
              ).paddingOnly(
                top: AppSize.appSize16,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
              Text(
                AppString.viewAllAdd,
                style: AppStyle.heading6Medium(
                  color: AppColor.primaryColor,
                ),
              ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
              Text(
                AppString.noOfBedrooms,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: AppSize.appSize16),
                child: Row(
                  children: List.generate(searchFilterController.bedroomsList.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        searchFilterController.updateBedrooms(index);
                      },
                      child: Obx(() => Container(
                        margin: const EdgeInsets.only(right: AppSize.appSize16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize16, vertical: AppSize.appSize10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                          border: Border.all(
                            color: searchFilterController.selectBedrooms.value == index
                                ? AppColor.primaryColor
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            searchFilterController.bedroomsList[index],
                            style: AppStyle.heading5Medium(
                              color: searchFilterController.selectBedrooms.value == index
                                  ? AppColor.primaryColor
                                  : AppColor.descriptionColor,
                            ),
                          ),
                        ),
                      )),
                    );
                  }),
                ).paddingOnly(top: AppSize.appSize16),
              ),
              Text(
                AppString.lookingForReadyToMove,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
              Row(
                children: List.generate(searchFilterController.propertyLookingForList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      searchFilterController.updateLookingFor(index);
                    },
                    child: Obx(() => Container(
                      width: AppSize.appSize75,
                      margin: const EdgeInsets.only(right: AppSize.appSize16),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSize.appSize10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: searchFilterController.selectLookingFor.value == index
                              ? AppColor.primaryColor
                              : AppColor.borderColor,
                          width: AppSize.appSize1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          searchFilterController.propertyLookingForList[index],
                          style: AppStyle.heading5Medium(
                            color: searchFilterController.selectLookingFor.value == index
                                ? AppColor.primaryColor
                                : AppColor.descriptionColor,
                          ),
                        ),
                      ),
                    )),
                  );
                }),
              ).paddingOnly(
                top: AppSize.appSize16,
                left: AppSize.appSize16, right: AppSize.appSize16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _searchContent() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              color: AppColor.whiteColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: AppSize.appSizePoint1,
                  blurRadius: AppSize.appSize2,
                ),
              ],
            ),
            child: TextFormField(
              controller: searchFilterController.searchController,
              cursorColor: AppColor.primaryColor,
              style: AppStyle.heading4Regular(color: AppColor.textColor),
              decoration: InputDecoration(
                hintText: AppString.searchCity,
                hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSize.appSize16, right: AppSize.appSize16,
                  ),
                  child: Image.asset(
                    Assets.images.search.path,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  maxWidth: AppSize.appSize51,
                ),
              ),
            ),
          ),
          Text(
            AppString.recentSearched,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize26),
          Row(
            children: List.generate(searchFilterController.recentSearchedList.length, (index) {
              return Container(
                margin: const EdgeInsets.only(right: AppSize.appSize16),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSize.appSize10, horizontal: AppSize.appSize14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  border: Border.all(
                    color: AppColor.borderColor,
                    width: AppSize.appSize1,
                  ),
                ),
                child: Center(
                  child: Text(
                    searchFilterController.recentSearchedList[index],
                    style: AppStyle.heading5Medium(
                      color: AppColor.descriptionColor,
                    ),
                  ),
                ),
              );
            }),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            AppString.suggestions,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize26),
          Wrap(
            runSpacing: AppSize.appSize6,
            children: List.generate(searchFilterController.recentSearched2List.length, (index) {
              return Container(
                margin: const EdgeInsets.only(right: AppSize.appSize16),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSize.appSize10, horizontal: AppSize.appSize14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  border: Border.all(
                    color: AppColor.borderColor,
                    width: AppSize.appSize1,
                  ),
                ),
                child: Text(
                  searchFilterController.recentSearched2List[index],
                  style: AppStyle.heading5Medium(
                    color: AppColor.descriptionColor,
                  ),
                ),
              );
            }),
          ).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
    );
  }
}
