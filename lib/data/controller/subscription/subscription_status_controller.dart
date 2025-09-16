import 'package:get/get.dart';
import 'package:ovoride_driver/data/repo/subscription/subscription_repo.dart';
import 'package:ovoride_driver/data/model/subscription/driver_subscription_model.dart';

class SubscriptionStatusController extends GetxController {
  final SubscriptionRepo _subscriptionRepo;
  
  SubscriptionStatusController({required SubscriptionRepo subscriptionRepo}) 
      : _subscriptionRepo = subscriptionRepo;

  // Observable variables
  var isLoading = false.obs;
  var hasActiveSubscription = false.obs;
  var shouldShowSubscriptionScreen = false.obs;
  var activeSubscription = Rxn<DriverSubscriptionModel>();

  @override
  void onInit() {
    super.onInit();
    // Não checar automaticamente aqui; a checagem deve ocorrer
    // somente após login bem-sucedido quando já houver token válido.
  }

  /// Verifica o status de assinatura do motorista
  Future<void> checkSubscriptionStatus() async {
    try {
      isLoading.value = true;
      print('🔍 Verificando status de assinatura...');

      final response = await _subscriptionRepo.checkSubscriptionStatus();
      
      if (response.statusCode == 200) {
        final data = response.responseJson['data'];
        
        hasActiveSubscription.value = data['has_active_subscription'] ?? false;
        shouldShowSubscriptionScreen.value = data['should_show_subscription_screen'] ?? false;
        
        if (data['active_subscription'] != null) {
          activeSubscription.value = DriverSubscriptionModel.fromJson(data['active_subscription']);
        }

        print('✅ Status de assinatura verificado:');
        print('   - Tem assinatura ativa: ${hasActiveSubscription.value}');
        print('   - Deve mostrar tela: ${shouldShowSubscriptionScreen.value}');
        print('   - Assinatura ativa: ${activeSubscription.value?.id}');
      } else {
        print('❌ Erro ao verificar status: ${response.statusCode}');
        // Em erro (ex.: 401 não autenticado), não forçar tela de assinatura
        shouldShowSubscriptionScreen.value = false;
      }
    } catch (e) {
      print('❌ Erro na verificação de status: $e');
      // Em exceção, não forçar tela de assinatura
      shouldShowSubscriptionScreen.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Força a verificação do status
  Future<void> refreshSubscriptionStatus() async {
    await checkSubscriptionStatus();
  }

  /// Marca que o usuário viu a tela de assinatura (para não mostrar novamente na mesma sessão)
  void markSubscriptionScreenAsSeen() {
    shouldShowSubscriptionScreen.value = false;
  }

  /// Verifica se deve mostrar a tela de assinatura
  bool get shouldShowSubscription {
    return shouldShowSubscriptionScreen.value && !hasActiveSubscription.value;
  }
}
