import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_models/customer/mb_customer_address.dart';
import '../controllers/address_controller.dart';

class AddressFormPage extends StatefulWidget {
  final UserAddressModel? address;

  const AddressFormPage({super.key, this.address});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final AddressController controller = Get.find<AddressController>();

  late final TextEditingController fullNameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressLineController;
  late final TextEditingController areaController;
  late final TextEditingController cityController;

  String label = 'Home';
  bool isDefault = false;

  bool get _isAddingNew => widget.address == null;

  bool get _isAreaSupported {
    return controller.isAreaSupported(areaController.text);
  }

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    fullNameController = TextEditingController(text: address?.fullName ?? '');
    phoneController = TextEditingController(text: address?.phoneNumber ?? '');
    addressLineController =
        TextEditingController(text: address?.addressLine ?? '');
    areaController = TextEditingController(text: address?.area ?? '');
    cityController = TextEditingController(text: address?.city ?? 'Dhaka');

    label = address?.label ?? 'Home';
    isDefault = address?.isDefault ?? controller.addresses.isEmpty;

    if (cityController.text.trim().isEmpty) {
      cityController.text = 'Dhaka';
    }

    areaController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressLineController.dispose();
    areaController.dispose();
    cityController.dispose();
    super.dispose();
  }

  void _useProfileInfo() {
    fullNameController.text = controller.profileFullName;
    phoneController.text = controller.profilePhoneDigits;
    setState(() {});
  }

  Future<void> _openAreaPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AreaPickerSheet(
          areas: AddressController.supportedAreas,
          initialValue: areaController.text.trim(),
        );
      },
    );

    if (selected != null && selected.trim().isNotEmpty) {
      areaController.text = selected;
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (fullNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressLineController.text.trim().isEmpty ||
        areaController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty) {
      MBNotification.warning(
        title: 'Missing Info',
        message: 'Please fill all required fields.',
        position: MBNotificationPosition.top,
      );
      return;
    }

    if (!_isAreaSupported) {
      MBNotification.info(
        title: 'Unsupported Area',
        message: 'Soon we will be in your area too!',
        position: MBNotificationPosition.top,
      );
      return;
    }

    final model = UserAddressModel(
      id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      fullName: fullNameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      addressLine: addressLineController.text.trim(),
      area: areaController.text.trim(),
      city: cityController.text.trim(),
      postalCode: '',
      isDefault: isDefault,
    );

    if (widget.address == null) {
      await controller.addAddressWithDelay(model);
    } else {
      await controller.updateAddressWithDelay(model);
    }

    if (mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MBAppLayout(
      backgroundColor: MBColors.background,
      appBar: AppBar(
        title: Text(
          widget.address == null ? 'Add Address' : 'Edit Address',
          style: MBAppText.sectionTitle(context),
        ),
      ),
      child: Obx(() {
        final bool isBusy = controller.isAddressProcessing.value;

        return Stack(
          children: [
            AbsorbPointer(
              absorbing: isBusy,
              child: Padding(
                padding: MBScreenPadding.page(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isAddingNew) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(MBRadius.pill),
                            onTap: _useProfileInfo,
                            child: Ink(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: MBColors.primaryOrange.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(MBRadius.pill),
                                border: Border.all(
                                  color: MBColors.primaryOrange.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                'Use Profile Info',
                                style: MBAppText.caption(context).copyWith(
                                  color: MBColors.primaryOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      MBSpacing.h(MBSpacing.md),
                    ],
                    _field('Full Name', fullNameController),
                    MBSpacing.h(MBSpacing.md),
                    _field(
                      'Phone Number',
                      phoneController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    MBSpacing.h(MBSpacing.md),
                    _field('Address Line', addressLineController, maxLines: 2),
                    MBSpacing.h(MBSpacing.md),
                    GestureDetector(
                      onTap: _openAreaPicker,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: areaController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Area',
                            hintText: 'Select supported area',
                            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                        ),
                      ),
                    ),
                    if (areaController.text.trim().isNotEmpty && !_isAreaSupported) ...[
                      MBSpacing.h(MBSpacing.xs),
                      Text(
                        'Unsupported Area, Soon We will be in your area too!',
                        style: MBAppText.bodySmall(context).copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    MBSpacing.h(MBSpacing.md),
                    _field(
                      'City',
                      cityController,
                      readOnly: true,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: label,
                      items: const [
                        DropdownMenuItem(value: 'Home', child: Text('Home')),
                        DropdownMenuItem(value: 'Office', child: Text('Office')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          label = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Address Label',
                      ),
                    ),
                    //MBSpacing.h(MBSpacing.md),
                    if (_isAddingNew) ...[
                      MBSpacing.h(MBSpacing.md),
                      SwitchListTile(
                        value: isDefault,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Set as default address'),
                        onChanged: (value) {
                          setState(() {
                            isDefault = value;
                          });
                        },
                      ),
                    ],
                    MBSpacing.h(MBSpacing.lg),
                    MBSpacing.h(MBSpacing.lg),
                    MBPrimaryButton(
                      text: widget.address == null ? 'Save Address' : 'Update Address',
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
            if (isBusy)
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
                    child: Container(
                      color: MBColors.background.withValues(alpha: 0.18),
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: MBSpacing.pageHorizontal(context),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: MBSpacing.lg,
                          vertical: MBSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(MBRadius.xl),
                          boxShadow: [
                            BoxShadow(
                              color: MBColors.shadow.withValues(alpha: 0.10),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                color: MBColors.primaryOrange,
                              ),
                            ),
                            MBSpacing.h(MBSpacing.sm),
                            Text(
                              'Please wait...',
                              style: MBAppText.label(context).copyWith(
                                color: MBColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            MBSpacing.h(MBSpacing.xxs),
                            Text(
                              controller.addressProcessingMessage.value.isNotEmpty
                                  ? controller.addressProcessingMessage.value
                                  : 'Saving your address...',
                              textAlign: TextAlign.center,
                              style: MBAppText.bodySmall(context).copyWith(
                                color: MBColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        bool readOnly = false,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }
}

class _AreaPickerSheet extends StatefulWidget {
  final List<String> areas;
  final String initialValue;

  const _AreaPickerSheet({
    required this.areas,
    required this.initialValue,
  });

  @override
  State<_AreaPickerSheet> createState() => _AreaPickerSheetState();
}

class _AreaPickerSheetState extends State<_AreaPickerSheet> {
  late final TextEditingController searchController;
  late List<String> filteredAreas;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.initialValue);
    filteredAreas = _filter(widget.initialValue);

    searchController.addListener(() {
      setState(() {
        filteredAreas = _filter(searchController.text);
      });
    });
  }

  List<String> _filter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return widget.areas;
    return widget.areas
        .where((item) => item.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MBRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            child: Column(
              children: [
                MBSpacing.h(MBSpacing.sm),
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: MBColors.divider,
                    borderRadius: BorderRadius.circular(MBRadius.pill),
                  ),
                ),
                MBSpacing.h(MBSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Select Area',
                          style: MBAppText.sectionTitle(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: MBColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search area',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: searchController.text.trim().isEmpty
                          ? null
                          : IconButton(
                        onPressed: () {
                          searchController.clear();
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredAreas.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Unsupported Area, Soon We will be in your area too!',
                        textAlign: TextAlign.center,
                        style: MBAppText.body(context).copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filteredAreas.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: MBColors.divider.withValues(alpha: 0.65),
                    ),
                    itemBuilder: (context, index) {
                      final area = filteredAreas[index];
                      final bool isSelected =
                          area.toLowerCase() ==
                              widget.initialValue.trim().toLowerCase();

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(MBRadius.lg),
                          onTap: () => Navigator.of(context).pop(area),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(MBRadius.lg),
                              color: isSelected
                                  ? MBColors.primaryOrange
                                  .withValues(alpha: 0.08)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    area,
                                    style: MBAppText.bodySmall(context)
                                        .copyWith(
                                      color: MBColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

