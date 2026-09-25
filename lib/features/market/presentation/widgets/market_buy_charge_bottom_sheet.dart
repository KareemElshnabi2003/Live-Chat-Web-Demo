// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/Constant/app_images.dart';
import 'package:live_chat/features/market/data/datasources/stars_service.dart';

import 'package:live_chat/core/widgets/loading.dart';
import 'package:live_chat/core/widgets/message_success_send_stars.dart';
import 'package:live_chat/core/widgets/text_click_widget.dart';
import 'package:live_chat/core/widgets/text_field_widget.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/chat/presentation/widgets/button.dart';
import 'package:live_chat/main.dart';

import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

// Models for payment data
class PaymentOption {
  final int stars;
  final int price;

  PaymentOption({required this.stars, required this.price});

  factory PaymentOption.fromJson(Map<String, dynamic> json) {
    return PaymentOption(
      stars: json['stars'] ?? 0,
      price: json['price'] ?? 0,
    );
  }
}

class PaymentMethod {
  final int id;
  final String name;
  final Map<String, dynamic> data;

  PaymentMethod({required this.id, required this.name, required this.data});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : {},
    );
  }
}

// Helper function to get the appropriate label based on payment method
String _getPaymentAddressLabel(String paymentMethod) {
  final lowerMethod = paymentMethod.toLowerCase();

  if (lowerMethod.contains('vodafone') || lowerMethod.contains('etisalat')) {
    return 'Phone Number';
  } else if (lowerMethod.contains('instapay')) {
    return 'IPN (InstaPay Number)';
  } else {
    return 'Payment Address/Number';
  }
}

// Helper function to get the appropriate keyboard type
TextInputType _getPaymentAddressKeyboardType(String paymentMethod) {
  final lowerMethod = paymentMethod.toLowerCase();

  if (lowerMethod.contains('vodafone') ||
      lowerMethod.contains('etisalat') ||
      lowerMethod.contains('instapay')) {
    return TextInputType.number;
  } else {
    return TextInputType.text;
  }
}

void showBottomSheetMarketBuyChargeWidget({required BuildContext context}) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: kIsWeb ? 600 : double.infinity),
    backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
    context: context,
    builder: (ctx) => const _MarketBuyChargeSheetContent(),
  );
}

class _MarketBuyChargeSheetContent extends StatefulWidget {
  const _MarketBuyChargeSheetContent();

  @override
  State<_MarketBuyChargeSheetContent> createState() =>
      _MarketBuyChargeSheetContentState();
}

