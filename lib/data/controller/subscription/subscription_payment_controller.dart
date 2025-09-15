import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/helper/string_format_helper.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/presentation/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/subscription/subscription_payment_model.dart';
import '../../repo/subscription/subscription_payment_repo.dart';

class SubscriptionPaymentController extends GetxController {
  SubscriptionPaymentRepo repo;
  SubscriptionPaymentController({required this.repo});

  bool isLoading = false;
  bool isProcessing = false;
  bool isCalculating = false;

  String currency = '';
  String curSymbol = '';

  List<SubscriptionPaymentModel> paymentList = [];
  String? nextPageUrl = '';
  int page = 1;

  // Form controllers
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  String? selectedMethodCode;
  String? selectedCurrency;

  // Payment calculation
  Map<String, dynamic>? paymentCalculation;
  String? paymentUrl;
  String? transactionId;

  @override
  void onInit() {
    super.onInit();
    currency = repo.apiClient.getCurrency();
    curSymbol = repo.apiClient.getCurrency(isSymbol: true);
  }


  /// Carregar histórico de pagamentos
  Future<void> loadPaymentHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
      paymentList.clear();
    }

    isLoading = true;
    update();

    try {
      ResponseModel response = await repo.getPaymentHistory(page: page);

      if (response.statusCode == 200) {
        SubscriptionPaymentResponseModel model = SubscriptionPaymentResponseModel.fromJson(response.responseJson);
        if (model.status?.toLowerCase() == 'success') {
          paymentList.addAll(model.data?.payments ?? []);
          nextPageUrl = model.data?.trx ?? '';
        } else {
          // Se não há dados, mostrar lista vazia sem erro
          paymentList = [];
          nextPageUrl = '';
        }
      } else {
        // Se erro na API, mostrar lista vazia
        paymentList = [];
        nextPageUrl = '';
        print('Erro ao carregar histórico de pagamentos: ${response.message}');
      }
    } catch (e) {
      // Se erro de conexão, mostrar lista vazia
      paymentList = [];
      nextPageUrl = '';
      print('Erro de conexão ao carregar histórico de pagamentos: $e');
    }

    isLoading = false;
    update();
  }

  /// Carregar mais pagamentos (pagination)
  Future<void> loadMorePayments() async {
    if (nextPageUrl == null || nextPageUrl!.isEmpty) return;

    page++;
    ResponseModel response = await repo.getPaymentHistory(page: page);

    if (response.statusCode == 200) {
      SubscriptionPaymentResponseModel model = SubscriptionPaymentResponseModel.fromJson(response.responseJson);
      if (model.status?.toLowerCase() == 'success') {
        paymentList.addAll(model.data?.payments ?? []);
        nextPageUrl = model.data?.trx ?? '';
        update();
      }
    }
  }

  /// Iniciar pagamento
  Future<void> initiatePayment({
    required String subscriptionId,
    required String methodCode,
    required String amount,
    String? currency,
  }) async {
    isProcessing = true;
    update();

    ResponseModel response = await repo.initiatePayment(
      subscriptionId: subscriptionId,
      methodCode: methodCode,
      amount: amount,
      currency: currency ?? this.currency,
    );

    if (response.statusCode == 200) {
      SubscriptionPaymentResponseModel model = SubscriptionPaymentResponseModel.fromJson(response.responseJson);
      if (model.status?.toLowerCase() == 'success') {
        paymentUrl = model.data?.paymentUrl;
        transactionId = model.data?.trx;
        CustomSnackBar.success(successList: ['Pagamento iniciado com sucesso']);
        // Aqui você pode navegar para a tela de pagamento ou abrir o webview
      } else {
        CustomSnackBar.error(errorList: model.message ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }

    isProcessing = false;
    update();
  }

  /// Processar pagamento manual
  Future<void> processManualPayment({
    required String subscriptionId,
    required String methodCode,
    required String amount,
    String? currency,
    String? note,
  }) async {
    isProcessing = true;
    update();

    ResponseModel response = await repo.processManualPayment(
      subscriptionId: subscriptionId,
      methodCode: methodCode,
      amount: amount,
      currency: currency ?? this.currency,
      note: note,
    );

    if (response.statusCode == 200) {
      var model = response.responseJson;
      if (model['status']?.toLowerCase() == 'success') {
        CustomSnackBar.success(successList: ['Pagamento manual processado com sucesso']);
        await loadPaymentHistory(isRefresh: true);
      } else {
        CustomSnackBar.error(errorList: model['message'] ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }

    isProcessing = false;
    update();
  }

  /// Verificar status de pagamento
  Future<void> checkPaymentStatus(String trx) async {
    ResponseModel response = await repo.checkPaymentStatus(trx);

    if (response.statusCode == 200) {
      var model = response.responseJson;
      if (model['status']?.toLowerCase() == 'success') {
        // Atualizar status do pagamento na lista
        final index = paymentList.indexWhere((payment) => payment.trx == trx);
        if (index != -1) {
          paymentList[index] = SubscriptionPaymentModel.fromJson(model['data']);
          update();
        }
      }
    }
  }

  /// Calcular detalhes de pagamento
  Future<void> calculatePayment({
    required String subscriptionId,
    required String paymentType,
    String? targetRides,
  }) async {
    isCalculating = true;
    update();

    ResponseModel response = await repo.calculatePayment(
      subscriptionId: subscriptionId,
      paymentType: paymentType,
      targetRides: targetRides,
    );

    if (response.statusCode == 200) {
      var model = response.responseJson;
      if (model['status']?.toLowerCase() == 'success') {
        paymentCalculation = model['data'];
      } else {
        CustomSnackBar.error(errorList: model['message'] ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }

    isCalculating = false;
    update();
  }

  /// Limpar formulário
  void clearForm() {
    amountController.clear();
    noteController.clear();
    selectedMethodCode = null;
    selectedCurrency = null;
    paymentCalculation = null;
    paymentUrl = null;
    transactionId = null;
    update();
  }

  /// Selecionar método de pagamento
  void selectPaymentMethod(String methodCode) {
    selectedMethodCode = methodCode;
    update();
  }

  /// Selecionar moeda
  void selectCurrency(String currency) {
    selectedCurrency = currency;
    update();
  }

  /// Verificar se tem próxima página
  bool hasNextPage() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty;
  }

  /// Obter cor do status de pagamento
  Color getPaymentStatusColor(String status) {
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

  /// Obter texto do status de pagamento
  String getPaymentStatusText(String status) {
    switch (status) {
      case 'success':
        return 'Sucesso';
      case 'pending':
        return 'Pendente';
      case 'initiated':
        return 'Iniciado';
      case 'rejected':
        return 'Rejeitado';
      default:
        return 'Desconhecido';
    }
  }

  /// Formatar valor
  String formatAmount(String amount) {
    final value = double.tryParse(amount) ?? 0;
    return '${StringConverter.formatNumber(value.toString())} $curSymbol';
  }

  /// Formatar data
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  /// Validar valor
  bool isValidAmount(String value) {
    if (value.isEmpty) return false;
    final amount = double.tryParse(value);
    return amount != null && amount > 0;
  }

  /// Obter valor calculado
  String? getCalculatedAmount() {
    return paymentCalculation?['amount']?.toString();
  }

  /// Obter taxa calculada
  String? getCalculatedCharge() {
    return paymentCalculation?['charge']?.toString();
  }

  /// Obter valor final calculado
  String? getCalculatedFinalAmount() {
    return paymentCalculation?['final_amount']?.toString();
  }

  /// Verificar se tem cálculo disponível
  bool get hasCalculation => paymentCalculation != null;

  /// Verificar se tem URL de pagamento
  bool get hasPaymentUrl => paymentUrl != null && paymentUrl!.isNotEmpty;
}
