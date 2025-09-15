import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/helper/string_format_helper.dart';
import 'package:ovoride_driver/core/utils/dimensions.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/core/utils/style.dart';
import 'package:ovoride_driver/data/model/subscription/driver_subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final VoidCallback onPressed;
  final DriverSubscriptionModel subscription;
  final String currency;
  final String curSymbol;

  const SubscriptionCard({
    super.key,
    required this.onPressed,
    required this.subscription,
    required this.currency,
    required this.curSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
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
            // Header com status e tipo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.service?.name ?? 'Serviço',
                        style: regularLarge.copyWith(
                          color: MyColor.colorBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space5),
                      Text(
                        _getPaymentTypeText(subscription.paymentType ?? ''),
                        style: regularSmall.copyWith(
                          color: MyColor.colorGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.space8,
                    vertical: Dimensions.space4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(subscription.status ?? ''),
                    borderRadius: BorderRadius.circular(Dimensions.space12),
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
            const SizedBox(height: Dimensions.space15),
            
            // Informações de valor
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    MyStrings.subscriptionAmount.tr,
                    '${StringConverter.formatNumber(subscription.amount ?? '0')} $curSymbol',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    MyStrings.totalPaid.tr,
                    '${StringConverter.formatNumber(subscription.paidAmount ?? '0')} $curSymbol',
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.space10),
            
            // Progresso do pagamento
            if (subscription.amount != null && subscription.paidAmount != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        MyStrings.paymentProgress.tr,
                        style: regularSmall.copyWith(color: MyColor.colorGrey),
                      ),
                      Text(
                        '${_getPaymentProgress().toStringAsFixed(1)}%',
                        style: regularSmall.copyWith(
                          color: MyColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space5),
                  LinearProgressIndicator(
                    value: _getPaymentProgress() / 100,
                    backgroundColor: MyColor.colorGrey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getPaymentProgress() >= 100 
                          ? MyColor.greenSuccessColor 
                          : MyColor.primaryColor,
                    ),
                    minHeight: 4,
                  ),
                ],
              ),
            
            // Informações específicas para pagamento diluído
            if (subscription.paymentType == 'monthly_ride_based' && 
                subscription.targetRides != null && 
                subscription.completedRides != null)
              Container(
                margin: const EdgeInsets.only(top: Dimensions.space10),
                padding: const EdgeInsets.all(Dimensions.space10),
                decoration: BoxDecoration(
                  color: MyColor.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Dimensions.space8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        MyStrings.completedRides.tr,
                        subscription.completedRides ?? '0',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        MyStrings.targetRides.tr,
                        subscription.targetRides ?? '0',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        MyStrings.perRideAmount.tr,
                        '${StringConverter.formatNumber(subscription.perRideAmount ?? '0')} $curSymbol',
                      ),
                    ),
                  ],
                ),
              ),
            
            // Data de expiração
            if (subscription.endDate != null)
              Container(
                margin: const EdgeInsets.only(top: Dimensions.space10),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: MyColor.colorGrey,
                    ),
                    const SizedBox(width: Dimensions.space5),
                    Text(
                      '${MyStrings.subscriptionExpiry.tr}: ${_formatDate(subscription.endDate!)}',
                      style: regularSmall.copyWith(color: MyColor.colorGrey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: regularSmall.copyWith(
            color: MyColor.colorGrey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: Dimensions.space2),
        Text(
          value,
          style: regularDefault.copyWith(
            color: MyColor.colorBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getPaymentTypeText(String paymentType) {
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

  String _getStatusText(String status) {
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

  Color _getStatusColor(String status) {
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

  double _getPaymentProgress() {
    final amount = double.tryParse(subscription.amount ?? '0') ?? 0;
    final paid = double.tryParse(subscription.paidAmount ?? '0') ?? 0;
    if (amount == 0) return 0;
    return (paid / amount) * 100;
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}
