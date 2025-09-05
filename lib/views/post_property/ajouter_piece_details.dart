import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/ajouter_piece_details_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class RoomDetailsView extends StatelessWidget {
  RoomDetailsView({super.key});

  final RoomDetailsController roomDetailsController =
      Get.put(RoomDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildRoomDetailsFields(),
      bottomNavigationBar: buildButton(context),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      scrolledUnderElevation: AppSize.appSize0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Image.asset(Assets.images.backArrow.path),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Text(
        'Détails des pièces',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildRoomDetailsFields() {
    return Column(
      children: [
        // Header with add room button
        Padding(
          padding: const EdgeInsets.all(AppSize.appSize16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pièces du bien',
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () => roomDetailsController.addRoom(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize12,
                    vertical: AppSize.appSize8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: AppColor.whiteColor,
                        size: AppSize.appSize16,
                      ),
                      const SizedBox(width: AppSize.appSize4),
                      Text(
                        'Ajouter',
                        style:
                            AppStyle.heading6Medium(color: AppColor.whiteColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Rooms list
        Expanded(
          child: Obx(() {
            return ListView.builder(
              padding: const EdgeInsets.only(
                left: AppSize.appSize16,
                right: AppSize.appSize16,
                bottom: AppSize.appSize20,
              ),
              itemCount: roomDetailsController.rooms.length,
              itemBuilder: (context, index) {
                return buildRoomCard(index);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget buildRoomCard(int roomIndex) {
    final room = roomDetailsController.rooms[roomIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSize.appSize16),
      padding: const EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: AppColor.descriptionColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header with room number and delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pièce ${roomIndex + 1}',
                style: AppStyle.heading5Medium(color: AppColor.textColor),
              ),
              if (roomDetailsController.rooms.length > 1)
                GestureDetector(
                  onTap: () => roomDetailsController.removeRoom(roomIndex),
                  child: Container(
                    padding: const EdgeInsets.all(AppSize.appSize4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize6),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: AppSize.appSize18,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSize.appSize16),

          // Room type dropdown (required)
          buildRoomTypeDropdown(
            label: 'Type de pièce',
            hint: 'Sélectionnez le type',
            selectedType: room.selectedType,
            onChanged: (type) =>
                roomDetailsController.updateRoomType(roomIndex, type),
            required: true,
          ),

          const SizedBox(height: AppSize.appSize12),

          // Room name (optional)
          buildTextField(
            controller: room.nomController,
            focusNode: room.nomFocusNode,
            label: 'Nom de la pièce',
            hint: 'Ex: Chambre parentale (optionnel)',
            hasInput: room.nomHasInput,
            required: false,
          ),

          const SizedBox(height: AppSize.appSize12),

          // Surface (required)
          buildTextField(
            controller: room.surfaceController,
            focusNode: room.surfaceFocusNode,
            label: 'Surface',
            hint: 'Ex: 15 m²',
            hasInput: room.surfaceHasInput,
            required: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),

          const SizedBox(height: AppSize.appSize12),

          // Row with orientation and level
          Row(
            children: [
              Expanded(
                child: buildDropdownField(
                  label: 'Orientation',
                  hint: 'Optionnel',
                  value: RxString(room.orientationController.text),
                  options: roomDetailsController.orientationOptions,
                  onChanged: (value) {
                    room.orientationController.text = value ?? '';
                    room.orientationHasInput.value = value?.isNotEmpty ?? false;
                  },
                  required: false,
                ),
              ),
              const SizedBox(width: AppSize.appSize12),
              Expanded(
                child: buildTextField(
                  controller: room.niveauController,
                  focusNode: room.niveauFocusNode,
                  label: 'Niveau',
                  hint: 'Ex: 1 (optionnel)',
                  hasInput: room.niveauHasInput,
                  required: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSize.appSize12),

          // Description (optional)
          buildTextField(
            controller: room.descriptionController,
            focusNode: room.descriptionFocusNode,
            label: 'Description',
            hint: 'Ajoutez des détails (optionnel)',
            hasInput: room.descriptionHasInput,
            required: false,
            maxLines: 3,
          ),

          const SizedBox(height: AppSize.appSize16),

          // Boolean options
          Text(
            'Options spéciales',
            style: AppStyle.heading6Medium(color: AppColor.textColor),
          ),

          const SizedBox(height: AppSize.appSize8),

          // Boolean toggles in a grid
          Wrap(
            spacing: AppSize.appSize8,
            runSpacing: AppSize.appSize8,
            children: [
              buildBooleanChip(
                label: 'Avec balcon',
                value: room.avecBalcon,
                onTap: () => roomDetailsController.toggleBalcon(roomIndex),
              ),
              buildBooleanChip(
                label: 'Avec terrasse',
                value: room.avecTerrasse,
                onTap: () => roomDetailsController.toggleTerrasse(roomIndex),
              ),
              buildBooleanChip(
                label: 'Avec dressing',
                value: room.avecDressing,
                onTap: () => roomDetailsController.toggleDressing(roomIndex),
              ),
              buildBooleanChip(
                label: 'SDB privée',
                value: room.avecSalleDeBainPrivee,
                onTap: () =>
                    roomDetailsController.toggleSalleDeBainPrivee(roomIndex),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required RxBool hasInput,
    required bool required,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Obx(() => Container(
          padding: EdgeInsets.only(
            top: hasInput.value ? AppSize.appSize6 : AppSize.appSize14,
            bottom: hasInput.value ? AppSize.appSize8 : AppSize.appSize14,
            left: AppSize.appSize16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            border: Border.all(
              color: hasInput.value || focusNode.hasFocus
                  ? AppColor.primaryColor
                  : AppColor.descriptionColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasInput.value || focusNode.hasFocus)
                Row(
                  children: [
                    Text(
                      label,
                      style: AppStyle.heading6Regular(
                          color: AppColor.primaryColor),
                    ),
                    if (required)
                      Text(
                        ' *',
                        style: AppStyle.heading6Regular(color: Colors.red),
                      ),
                  ],
                ).paddingOnly(bottom: AppSize.appSize2),
              TextFormField(
                controller: controller,
                focusNode: focusNode,
                maxLines: maxLines,
                cursorColor: AppColor.primaryColor,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                style: AppStyle.heading4Regular(color: AppColor.textColor),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintText: (hasInput.value || focusNode.hasFocus) ? '' : hint,
                  hintStyle: AppStyle.heading4Regular(
                      color: AppColor.descriptionColor),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ));
  }

  Widget buildDropdownField({
    required String label,
    required String hint,
    required RxString value,
    required List<String> options,
    required Function(String?) onChanged,
    required bool required,
  }) {
    return Obx(() => Container(
          padding: EdgeInsets.only(
            top: value.value.isNotEmpty ? AppSize.appSize6 : AppSize.appSize14,
            bottom:
                value.value.isNotEmpty ? AppSize.appSize8 : AppSize.appSize14,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            border: Border.all(
              color: value.value.isNotEmpty
                  ? AppColor.primaryColor
                  : AppColor.descriptionColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value.value.isNotEmpty)
                Row(
                  children: [
                    Text(
                      label,
                      style: AppStyle.heading6Regular(
                          color: AppColor.primaryColor),
                    ),
                    if (required)
                      Text(
                        ' *',
                        style: AppStyle.heading6Regular(color: Colors.red),
                      ),
                  ],
                ).paddingOnly(bottom: AppSize.appSize2),
              DropdownButtonFormField<String>(
                value: value.value.isEmpty ? null : value.value,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintText: value.value.isNotEmpty ? '' : hint,
                  hintStyle: AppStyle.heading4Regular(
                      color: AppColor.descriptionColor),
                  border: InputBorder.none,
                ),
                style: AppStyle.heading4Regular(color: AppColor.textColor),
                dropdownColor: AppColor.whiteColor,
                icon: Icon(Icons.keyboard_arrow_down,
                    color: AppColor.descriptionColor),
                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option,
                        style: AppStyle.heading4Regular(
                            color: AppColor.textColor)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ],
          ),
        ));
  }

  Widget buildRoomTypeDropdown({
    required String label,
    required String hint,
    required RxString selectedType,
    required Function(String) onChanged,
    required bool required,
  }) {
    return Obx(() {
      // Get display name for selected type
      String displayValue = selectedType.value.isEmpty
          ? ''
          : (roomDetailsController.roomTypeDisplayNames[selectedType.value] ??
              selectedType.value);

      return Container(
        padding: EdgeInsets.only(
          top: displayValue.isNotEmpty ? AppSize.appSize6 : AppSize.appSize14,
          bottom:
              displayValue.isNotEmpty ? AppSize.appSize8 : AppSize.appSize14,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.appSize12),
          border: Border.all(
            color: displayValue.isNotEmpty
                ? AppColor.primaryColor
                : AppColor.descriptionColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displayValue.isNotEmpty)
              Row(
                children: [
                  Text(
                    label,
                    style:
                        AppStyle.heading6Regular(color: AppColor.primaryColor),
                  ),
                  if (required)
                    Text(
                      ' *',
                      style: AppStyle.heading6Regular(color: Colors.red),
                    ),
                ],
              ).paddingOnly(bottom: AppSize.appSize2),
            DropdownButtonFormField<String>(
              value: selectedType.value.isEmpty ? null : selectedType.value,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintText: displayValue.isNotEmpty ? '' : hint,
                hintStyle:
                    AppStyle.heading4Regular(color: AppColor.descriptionColor),
                border: InputBorder.none,
              ),
              style: AppStyle.heading4Regular(color: AppColor.textColor),
              dropdownColor: AppColor.whiteColor,
              icon: Icon(Icons.keyboard_arrow_down,
                  color: AppColor.descriptionColor),
              items: roomDetailsController.roomTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    roomDetailsController.roomTypeDisplayNames[type] ?? type,
                    style: AppStyle.heading4Regular(color: AppColor.textColor),
                  ),
                );
              }).toList(),
              onChanged: (String? newType) {
                if (newType != null) {
                  onChanged(newType);
                }
              },
            ),
          ],
        ),
      );
    });
  }

  Widget buildBooleanChip({
    required String label,
    required RxBool value,
    required VoidCallback onTap,
  }) {
    return Obx(() => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.appSize12,
              vertical: AppSize.appSize8,
            ),
            decoration: BoxDecoration(
              color: value.value ? AppColor.primaryColor : AppColor.whiteColor,
              borderRadius: BorderRadius.circular(AppSize.appSize20),
              border: Border.all(
                color: value.value
                    ? AppColor.primaryColor
                    : AppColor.descriptionColor,
              ),
            ),
            child: Text(
              label,
              style: AppStyle.heading6Regular(
                color: value.value ? AppColor.whiteColor : AppColor.textColor,
              ),
            ),
          ),
        ));
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Obx(() {
        // Use reactive validation from the controller
        final canProceedNow = roomDetailsController.canProceedValue.value;
        final roomCount = roomDetailsController.rooms.length;

        return CommonButton(
          onPressed: canProceedNow
              ? () {
                  print('🔄 Proceeding to next step from room details...');
                  roomDetailsController.proceedToNextStep();
                }
              : () {
                  // Show why they can't proceed
                  final error = roomDetailsController.getValidationError();
                  if (error != null) {
                    Get.snackbar(
                      'Formulaire incomplet',
                      error,
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                      colorText: AppColor.primaryColor,
                      duration: const Duration(seconds: 3),
                    );
                  }
                },
          backgroundColor: canProceedNow
              ? AppColor.primaryColor
              : AppColor.descriptionColor.withOpacity(0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continuer',
                    style: AppStyle.heading5Medium(
                      color: canProceedNow
                          ? AppColor.whiteColor
                          : AppColor.whiteColor.withOpacity(0.7),
                    ),
                  ),
                  if (canProceedNow) ...[
                    SizedBox(width: AppSize.appSize8),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColor.whiteColor,
                      size: AppSize.appSize18,
                    ),
                  ]
                ],
              ),
              if (roomCount > 0) ...[
                SizedBox(height: AppSize.appSize4),
                Text(
                  '$roomCount pièce${roomCount > 1 ? 's' : ''} ${canProceedNow ? 'validée${roomCount > 1 ? 's' : ''}' : 'à compléter'}',
                  style: AppStyle.heading7Regular(
                    color: canProceedNow
                        ? AppColor.whiteColor.withOpacity(0.8)
                        : AppColor.whiteColor.withOpacity(0.6),
                  ),
                ),
              ]
            ],
          ),
        );
      }),
    ).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
      bottom: AppSize.appSize26,
      top: AppSize.appSize10,
    );
  }
}
