import 'package:get/get.dart';
import 'package:ovoride_driver/data/model/subscription/service_model.dart';
import 'package:ovoride_driver/data/model/subscription/service_response_model.dart';
import 'package:ovoride_driver/data/repo/subscription/subscription_repo.dart';
import 'package:ovoride_driver/data/model/global/response_model/response_model.dart';

class SubscriptionPlansController extends GetxController {
  final SubscriptionRepo _subscriptionRepo;
  
  SubscriptionPlansController({required SubscriptionRepo subscriptionRepo}) 
      : _subscriptionRepo = subscriptionRepo;

  var isLoading = false.obs;
  var services = <SubscriptionServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    isLoading.value = true;
    try {
      print('🔍 Carregando serviços para planos...');
      ResponseModel response = await _subscriptionRepo.getServices();
      
      print('📡 Resposta recebida - Status: ${response.statusCode}');
      print('📄 Dados da resposta: ${response.responseJson}');
      
      if (response.statusCode == 200) {
        try {
          ServiceResponseModel model = ServiceResponseModel.fromJson(response.responseJson);
          print('📊 Modelo parseado - Status: ${model.status}');
          print('📊 Modelo parseado - Message: ${model.message}');
          print('📊 Modelo parseado - Data: ${model.data}');
          
          if (model.status?.toLowerCase() == 'success') {
            services.value = model.data?.services ?? [];
            print('✅ Serviços carregados: ${services.length}');
            for (var service in services) {
              print('  - ${service.name}: R\$ ${service.subscriptionPrice}');
            }
          } else {
            print('❌ Erro na resposta: ${model.message}');
            services.value = [];
          }
        } catch (parseError) {
          print('❌ Erro ao fazer parsing da resposta: $parseError');
          print('📄 JSON original: ${response.responseJson}');
          services.value = [];
        }
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        services.value = [];
      }
    } catch (e) {
      print('❌ Exceção ao carregar serviços: $e');
      services.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Método para obter o preço formatado
  String getFormattedPrice(SubscriptionServiceModel service) {
    if (service.subscriptionPrice != null && service.subscriptionPrice!.isNotEmpty) {
      try {
        double price = double.parse(service.subscriptionPrice!);
        return 'R\$ ${price.toStringAsFixed(2)}';
      } catch (e) {
        return 'R\$ ${service.subscriptionPrice}';
      }
    }
    return 'R\$ 0,00';
  }

  // Método para obter a descrição do serviço
  String getServiceDescription(SubscriptionServiceModel service) {
    if (service.subscriptionDescription != null && service.subscriptionDescription!.isNotEmpty) {
      return service.subscriptionDescription!;
    }
    return 'Acesso completo ao serviço ${service.name}';
  }
}
