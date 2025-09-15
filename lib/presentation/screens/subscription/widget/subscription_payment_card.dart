import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/helper/string_format_helper.dart';
import 'package:ovoride_driver/core/utils/dimensions.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/core/utils/style.dart';
import 'package:ovoride_driver/data/model/subscription/subscription_payment_model.dart';

class SubscriptionPaymentCard extends StatelessWidget {
  final VoidCallback onPressed;
  final SubscriptionPaymentModel payment;
  final String currency;
  final String curSymbol;

  const SubscriptionPaymentCard({
    super.key,
    required this.onPressed,
    required this.payment,
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
            // Header com status e valor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.gateway?.name ?? 'Gateway',
                        style: regularDefault.copyWith(
                          color: MyColor.colorBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space5),
                      Text(
                        payment.trx ?? '',
                        style: regularSmall.copyWith(
                          color: MyColor.colorGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.space8,
                        vertical: Dimensions.space4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payment.status ?? ''),
                        borderRadius: BorderRadius.circular(Dimensions.space12),
                      ),
                      child: Text(
                        _getStatusText(payment.status ?? ''),
                        style: regularSmall.copyWith(
                          color: MyColor.colorWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.space5),
                    Text(
                      '${StringConverter.formatNumber(payment.amount ?? '0')} $curSymbol',
                      style: regularDefault.copyWith(
                        color: MyColor.colorBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Dimensions.space15),
            
            // Informações de pagamento
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    MyStrings.finalAmount.tr,
                    '${StringConverter.formatNumber(payment.finalAmount ?? '0')} $curSymbol',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    MyStrings.charge.tr,
                    '${StringConverter.formatNumber(payment.charge ?? '0')} $curSymbol',
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.space10),
            
            // Data e taxa
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    MyStrings.date.tr,
                    _formatDate(payment.createdAt ?? ''),
                  ),
                ),
                if (payment.rate != null && payment.rate!.isNotEmpty)
                  Expanded(
                    child: _buildInfoItem(
                      MyStrings.conversionRate.tr,
                      '1 $currency = ${payment.rate} ${payment.methodCurrency ?? ''}',
                    ),
                  ),
              ],
            ),
            
            // Parcela se aplicável
            if (payment.installmentNumber != null && int.parse(payment.installmentNumber!) > 1)
              Container(
                margin: const EdgeInsets.only(top: Dimensions.space10),
                padding: const EdgeInsets.all(Dimensions.space10),
                decoration: BoxDecoration(
                  color: MyColor.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Dimensions.space8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 16,
                      color: MyColor.primaryColor,
                    ),
                    const SizedBox(width: Dimensions.space5),
                    Text(
                      'Parcela ${payment.installmentNumber}',
                      style: regularSmall.copyWith(
                        color: MyColor.primaryColor,
                        fontWeight: FontWeight.w500,
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
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}
