import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/utils/dimensions.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/core/utils/style.dart';
import 'package:ovoride_driver/data/controller/subscription/subscription_controller.dart';

class SubscriptionFormWidget extends StatefulWidget {
  const SubscriptionFormWidget({super.key});

  @override
  State<SubscriptionFormWidget> createState() => _SubscriptionFormWidgetState();
}

class _SubscriptionFormWidgetState extends State<SubscriptionFormWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(
      builder: (controller) {
        print('🔄 Rebuildando SubscriptionFormWidget...');
        print('📊 Serviços disponíveis no build: ${controller.availableServices.length}');
        
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seleção de Serviço
              _buildSection(
                MyStrings.selectService.tr,
                _buildServiceSelector(controller),
              ),
              
              const SizedBox(height: Dimensions.space20),
              
              // Seleção de Tipo de Pagamento
              _buildSection(
                MyStrings.selectPaymentType.tr,
                _buildPaymentTypeSelector(controller),
              ),
              
              const SizedBox(height: Dimensions.space20),
              
              // Nova regra: não precisa mais de campo target_rides
              // O pagamento é baseado em 30% de cada corrida até quitar a assinatura
              
              // Informações de Resumo
              if (controller.selectedServiceId != null && controller.selectedPaymentType != null)
                _buildSection(
                  MyStrings.subscriptionInfo.tr,
                  _buildSummaryInfo(controller),
                ),
              
              const SizedBox(height: Dimensions.space30),
              
              // Botão de Criar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isCreating ? null : () => _createSubscription(controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primaryColor,
                    foregroundColor: MyColor.colorWhite,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.space15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.space8),
                    ),
                  ),
                  child: controller.isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(MyColor.colorWhite),
                          ),
                        )
                      : Text(
                          MyStrings.createSubscription.tr,
                          style: regularDefault.copyWith(
                            color: MyColor.colorWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
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
        child,
      ],
    );
  }

  Widget _buildServiceSelector(SubscriptionController controller) {
    print('🎯 Construindo seletor de serviços...');
    print('📊 Serviços disponíveis: ${controller.availableServices.length}');
    
    // Se não há serviços, mostrar mensagem
    if (controller.availableServices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.space15),
        decoration: BoxDecoration(
          color: MyColor.colorGrey.withOpacity(0.1),
          border: Border.all(color: MyColor.colorGrey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(Dimensions.space8),
        ),
        child: Text(
          'Nenhum serviço disponível',
          style: regularDefault.copyWith(color: MyColor.colorGrey),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
      decoration: BoxDecoration(
        border: Border.all(color: MyColor.colorGrey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(Dimensions.space8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedServiceId,
          hint: Text(
            MyStrings.selectService.tr,
            style: regularDefault.copyWith(color: MyColor.colorGrey),
          ),
          isExpanded: true,
          items: controller.availableServices.map((service) {
            print('🔧 Criando item para serviço: ${service.name} (ID: ${service.id})');
            return DropdownMenuItem<String>(
              value: service.id.toString(),
              child: Text(
                '${service.name ?? ''} - ${service.formattedPrice}',
                style: regularDefault.copyWith(color: MyColor.colorBlack),
              ),
            );
          }).toList(),
          onChanged: (value) {
            print('🎯 Serviço selecionado: $value');
            controller.selectService(value!);
          },
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelector(SubscriptionController controller) {
    return Column(
      children: controller.paymentTypes.map((paymentType) {
        final isSelected = controller.selectedPaymentType == paymentType['value'];
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.space10),
          child: InkWell(
            onTap: () {
              controller.selectPaymentType(paymentType['value']!);
            },
            child: Container(
              padding: const EdgeInsets.all(Dimensions.space15),
              decoration: BoxDecoration(
                color: isSelected ? MyColor.primaryColor.withOpacity(0.1) : MyColor.colorWhite,
                border: Border.all(
                  color: isSelected ? MyColor.primaryColor : MyColor.colorGrey.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(Dimensions.space8),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? MyColor.primaryColor : MyColor.colorGrey,
                    size: 20,
                  ),
                  const SizedBox(width: Dimensions.space10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paymentType['label']!,
                          style: regularDefault.copyWith(
                            color: MyColor.colorBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: Dimensions.space5),
                        Text(
                          _getPaymentTypeDescription(paymentType['value']!),
                          style: regularSmall.copyWith(
                            color: MyColor.colorGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Método removido - não precisa mais de campo target_rides

  Widget _buildSummaryInfo(SubscriptionController controller) {
    // Encontrar o serviço selecionado
    final selectedService = controller.availableServices.firstWhereOrNull(
      (service) => service.id.toString() == controller.selectedServiceId
    );
    
    final subscriptionPrice = selectedService?.subscriptionPrice ?? '0';
    final price = double.tryParse(subscriptionPrice) ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.space8),
        border: Border.all(color: MyColor.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildSummaryRow(MyStrings.subscriptionType.tr, controller.getPaymentTypeText(controller.selectedPaymentType!)),
          const SizedBox(height: Dimensions.space10),
          _buildSummaryRow(MyStrings.subscriptionAmount.tr, 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}'),
          if (controller.isRideBasedPayment)
            Column(
              children: [
                const SizedBox(height: Dimensions.space10),
                _buildSummaryRow('Desconto por corrida', '30%'),
                const SizedBox(height: Dimensions.space10),
                _buildSummaryRow('Status', 'Ativo até quitar a assinatura'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getPaymentTypeDescription(String paymentType) {
    switch (paymentType) {
      case 'monthly_full':
        return 'Pague o valor mensal completo de uma vez';
      case 'monthly_ride_based':
        return 'Dilua o pagamento mensal ao longo das corridas';
      case 'yearly_full':
        return 'Pague o valor anual completo de uma vez';
      default:
        return '';
    }
  }

  // Método removido - usando controller.getPaymentTypeText() agora

  void _createSubscription(SubscriptionController controller) {
    if (_formKey.currentState!.validate()) {
      controller.createSubscription();
    }
  }
}
