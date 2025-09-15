import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/helper/string_format_helper.dart';
import 'package:ovoride_driver/core/utils/style.dart';
import 'package:ovoride_driver/presentation/components/custom_no_data_found_class.dart';
import 'package:ovoride_driver/presentation/screens/subscription/widget/subscription_payment_card.dart';

import '../../../core/helper/date_converter.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/subscription/subscription_payment_controller.dart';
import '../../../data/repo/subscription/subscription_payment_repo.dart';
import '../../components/custom_loader/custom_loader.dart';

class SubscriptionPaymentHistoryScreen extends StatefulWidget {
  const SubscriptionPaymentHistoryScreen({super.key});

  @override
  State<SubscriptionPaymentHistoryScreen> createState() => _SubscriptionPaymentHistoryScreenState();
}

class _SubscriptionPaymentHistoryScreenState extends State<SubscriptionPaymentHistoryScreen> {
  final ScrollController scrollController = ScrollController();

  void fetchData() {
    Get.find<SubscriptionPaymentController>().loadMorePayments();
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<SubscriptionPaymentController>().hasNextPage()) {
        fetchData();
      }
    }
  }

  @override
  void initState() {
    Get.put(SubscriptionPaymentRepo(apiClient: Get.find()));
    final controller = Get.put(SubscriptionPaymentController(repo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadPaymentHistory(isRefresh: true);
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
    return GetBuilder<SubscriptionPaymentController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppBar(
          title: Text(MyStrings.subscriptionPaymentHistory.tr, style: regularDefault.copyWith(color: MyColor.colorWhite)),
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
            const SizedBox(width: Dimensions.space15),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : Padding(
                padding: const EdgeInsets.only(top: Dimensions.space20, left: Dimensions.space15, right: Dimensions.space15),
                child: Column(
                  children: [
                    Expanded(
                      child: controller.paymentList.isEmpty
                          ? NoDataOrInternetScreen(
                              message: MyStrings.noSubscriptionPaymentFound.tr,
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: ListView.separated(
                                shrinkWrap: true,
                                controller: scrollController,
                                scrollDirection: Axis.vertical,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: controller.paymentList.length + 1,
                                separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                                itemBuilder: (context, index) {
                                  if (controller.paymentList.length == index) {
                                    return controller.hasNextPage()
                                        ? SizedBox(
                                            height: 40,
                                            width: MediaQuery.of(context).size.width,
                                            child: const Center(child: CustomLoader()),
                                          )
                                        : const SizedBox();
                                  }
                                  final payment = controller.paymentList[index];
                                  return SubscriptionPaymentCard(
                                    onPressed: () {
                                      // Mostrar detalhes do pagamento
                                      _showPaymentDetails(context, payment);
                                    },
                                    payment: payment,
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

  void _showPaymentDetails(BuildContext context, payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: MyColor.colorWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.space20),
            topRight: Radius.circular(Dimensions.space20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: Dimensions.space10),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: MyColor.colorGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.all(Dimensions.space20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MyStrings.subscriptionPaymentDetails.tr,
                          style: regularLarge.copyWith(
                            color: MyColor.colorBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: Dimensions.space5),
                        Text(
                          payment.trx ?? '',
                          style: regularDefault.copyWith(
                            color: MyColor.colorGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space12,
                      vertical: Dimensions.space6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(payment.status ?? ''),
                      borderRadius: BorderRadius.circular(Dimensions.space15),
                    ),
                    child: Text(
                      _getStatusText(payment.status ?? ''),
                      style: regularSmall.copyWith(
                        color: MyColor.colorWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(MyStrings.amount.tr, '${StringConverter.formatNumber(payment.amount ?? '0')} ${Get.find<SubscriptionPaymentController>().curSymbol}'),
                    _buildDetailRow(MyStrings.charge.tr, '${StringConverter.formatNumber(payment.charge ?? '0')} ${Get.find<SubscriptionPaymentController>().curSymbol}'),
                    _buildDetailRow(MyStrings.finalAmount.tr, '${StringConverter.formatNumber(payment.finalAmount ?? '0')} ${Get.find<SubscriptionPaymentController>().curSymbol}'),
                    _buildDetailRow(MyStrings.date.tr, _formatDate(payment.createdAt ?? '')),
                    if (payment.gateway?.name != null)
                      _buildDetailRow('Gateway', payment.gateway!.name!),
                    if (payment.detail != null && payment.detail!.isNotEmpty)
                      _buildDetailRow(MyStrings.details.tr, payment.detail!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: regularDefault.copyWith(color: MyColor.colorGrey),
          ),
          Text(
            value,
            style: regularDefault.copyWith(
              color: MyColor.colorBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'success':
        return MyStrings.succeed.tr;
      case 'pending':
        return MyStrings.pending.tr;
      case 'initiated':
        return MyStrings.initiated.tr;
      case 'rejected':
        return MyStrings.rejected.tr;
      default:
        return 'Desconhecido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return MyColor.greenSuccessColor;
      case 'pending':
        return MyColor.pendingColor;
      case 'initiated':
        return MyColor.colorGrey;
      case 'rejected':
        return MyColor.redCancelTextColor;
      default:
        return MyColor.colorGrey;
    }
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateConverter.estimatedDate(dateTime, formatType: DateFormatType.onlyDate);
    } catch (e) {
      return date;
    }
  }
}
