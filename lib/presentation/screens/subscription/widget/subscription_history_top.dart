import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/utils/dimensions.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/core/utils/style.dart';

class SubscriptionHistoryTop extends StatelessWidget {
  const SubscriptionHistoryTop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: BorderRadius.circular(Dimensions.space8),
        boxShadow: [
          BoxShadow(
            color: MyColor.colorBlack.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MyStrings.searchYourSubscription.tr,
            style: regularDefault.copyWith(
              color: MyColor.colorBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Dimensions.space10),
          TextField(
            decoration: InputDecoration(
              hintText: MyStrings.searchYourSubscription.tr,
              hintStyle: regularDefault.copyWith(color: MyColor.colorGrey),
              prefixIcon: const Icon(Icons.search, color: MyColor.colorGrey, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.space8),
                borderSide: BorderSide(color: MyColor.colorGrey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.space8),
                borderSide: BorderSide(color: MyColor.colorGrey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.space8),
                borderSide: const BorderSide(color: MyColor.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space15,
                vertical: Dimensions.space12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
