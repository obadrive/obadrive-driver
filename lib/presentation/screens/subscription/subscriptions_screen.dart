import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/utils/style.dart';
import 'package:ovoride_driver/presentation/components/custom_no_data_found_class.dart';
import 'package:ovoride_driver/presentation/screens/subscription/widget/subscription_card.dart';
import 'package:ovoride_driver/presentation/screens/subscription/widget/subscription_bottom_sheet.dart';

import '../../../core/route/route.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/subscription/subscription_controller.dart';
import '../../../data/repo/subscription/subscription_repo.dart';
import '../../components/custom_loader/custom_loader.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final ScrollController scrollController = ScrollController();

  void fetchData() {
    Get.find<SubscriptionController>().loadSubscriptions();
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      // Implementar paginação se necessário
      fetchData();
    }
  }

  @override
  void initState() {
    Get.put(SubscriptionRepo(apiClient: Get.find()));
    final controller = Get.put(SubscriptionController(repo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadSubscriptions();
      scrollController.addListener(_scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppBar(
          title: Text(MyStrings.mySubscriptions.tr, style: regularDefault.copyWith(color: MyColor.colorWhite)),
          backgroundColor: MyColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios, color: MyColor.colorWhite, size: 20),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                // Implementar busca se necessário
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.space7),
                decoration: const BoxDecoration(color: MyColor.colorWhite, shape: BoxShape.circle),
                child: const Icon(Icons.search, color: MyColor.primaryColor, size: 15),
              ),
            ),
            const SizedBox(width: Dimensions.space7),
            GestureDetector(
              onTap: () {
                Get.toNamed(RouteHelper.createSubscriptionScreen);
              },
              child: Container(
                margin: const EdgeInsets.only(left: 7, right: 10, bottom: 7, top: 7),
                padding: const EdgeInsets.all(Dimensions.space7),
                decoration: const BoxDecoration(color: MyColor.colorWhite, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: MyColor.primaryColor, size: 15),
              ),
            ),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : Padding(
                padding: const EdgeInsets.only(top: Dimensions.space20, left: Dimensions.space15, right: Dimensions.space15),
                child: Column(
                  children: [
                    // Status de bloqueio se aplicável
                    if (controller.isBlocked)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Dimensions.space15),
                        margin: const EdgeInsets.only(bottom: Dimensions.space15),
                        decoration: BoxDecoration(
                          color: MyColor.redCancelTextColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Dimensions.space8),
                          border: Border.all(color: MyColor.redCancelTextColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.block, color: MyColor.redCancelTextColor, size: 20),
                            const SizedBox(width: Dimensions.space10),
                            Expanded(
                              child: Text(
                                controller.blockReason.isNotEmpty ? controller.blockReason : MyStrings.subscriptionBlockedMessage.tr,
                                style: regularDefault.copyWith(color: MyColor.redCancelTextColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: controller.subscriptionList.isEmpty
                          ? NoDataOrInternetScreen(
                              message: MyStrings.noSubscriptionFound.tr,
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: ListView.separated(
                                shrinkWrap: true,
                                controller: scrollController,
                                scrollDirection: Axis.vertical,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: controller.subscriptionList.length,
                                separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                                itemBuilder: (context, index) {
                                  final subscription = controller.subscriptionList[index];
                                  return SubscriptionCard(
                                    onPressed: () {
                                      SubscriptionBottomSheet.subscriptionBottomSheet(context, index);
                                    },
                                    subscription: subscription,
                                    currency: controller.currency,
                                    curSymbol: controller.curSymbol,
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
