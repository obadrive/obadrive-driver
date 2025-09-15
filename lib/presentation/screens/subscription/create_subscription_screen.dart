import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/utils/dimensions.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/core/utils/style.dart';
import 'package:ovoride_driver/presentation/components/custom_loader/custom_loader.dart';
import 'package:ovoride_driver/presentation/screens/subscription/widget/subscription_form_widget.dart';

import '../../../data/controller/subscription/subscription_controller.dart';
import '../../../data/repo/subscription/subscription_repo.dart';

class CreateSubscriptionScreen extends StatefulWidget {
  final String? selectedPaymentType;
  final bool isFromPlansScreen;
  
  const CreateSubscriptionScreen({
    super.key,
    this.selectedPaymentType,
    this.isFromPlansScreen = false,
  });

  @override
  State<CreateSubscriptionScreen> createState() => _CreateSubscriptionScreenState();
}

class _CreateSubscriptionScreenState extends State<CreateSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    print('🚀 Inicializando CreateSubscriptionScreen...');
    print('   - selectedPaymentType: ${widget.selectedPaymentType}');
    print('   - isFromPlansScreen: ${widget.isFromPlansScreen}');
    
    // Inicializar controller se não estiver inicializado
    if (!Get.isRegistered<SubscriptionController>()) {
      print('🔧 Criando novo SubscriptionController...');
      Get.put(SubscriptionRepo(apiClient: Get.find()));
      Get.put(SubscriptionController(repo: Get.find()));
    } else {
      print('✅ SubscriptionController já existe');
    }
    
    // Carregar serviços disponíveis e assinaturas existentes
    print('📡 Carregando serviços e assinaturas...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<SubscriptionController>();
      controller.loadServices();
      controller.loadSubscriptions();
      
      // Se veio da tela de planos, define o tipo de pagamento
      if (widget.selectedPaymentType != null) {
        controller.selectedPaymentType = widget.selectedPaymentType!;
        print('🎯 Tipo de pagamento definido: ${widget.selectedPaymentType}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppBar(
          title: Text(MyStrings.createSubscription.tr, style: regularDefault.copyWith(color: MyColor.colorWhite)),
          backgroundColor: MyColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios, color: MyColor.colorWhite, size: 20),
          ),
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.space20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(Dimensions.space20),
                      decoration: BoxDecoration(
                        color: MyColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.space12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.subscriptions,
                            color: MyColor.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: Dimensions.space10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  MyStrings.createSubscription.tr,
                                  style: regularLarge.copyWith(
                                    color: MyColor.colorBlack,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.space5),
                                Text(
                                  MyStrings.subscriptionRequiredMessage.tr,
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
                    
                    const SizedBox(height: Dimensions.space20),
                    
                    // Assinaturas Existentes
                    if (controller.subscriptionList.isNotEmpty) ...[
                      _buildExistingSubscriptions(controller),
                      const SizedBox(height: Dimensions.space20),
                    ],
                    
                    // Formulário
                    const SubscriptionFormWidget(),
                    
                    const SizedBox(height: Dimensions.space30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildExistingSubscriptions(SubscriptionController controller) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space20),
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: BorderRadius.circular(Dimensions.space12),
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
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: MyColor.primaryColor,
                size: 20,
              ),
              const SizedBox(width: Dimensions.space10),
              Text(
                'Assinaturas Existentes',
                style: regularDefault.copyWith(
                  color: MyColor.colorBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space15),
          ...controller.subscriptionList.map((subscription) => Container(
            margin: const EdgeInsets.only(bottom: Dimensions.space10),
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              color: subscription.isActive 
                  ? MyColor.primaryColor.withOpacity(0.1)
                  : MyColor.colorGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.space8),
              border: Border.all(
                color: subscription.isActive 
                    ? MyColor.primaryColor.withOpacity(0.3)
                    : MyColor.colorGrey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: subscription.isActive 
                        ? Colors.green 
                        : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Dimensions.space10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.service?.name ?? 'Serviço',
                        style: regularDefault.copyWith(
                          color: MyColor.colorBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space5),
                      Text(
                        '${subscription.paymentTypeText} - ${subscription.statusText}',
                        style: regularSmall.copyWith(
                          color: MyColor.colorGrey,
                        ),
                      ),
                      if (subscription.isMonthlyRideBased && subscription.targetRides != null) ...[
                        const SizedBox(height: Dimensions.space5),
                        Text(
                          'Meta: ${subscription.targetRides} corridas',
                          style: regularSmall.copyWith(
                            color: MyColor.colorGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  'R\$ ${subscription.amount ?? '0.00'}',
                  style: regularDefault.copyWith(
                    color: MyColor.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
