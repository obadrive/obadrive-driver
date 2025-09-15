import 'package:ovoride_driver/core/utils/method.dart';
import 'package:ovoride_driver/core/utils/url_container.dart';
import 'package:ovoride_driver/data/model/global/response_model/response_model.dart';
import 'package:ovoride_driver/data/services/api_client.dart';

class SubscriptionRepo {
  ApiClient apiClient;
  SubscriptionRepo({required this.apiClient});

  /// Verificar status de assinatura do motorista
  Future<ResponseModel> checkSubscriptionStatus() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionStatus}";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  /// Listar todas as assinaturas do motorista
  Future<ResponseModel> getSubscriptions() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionsList}";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  /// Criar nova assinatura
  Future<ResponseModel> createSubscription({
    required String serviceId,
    required String paymentType,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionStore}";
    Map<String, String> params = {
      'service_id': serviceId,
      'payment_type': paymentType,
    };
    
    print('🚀 Criando assinatura...');
    print('📡 URL: $url');
    print('📋 Parâmetros: $params');
    
    // Verificar se o token está sendo enviado
    print('🔑 Verificando autenticação...');
    
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    
    print('📡 Resposta da criação: ${responseModel.statusCode}');
    print('📄 Dados da resposta: ${responseModel.responseJson}');
    
    return responseModel;
  }

  /// Obter assinatura ativa para um serviço
  Future<ResponseModel> getActiveSubscription(String serviceId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionActive}/$serviceId";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  /// Obter detalhes de pagamento para um serviço
  Future<ResponseModel> getPaymentDetails(String serviceId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionPaymentDetails}/$serviceId";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  /// Obter opções de pagamento disponíveis
  Future<ResponseModel> getPaymentOptions() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionPaymentOptions}";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  /// Verificar status de bloqueio do motorista
  Future<ResponseModel> checkBlockStatus() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionBlockStatus}";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  /// Adicionar corrida completada
  Future<ResponseModel> addCompletedRide() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionAddRide}";
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, null, passHeader: true);
    return responseModel;
  }

  /// Obter estatísticas de uma assinatura
  Future<ResponseModel> getSubscriptionStats(String subscriptionId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionStats}/$subscriptionId";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  /// Obter serviços disponíveis
  Future<ResponseModel> getServices() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionServices}";
    print('🌐 Fazendo requisição para: $url');
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    print('📡 Resposta recebida - Status: ${responseModel.statusCode}');
    return responseModel;
  }
}