class _MarketBuyChargeSheetContentState
    extends State<_MarketBuyChargeSheetContent> {
  String _sheetBuyMarket = "firstPage";
  bool _isLoading = false;

  // Controllers for send stars
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numOfStarsController = TextEditingController();

  // Payment flow state
  List<PaymentOption> _paymentOptions = [];
  final List<PaymentOption> _selectedOptions = [];
  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _selectedPaymentMethod;
  Uint8List? _selectedImageBytes;
  int _totalStars = 0;
  int _totalPrice = 0;

  // Controller for payment address field
  final TextEditingController _paymentAddressController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _numOfStarsController.dispose();
    _paymentAddressController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _sheetBuyMarket == "sendStarsPage"
            ? 45.h
            : _sheetBuyMarket == "paymentOptionsPage"
                ? 75.h
                : _sheetBuyMarket == "paymentMethodsPage"
                    ? 70.h
                    : _sheetBuyMarket == "uploadReceiptPage"
                        ? 75.h
                        : 55.h,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 4,
                width: 70,
                color: pref! ? AppColors.whiteColor : AppColors.blackColor,
              ),
              Container(
                padding: EdgeInsets.only(
                  right: 4.w,
                  left: 4.w,
                  top: 4.w,
                ),
                width: 100.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back/Close button
                    Row(
                      mainAxisAlignment: isRtl
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        textClick(
                          _sheetBuyMarket != "firstPage"
                              ? S.of(context).back
                              : S.of(context).close,
                          true,
                          () {
                            if (_sheetBuyMarket == "firstPage") {
                              Navigator.pop(context);
                            } else if (_sheetBuyMarket == "sendStarsPage") {
                              setState(() => _sheetBuyMarket = "firstPage");
                            } else if (_sheetBuyMarket == "paymentOptionsPage") {
                              setState(() => _sheetBuyMarket = "firstPage");
                            } else if (_sheetBuyMarket == "paymentMethodsPage") {
                              setState(() => _sheetBuyMarket = "paymentOptionsPage");
                            } else if (_sheetBuyMarket == "uploadReceiptPage") {
                              setState(() => _sheetBuyMarket = "paymentMethodsPage");
                            }
                          },
                          pref! ? AppColors.whiteColor : AppColors.blackColor,
                          3.5.w,
                        ),
                      ],
                    ),

                    // First Page - Main Menu
                    if (_sheetBuyMarket == "firstPage") ...[
                      SizedBox(
                        height: 40.w,
                        width: 100.w,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 25.w,
                              right: 20.w,
                              child: Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(AppImages.starFillImg),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 25.w,
                              left: 18.w,
                              child: Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(AppImages.starImg),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      textNormal(
                        S.of(context).buyOrSendStars,
                        pref!
                            ? AppColors.whiteColor
                            : AppColors.blackTextColor,
                        3.5.w,
                        FontWeight.w400,
                      ),
                      SizedBox(height: 3.h),
                      Button(
                        text: S.of(context).send,
                        ontap: () {
                          setState(() => _sheetBuyMarket = "sendStarsPage");
                        },
                      ),
                      SizedBox(height: 1.5.h),
                      _isLoading
                          ? loading(5.h)
                          : Button(
                              text: S.of(context).purchase,
                              ontap: () async {
                                try {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  final service = StarsPurchaseService();
                                  final response =
                                      await service.getPaymentOptions();

                                  if (response != null && response is List && response.isNotEmpty) {
                                    setState(() {
                                      _paymentOptions = response
                                          .map((e) => PaymentOption.fromJson(e))
                                          .toList();
                                      _selectedOptions.clear();
                                      _totalStars = 0;
                                      _totalPrice = 0;
                                      _isLoading = false;
                                      _sheetBuyMarket = "paymentOptionsPage";
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    _showError(S.of(context).somethingWentWrong);
                                  }
                                } catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  _showError(e.toString());
                                }
                              },
                            ),
                    ],

                    // Send Stars Page
                    if (_sheetBuyMarket == "sendStarsPage") ...[
                      SizedBox(
                        height: 40.w,
                        width: 100.w,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 25.w,
                              right: 20.w,
                              child: Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(AppImages.starFillImg),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 25.w,
                              left: 18.w,
                              child: Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(AppImages.starImg),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      textNormal(
                        S.of(context).buyOrSendStars,
                        pref!
                            ? AppColors.whiteColor
                            : AppColors.blackTextColor,
                        3.5.w,
                        FontWeight.w400,
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        height: 6.h,
                        child: textFieldWidget(
                          _nameController,
                          S.of(context).email,
                          false,
                          false,
                          null,
                          TextInputType.text,
                          null,
                          null,
                          textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      SizedBox(
                        height: 6.h,
                        child: textFieldWidget(
                          _numOfStarsController,
                          S.of(context).numberOfStars,
                          false,
                          false,
                          null,
                          TextInputType.number,
                          null,
                          null,
                          textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      Button(
                        text: S.of(context).send,
                        ontap: () async {
                          final starsService = StarsService();
                          final response = await starsService.sendStars(
                            _nameController.text.trim(),
                            _numOfStarsController.text.trim(),
                          );
                          if (response['status'] == 'success') {
                            Navigator.pop(context);
                            messageSuccessSendStars(context);
                          } else {
                            _showError(response['message'] ?? S.of(context).somethingWentWrong);
                          }
                        },
                      ),
                    ],

                    // Payment Options Page
                    if (_sheetBuyMarket == "paymentOptionsPage") ...[
                      SizedBox(height: 2.h),
                      textNormal(
                        S.of(context).selectStarsPackages,
                        pref!
                            ? AppColors.whiteColor
                            : AppColors.blackTextColor,
                        4.w,
                        FontWeight.w600,
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        height: 45.h,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 3.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 2,
                          ),
                          itemCount: _paymentOptions.length,
                          itemBuilder: (context, index) {
                            final option = _paymentOptions[index];
                            final isSelected =
                                _selectedOptions.contains(option);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedOptions.remove(option);
                                    _totalStars -= option.stars;
                                    _totalPrice -= option.price;
                                  } else {
                                    _selectedOptions.add(option);
                                    _totalStars += option.stars;
                                    _totalPrice += option.price;
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                          .withOpacity(0.3)
                                      : (pref!
                                          ? Colors.grey.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    textNormal(
                                      "${option.stars} Stars",
                                      pref!
                                          ? AppColors.whiteColor
                                          : AppColors.blackTextColor,
                                      3.5.w,
                                      FontWeight.w600,
                                    ),
                                    SizedBox(height: 0.5.h),
                                    textNormal(
                                      "${option.price} EGP",
                                      pref!
                                          ? AppColors.whiteColor
                                          : AppColors.blackTextColor,
                                      3.w,
                                      FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_selectedOptions.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: pref!
                                ? Colors.grey.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              textNormal(
                                S.of(context).totalStars(_totalStars),
                                pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackTextColor,
                                3.5.w,
                                FontWeight.w600,
                              ),
                              textNormal(
                                "$_totalPrice EGP",
                                AppColors.primaryColor,
                                3.5.w,
                                FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 2.h),
                      _isLoading
                          ? loading(5.h)
                          : Button(
                              text: S.of(context).next,
                              ontap: _selectedOptions.isEmpty
                                  ? null
                                  : () async {
                                      try {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        final service = StarsPurchaseService();
                                        final response =
                                            await service.getPaymentMethods();

                                        if (response != null &&
                                            response is List &&
                                            response.isNotEmpty) {
                                          setState(() {
                                            _paymentMethods = response
                                                .map((e) => PaymentMethod.fromJson(e))
                                                .toList();
                                            _selectedPaymentMethod = null;
                                            _isLoading = false;
                                            _sheetBuyMarket = "paymentMethodsPage";
                                          });
                                        } else {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          _showError(S.of(context).somethingWentWrong);
                                        }
                                      } catch (e) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        _showError(e.toString());
                                      }
                                    },
                            ),
                    ],

                    // Payment Methods Page
                    if (_sheetBuyMarket == "paymentMethodsPage") ...[
                      SizedBox(height: 2.h),
                      textNormal(
                        S.of(context).selectPaymentMethod,
                        pref!
                            ? AppColors.whiteColor
                            : AppColors.blackTextColor,
                        4.w,
                        FontWeight.w600,
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        height: 45.h,
                        child: ListView.builder(
                          itemCount: _paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = _paymentMethods[index];
                            final isSelected =
                                _selectedPaymentMethod == method;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPaymentMethod = method;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 2.h),
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                          .withOpacity(0.3)
                                      : (pref!
                                          ? Colors.grey.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    textNormal(
                                      method.name,
                                      pref!
                                          ? AppColors.whiteColor
                                          : AppColors.blackTextColor,
                                      4.w,
                                      FontWeight.w600,
                                    ),
                                    SizedBox(height: 1.h),
                                    ...method.data.entries.map((entry) {
                                      return Padding(
                                        padding:
                                            EdgeInsets.only(bottom: 0.5.h),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            textNormal(
                                              "${entry.key}:",
                                              pref!
                                                  ? AppColors.whiteColor
                                                      .withOpacity(0.7)
                                                  : AppColors.blackTextColor
                                                      .withOpacity(0.7),
                                              3.w,
                                              FontWeight.w400,
                                            ),
                                            Expanded(
                                              child: textNormal(
                                                entry.value.toString(),
                                                pref!
                                                    ? AppColors.whiteColor
                                                    : AppColors
                                                        .blackTextColor,
                                                3.w,
                                                FontWeight.w500,
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Button(
                        text: S.of(context).next,
                        ontap: _selectedPaymentMethod == null
                            ? null
                            : () {
                                _paymentAddressController.clear();
                                setState(() {
                                  _sheetBuyMarket = "uploadReceiptPage";
                                });
                              },
                      ),
                    ],

                    // Upload Receipt Page
                    if (_sheetBuyMarket == "uploadReceiptPage") ...[
                      SizedBox(height: 2.h),
                      textNormal(
                        S.of(context).uploadPaymentReceipt,
                        pref!
                            ? AppColors.whiteColor
                            : AppColors.blackTextColor,
                        4.w,
                        FontWeight.w600,
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: pref!
                              ? Colors.grey.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            textNormal(
                              S.of(context).paymentDetails,
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.blackTextColor,
                              3.5.w,
                              FontWeight.w600,
                            ),
                            SizedBox(height: 1.h),
                            textNormal(
                              S.of(context).starsCount(_totalStars),
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.blackTextColor,
                              3.w,
                              FontWeight.w400,
                            ),
                            textNormal(
                              S.of(context).priceAmount(_totalPrice),
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.blackTextColor,
                              3.w,
                              FontWeight.w400,
                            ),
                            textNormal(
                              "${S.of(context).paymentMethod}: ${_selectedPaymentMethod?.name}",
                              pref!
                                  ? AppColors.whiteColor
                                  : AppColors.blackTextColor,
                              3.w,
                              FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Payment Address TextField
                      SizedBox(
                        height: 6.h,
                        child: textFieldWidget(
                          _paymentAddressController,
                          _getPaymentAddressLabel(
                              _selectedPaymentMethod?.name ?? ""),
                          false,
                          false,
                          null,
                          _getPaymentAddressKeyboardType(
                              _selectedPaymentMethod?.name ?? ""),
                          null,
                          null,
                          textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setState(() {
                              _selectedImageBytes = bytes;
                            });
                          }
                        },
                        child: Container(
                          height: 20.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: pref!
                                ? Colors.grey.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _selectedImageBytes == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 10.w,
                                      color: pref!
                                          ? AppColors.whiteColor
                                          : AppColors.blackTextColor,
                                    ),
                                    SizedBox(height: 1.h),
                                    textNormal(
                                      S.of(context).tapToUploadReceipt,
                                      pref!
                                          ? AppColors.whiteColor
                                          : AppColors.blackTextColor,
                                      3.w,
                                      FontWeight.w400,
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      _isLoading
                          ? loading(5.h)
                          : Button(
                              text: S.of(context).finish,
                              ontap: (_selectedImageBytes == null ||
                                      _paymentAddressController.text
                                          .trim()
                                          .isEmpty)
                                  ? null
                                  : () async {
                                      try {
                                        setState(() {
                                          _isLoading =
                                              true;
                                        });

                                        final service = StarsPurchaseService();
                                        String paymentAddress =
                                            _paymentAddressController.text
                                                .trim();

                                        final response =
                                            await service.submitManualPayment(
                                          image: _selectedImageBytes,
                                          price: _totalPrice,
                                          paymentAddress: paymentAddress,
                                          paymentType:
                                              _selectedPaymentMethod!.name,
                                          stars: _totalStars,
                                        );

                                        setState(() {
                                          _isLoading = false;
                                        });

                                        if (response != null &&
                                            response['status'] == 'success') {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: pref!
                                                  ? AppColors.blackColor
                                                  : AppColors.whiteColor,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 24),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 60,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    S
                                                        .of(context)
                                                        .orderUnderReview,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: pref!
                                                          ? AppColors.whiteColor
                                                          : AppColors
                                                              .blackTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(ctx);
                                                  },
                                                  child: Text(
                                                    S.of(context).ok,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          _showError(
                                            response?['message'] ??
                                                S
                                                    .of(context)
                                                    .somethingWentWrong,
                                          );
                                        }
                                      } catch (e) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        _showError(e.toString());
                                      }
                                    },
                            ),
                    ],

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
