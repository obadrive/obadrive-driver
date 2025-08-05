import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/helper/string_format_helper.dart';
import 'package:ovoride_driver/core/utils/dimensions.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/core/utils/style.dart';
import 'package:ovoride_driver/data/controller/ride/accept_ride/active_ride_controller.dart';
import 'package:ovoride_driver/data/model/global/ride/ride_model.dart';
import 'package:ovoride_driver/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride_driver/presentation/components/bottom-sheet/bottom_sheet_header_row.dart';
import 'package:ovoride_driver/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride_driver/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride_driver/presentation/components/otp_field_widget/otp_field_widget.dart';
import 'package:ovoride_driver/presentation/components/snack_bar/show_custom_snackbar.dart';
import 'package:ovoride_driver/presentation/components/text/header_text.dart';

import '../../../../../core/route/route.dart';

class PickUpBottomSheet extends StatelessWidget {
  final RideModel ride;
  final bool isFromActiveRide;
  const PickUpBottomSheet({super.key, required this.ride, this.isFromActiveRide = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActiveRideController>(builder: (controller) {
      return AnnotatedRegionWidget(
        child: Container(
          color: MyColor.colorWhite,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
          child: Column(
            children: [
              const BottomSheetHeaderRow(),
              HeaderText(text: MyStrings.otpVerificationForPassenger.tr, textStyle: boldLarge.copyWith(color: MyColor.getRideTitleColor(), fontWeight: FontWeight.bold, fontSize: Dimensions.fontOverLarge)),
              spaceDown(Dimensions.space15),
              Column(
                children: [
                  spaceDown(Dimensions.space15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
                    child: OTPFieldWidget(
                      onChanged: (v) {
                        printX(v);
                        controller.otpController.text = v;
                        printX(controller.otpController.text);
                      },
                    ),
                  ),
                  spaceDown(Dimensions.space20),
                  RoundedButton(
                    text: MyStrings.verify.tr.toUpperCase(),
                    color: MyColor.colorBlack,
                    isLoading: controller.selectedRideId == ride.id,
                    textStyle: boldDefault.copyWith(color: MyColor.colorWhite, fontSize: Dimensions.fontLarge),
                    press: () {
                      Get.back();
                      if (controller.otpController.text.isNotEmpty) {
                        if (isFromActiveRide) {
                          Get.toNamed(RouteHelper.rideDetailsScreen, arguments: ride.id ?? '-1');
                          controller.startRide(ride.id ?? '-1');
                        } else {
                          controller.startRide(ride.id ?? '-1');
                        }
                      } else if (controller.otpController.text.length != 6) {
                        CustomSnackBar.error(errorList: [MyStrings.pleaseEnterValidOtpCode.tr]);
                      }
                    },
                    isOutlined: false,
                  ),
                  spaceDown(Dimensions.space20),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
