import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/helper/string_format_helper.dart';
import 'package:ovoride_driver/core/utils/dimensions.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/core/utils/style.dart';
import 'package:ovoride_driver/data/controller/subscription/subscription_controller.dart';

class SubscriptionBottomSheet {
  static void subscriptionBottomSheet(BuildContext context, int index) {
    final controller = Get.find<SubscriptionController>();
    final subscription = controller.subscriptionList[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                          MyStrings.subscriptionDetails.tr,
                          style: regularLarge.copyWith(
                            color: MyColor.colorBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: Dimensions.space5),
                        Text(
                          subscription.service?.name ?? 'Serviço',
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
                      color: _getStatusColor(subscription.status ?? ''),
                      borderRadius: BorderRadius.circular(Dimensions.space15),
                    ),
                    child: Text(
                      _getStatusText(subscription.status ?? ''),
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
                    // Informações básicas
                    _buildSection(
                      MyStrings.subscriptionInfo.tr,
                      [
                        _buildInfoRow(MyStrings.subscriptionType.tr, _getPaymentTypeText(subscription.paymentType ?? '')),
                        _buildInfoRow(MyStrings.subscriptionAmount.tr, '${StringConverter.formatNumber(subscription.amount ?? '0')} ${controller.curSymbol}'),
                        _buildInfoRow(MyStrings.totalPaid.tr, '${StringConverter.formatNumber(subscription.paidAmount ?? '0')} ${controller.curSymbol}'),
                        _buildInfoRow(MyStrings.totalRemaining.tr, controller.getRemainingAmount(subscription)),
                        if (subscription.startDate != null)
                          _buildInfoRow(MyStrings.subscriptionDate.tr, _formatDate(subscription.startDate!)),
                        if (subscription.endDate != null)
                          _buildInfoRow(MyStrings.subscriptionExpiry.tr, _formatDate(subscription.endDate!)),
                      ],
                    ),
                    
                    // Progresso do pagamento
                    if (subscription.amount != null && subscription.paidAmount != null)
                      _buildSection(
                        MyStrings.paymentProgress.tr,
                        [
                          Container(
                            padding: const EdgeInsets.all(Dimensions.space15),
                            decoration: BoxDecoration(
                              color: MyColor.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(Dimensions.space8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${controller.getPaidAmount(subscription)} / ${controller.getTotalAmount(subscription)}',
                                      style: regularDefault.copyWith(
                                        color: MyColor.colorBlack,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${controller.getPaymentProgress(subscription).toStringAsFixed(1)}%',
                                      style: regularDefault.copyWith(
                                        color: MyColor.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.space10),
                                LinearProgressIndicator(
                                  value: controller.getPaymentProgress(subscription) / 100,
                                  backgroundColor: MyColor.colorGrey.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    controller.getPaymentProgress(subscription) >= 100 
                                        ? MyColor.greenSuccessColor 
                                        : MyColor.primaryColor,
                                  ),
                                  minHeight: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    
                    // Informações específicas para pagamento diluído
                    if (subscription.paymentType == 'monthly_ride_based')
                      _buildSection(
                        MyStrings.monthlyRideBased.tr,
                        [
                          if (subscription.targetRides != null)
                            _buildInfoRow(MyStrings.targetRides.tr, subscription.targetRides!),
                          if (subscription.completedRides != null)
                            _buildInfoRow(MyStrings.completedRides.tr, subscription.completedRides!),
                          if (subscription.perRideAmount != null)
                            _buildInfoRow(MyStrings.perRideAmount.tr, '${StringConverter.formatNumber(subscription.perRideAmount!)} ${controller.curSymbol}'),
                        ],
                      ),
                    
                    // Observações
                    if (subscription.notes != null && subscription.notes!.isNotEmpty)
                      _buildSection(
                        MyStrings.remark.tr,
                        [
                          Container(
                            padding: const EdgeInsets.all(Dimensions.space15),
                            decoration: BoxDecoration(
                              color: MyColor.colorGrey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(Dimensions.space8),
                            ),
                            child: Text(
                              subscription.notes!,
                              style: regularDefault.copyWith(color: MyColor.colorBlack),
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: Dimensions.space20),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(Dimensions.space20),
              child: Row(
                children: [
                  if (subscription.status == 'active')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          // Navegar para tela de pagamento
                          // Get.toNamed(RouteHelper.subscriptionPaymentScreen, arguments: subscription);
                        },
                        icon: const Icon(Icons.payment, size: 18),
                        label: Text(MyStrings.subscriptionPayment.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColor.primaryColor,
                          foregroundColor: MyColor.colorWhite,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.space12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Dimensions.space8),
                          ),
                        ),
                      ),
                    ),
                  if (subscription.status == 'active')
                    const SizedBox(width: Dimensions.space10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        // Navegar para histórico de pagamentos
                        // Get.toNamed(RouteHelper.subscriptionPaymentHistoryScreen, arguments: subscription);
                      },
                      icon: const Icon(Icons.history, size: 18),
                      label: Text(MyStrings.subscriptionPaymentHistory.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MyColor.primaryColor,
                        side: const BorderSide(color: MyColor.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.space12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.space8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: regularDefault.copyWith(
              color: MyColor.colorBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Dimensions.space10),
          ...children,
        ],
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space8),
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

  static String _getPaymentTypeText(String paymentType) {
    switch (paymentType) {
      case 'monthly_full':
        return MyStrings.monthlyFull.tr;
      case 'monthly_ride_based':
        return MyStrings.monthlyRideBased.tr;
      case 'yearly_full':
        return MyStrings.yearlyFull.tr;
      default:
        return 'Desconhecido';
    }
  }

  static String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return MyStrings.subscriptionActive.tr;
      case 'inactive':
        return MyStrings.subscriptionInactive.tr;
      case 'expired':
        return MyStrings.subscriptionExpired.tr;
      case 'cancelled':
        return MyStrings.subscriptionCancelled.tr;
      default:
        return 'Desconhecido';
    }
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return MyColor.greenSuccessColor;
      case 'inactive':
        return MyColor.colorGrey;
      case 'expired':
        return MyColor.redCancelTextColor;
      case 'cancelled':
        return MyColor.redCancelTextColor;
      default:
        return MyColor.colorGrey;
    }
  }

  static String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}
