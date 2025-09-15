import 'package:ovoride_driver/core/utils/method.dart';
import 'package:ovoride_driver/core/utils/url_container.dart';
import 'package:ovoride_driver/data/model/global/response_model/response_model.dart';
import 'package:ovoride_driver/data/services/api_client.dart';

class SubscriptionPaymentRepo {
  ApiClient apiClient;
  SubscriptionPaymentRepo({required this.apiClient});

  /// Iniciar pagamento de assinatura
  Future<ResponseModel> initiatePayment({
    required String subscriptionId,
    required String methodCode,
    required String amount,
    String? currency,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionPaymentInitiate}";
    Map<String, String> params = {
      'subscription_id': subscriptionId,
      'method_code': methodCode,
      'amount': amount,
    };
    
    if (currency != null && currency.isNotEmpty) {
      params['currency'] = currency;
    }
    
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  /// Processar pagamento manual
  Future<ResponseModel> processManualPayment({
    required String subscriptionId,
    required String methodCode,
    required String amount,
    String? currency,
    String? note,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionPaymentManual}";
    Map<String, String> params = {
      'subscription_id': subscriptionId,
      'method_code': methodCode,
      'amount': amount,
    };
    
    if (currency != null && currency.isNotEmpty) {
      params['currency'] = currency;
    }
    
    if (note != null && note.isNotEmpty) {
      params['note'] = note;
    }
    
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  /// Verificar status de um pagamento
  Future<ResponseModel> checkPaymentStatus(String trx) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionPaymentStatus}?trx=$trx";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  /// Obter histórico de pagamentos
  Future<ResponseModel> getPaymentHistory({int page = 1, String searchText = ""}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionPaymentHistory}?page=$page&search=$searchText";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  /// Calcular detalhes de pagamento
  Future<ResponseModel> calculatePayment({
    required String subscriptionId,
    required String paymentType,
    String? targetRides,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.subscriptionPaymentCalculate}";
    Map<String, String> params = {
      'subscription_id': subscriptionId,
      'payment_type': paymentType,
    };
    
    if (targetRides != null && targetRides.isNotEmpty) {
      params['target_rides'] = targetRides;
    }
    
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, params, passHeader: true);
    return responseModel;
  }
}
