import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/dimensions.dart';
import 'package:ovoride_driver/core/utils/style.dart';
import 'package:ovoride_driver/presentation/screens/subscription/create_subscription_screen.dart';
import 'package:ovoride_driver/data/controller/subscription/subscription_plans_controller.dart';
import 'package:ovoride_driver/data/repo/subscription/subscription_repo.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Inicializa o controller de planos
    Get.put(SubscriptionRepo(apiClient: Get.find()));
    Get.put(SubscriptionPlansController(subscriptionRepo: Get.find()));
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildPlansList(),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            MyStrings.appName,
            style: regularDefault.copyWith(
              color: MyColor.colorWhite,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Escolha seu plano e comece a dirigir',
            style: regularDefault.copyWith(
              color: MyColor.colorWhite.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Assinatura obrigatória para usar o aplicativo',
            style: regularDefault.copyWith(
              color: MyColor.colorWhite.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
      children: [
        const SizedBox(height: 20),
        // Lista dinâmica de planos baseada nos serviços
        GetX<SubscriptionPlansController>(
          builder: (controller) {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            
            if (controller.services.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum serviço disponível',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            
            return Column(
              children: controller.services.map((service) {
                return Column(
                  children: [
                    _buildServicePlanCard(service),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPopular
                    ? [
                        const Color(0xFFE50914),
                        const Color(0xFFB81D13),
                      ]
                    : [
                        const Color(0xFF2D2D2D),
                        const Color(0xFF1A1A1A),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isPopular
                      ? const Color(0xFFE50914).withOpacity(0.3)
                      : Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: MyColor.colorWhite,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'MAIS POPULAR',
                            style: regularDefault.copyWith(
                              color: const Color(0xFFE50914),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (isPopular) const SizedBox(height: 16),
                      Text(
                        title,
                        style: regularDefault.copyWith(
                          color: MyColor.colorWhite,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: regularDefault.copyWith(
                          color: MyColor.colorWhite.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            price,
                            style: regularDefault.copyWith(
                              color: MyColor.colorWhite,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              period,
                              style: regularDefault.copyWith(
                                color: MyColor.colorWhite.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ...features.map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: MyColor.colorWhite.withOpacity(0.8),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: regularDefault.copyWith(
                                      color: MyColor.colorWhite.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: MyColor.colorWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Escolher Plano',
                          style: regularDefault.copyWith(
                            color: isPopular
                                ? const Color(0xFFE50914)
                                : const Color(0xFF2D2D2D),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      child: Column(
        children: [
          Text(
            'Você pode cancelar sua assinatura a qualquer momento',
            style: regularDefault.copyWith(
              color: MyColor.colorWhite.withOpacity(0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Todos os planos incluem suporte 24/7',
            style: regularDefault.copyWith(
              color: MyColor.colorWhite.withOpacity(0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildServicePlanCard(dynamic service) {
    final controller = Get.find<SubscriptionPlansController>();
    final price = controller.getFormattedPrice(service);
    final description = controller.getServiceDescription(service);
    
    return _buildPlanCard(
      title: service.name ?? 'Serviço',
      subtitle: description,
      price: price,
      period: '/mês',
      features: [
        'Acesso completo ao serviço ${service.name}',
        'Suporte prioritário',
        'Sem taxas adicionais',
        'Cancelamento a qualquer momento',
      ],
      isPopular: service.id == 1, // Primeiro serviço é popular
      onTap: () => _selectServicePlan(service),
    );
  }

  void _selectServicePlan(dynamic service) {
    // Navega para a tela de criação de assinatura com o serviço selecionado
    Get.to(() => CreateSubscriptionScreen(
          selectedPaymentType: 'monthly_full',
          isFromPlansScreen: true,
        ));
  }

  void _selectPlan(String paymentType) {
    // Navega para a tela de criação de assinatura
    Get.to(() => CreateSubscriptionScreen(
          selectedPaymentType: paymentType,
          isFromPlansScreen: true,
        ));
  }
}
