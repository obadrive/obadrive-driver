import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ovoride_driver/core/helper/string_format_helper.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/presentation/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/subscription/driver_subscription_model.dart';
import '../../model/subscription/service_model.dart';
import '../../model/subscription/service_response_model.dart';
import '../../repo/subscription/subscription_repo.dart';

class SubscriptionController extends GetxController {
  SubscriptionRepo repo;
  SubscriptionController({required this.repo});

  bool isLoading = false;
  bool isCreating = false;
  bool isAddingRide = false;

  String currency = '';
  String curSymbol = '';

  List<DriverSubscriptionModel> subscriptionList = [];
  DriverSubscriptionModel? activeSubscription;
  List<SubscriptionServiceModel> availableServices = [];
  bool isBlocked = false;
  String blockReason = '';

  // Form controllers
  String? selectedServiceId;
  String? selectedPaymentType;

  // Payment types
  List<Map<String, String>> paymentTypes = [
    {'value': 'monthly_full', 'label': 'Mensal Integral'},
    {'value': 'monthly_ride_based', 'label': 'Mensal Diluído (30% por corrida)'},
  ];

  @override
  void onInit() {
    super.onInit();
    currency = repo.apiClient.getCurrency();
    curSymbol = repo.apiClient.getCurrency(isSymbol: true);
  }


  /// Carregar serviços disponíveis
  Future<void> loadServices() async {
    try {
      print('🔍 Carregando serviços...');
      ResponseModel response = await repo.getServices();
      print('📡 Resposta da API: ${response.statusCode}');
      print('📄 Dados recebidos: ${response.responseJson}');

      if (response.statusCode == 200) {
        try {
          ServiceResponseModel model = ServiceResponseModel.fromJson(response.responseJson);
          print('📊 Modelo parseado - Status: ${model.status}');
          print('📊 Serviços encontrados: ${model.data?.services?.length ?? 0}');
          
          if (model.status?.toLowerCase() == 'success') {
            availableServices = model.data?.services ?? [];
            print('✅ Serviços carregados: ${availableServices.length}');
            for (var service in availableServices) {
              print('🔧 Serviço: ${service.name} (ID: ${service.id})');
            }
          } else {
            // Se não há dados, mostrar lista vazia
            availableServices = [];
            print('⚠️ Status não é success: ${model.status}');
          }
        } catch (e) {
          print('💥 Erro ao parsear modelo: $e');
          availableServices = [];
        }
      } else {
        // Se erro na API, mostrar lista vazia
        availableServices = [];
        print('❌ Erro ao carregar serviços: ${response.message}');
      }
    } catch (e) {
      // Se erro de conexão, mostrar lista vazia
      availableServices = [];
      print('💥 Erro de conexão ao carregar serviços: $e');
    }
    update();
  }

  /// Carregar todas as assinaturas do motorista
  Future<void> loadSubscriptions() async {
    isLoading = true;
    update();

    try {
      print('🔄 Iniciando carregamento de assinaturas...');
      ResponseModel response = await repo.getSubscriptions();
      print('📡 Resposta recebida - Status: ${response.statusCode}');
      print('📄 Dados da resposta: ${response.responseJson}');

      if (response.statusCode == 200) {
        print('✅ Status 200 - Processando resposta...');
        DriverSubscriptionResponseModel model = DriverSubscriptionResponseModel.fromJson(response.responseJson);
        print('📊 Modelo parseado - Status: ${model.status}');
        print('📊 Data: ${model.data}');
        print('📊 Subscriptions: ${model.data?.subscriptions}');
        
        if (model.status?.toLowerCase() == 'success') {
          subscriptionList = model.data?.subscriptions ?? [];
          print('📋 Assinaturas carregadas: ${subscriptionList.length}');
          // Encontrar assinatura ativa
          activeSubscription = subscriptionList.firstWhereOrNull((sub) => sub.isActive);
          print('🎯 Assinatura ativa encontrada: ${activeSubscription != null}');
        } else {
          // Se não há dados, mostrar lista vazia sem erro
          subscriptionList = [];
          activeSubscription = null;
          print('⚠️ Status não é success: ${model.status}');
        }
      } else {
        // Se erro na API, mostrar lista vazia
        subscriptionList = [];
        activeSubscription = null;
        print('❌ Erro na API: ${response.statusCode} - ${response.message}');
      }
    } catch (e) {
      // Se erro de conexão, mostrar lista vazia
      subscriptionList = [];
      activeSubscription = null;
      print('💥 Erro de conexão ao carregar assinaturas: $e');
    }

    isLoading = false;
    update();
  }

  /// Verificar status de bloqueio
  Future<void> checkBlockStatus() async {
    ResponseModel response = await repo.checkBlockStatus();

    if (response.statusCode == 200) {
      // Assumindo que a resposta contém informações sobre bloqueio
      // Ajustar conforme a estrutura real da API
      var data = response.responseJson['data'];
      isBlocked = data?['is_blocked'] ?? false;
      blockReason = data?['block_reason'] ?? '';
    }

    update();
  }

  /// Criar nova assinatura
  Future<void> createSubscription() async {
    print('🎯 Iniciando criação de assinatura...');
    print('📋 Service ID: $selectedServiceId');
    print('📋 Payment Type: $selectedPaymentType');
    
    if (selectedServiceId == null) {
      CustomSnackBar.error(errorList: ['Selecione um serviço']);
      return;
    }

    if (selectedPaymentType == null) {
      CustomSnackBar.error(errorList: ['Selecione um tipo de pagamento']);
      return;
    }

    isCreating = true;
    update();

    try {
      ResponseModel response = await repo.createSubscription(
        serviceId: selectedServiceId!,
        paymentType: selectedPaymentType!,
      );
      
      print('📡 Resposta recebida no controller: ${response.statusCode}');
      print('📄 Dados da resposta no controller: ${response.responseJson}');

      if (response.statusCode == 200) {
        DriverSubscriptionResponseModel model = DriverSubscriptionResponseModel.fromJson(response.responseJson);
        if (model.status?.toLowerCase() == 'success') {
          // Se é pagamento via gateway, redireciona
          if (selectedPaymentType == 'monthly_full' || selectedPaymentType == 'yearly_full') {
            // Verifica se há URL de pagamento na resposta
            if (response.responseJson['data'] != null && 
                response.responseJson['data']['payment_url'] != null) {
              final paymentUrl = response.responseJson['data']['payment_url'];
              print('🔗 URL de pagamento: $paymentUrl');
              
              // Abre o navegador para pagamento
              await _openPaymentUrl(paymentUrl);
              
              CustomSnackBar.success(successList: ['Redirecionando para pagamento...']);
            } else {
              CustomSnackBar.success(successList: ['Assinatura criada com sucesso']);
            }
          } else {
            CustomSnackBar.success(successList: ['Assinatura criada com sucesso']);
          }
          await loadSubscriptions();
          clearForm();
        } else {
          CustomSnackBar.error(errorList: model.message ?? [MyStrings.somethingWentWrong]);
        }
      } else if (response.statusCode == 400) {
        // Erro 400 - já existe assinatura ativa
        DriverSubscriptionResponseModel model = DriverSubscriptionResponseModel.fromJson(response.responseJson);
        CustomSnackBar.error(errorList: model.message ?? ['Você já possui uma assinatura ativa para este serviço']);
        await loadSubscriptions(); // Recarregar assinaturas para mostrar a existente
      } else {
        CustomSnackBar.error(errorList: [response.message]);
      }
    } catch (e) {
      print('💥 Erro na criação de assinatura: $e');
      CustomSnackBar.error(errorList: ['Erro ao criar assinatura: $e']);
    }

    isCreating = false;
    update();
  }

  /// Adicionar corrida completada
  Future<void> addCompletedRide() async {
    isAddingRide = true;
    update();

    ResponseModel response = await repo.addCompletedRide();

    if (response.statusCode == 200) {
      var model = response.responseJson;
      if (model['status']?.toLowerCase() == 'success') {
        CustomSnackBar.success(successList: ['Corrida adicionada com sucesso']);
        await loadSubscriptions();
      } else {
        CustomSnackBar.error(errorList: model['message'] ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }

    isAddingRide = false;
    update();
  }

  /// Obter assinatura ativa para um serviço
  Future<DriverSubscriptionModel?> getActiveSubscriptionForService(String serviceId) async {
    ResponseModel response = await repo.getActiveSubscription(serviceId);

    if (response.statusCode == 200) {
      DriverSubscriptionResponseModel model = DriverSubscriptionResponseModel.fromJson(response.responseJson);
      if (model.status?.toLowerCase() == 'success' && model.data?.subscriptions?.isNotEmpty == true) {
        return model.data!.subscriptions!.first;
      }
    }

    return null;
  }

  /// Obter estatísticas de uma assinatura
  Future<Map<String, dynamic>?> getSubscriptionStats(String subscriptionId) async {
    ResponseModel response = await repo.getSubscriptionStats(subscriptionId);

    if (response.statusCode == 200) {
      var model = response.responseJson;
      if (model['status']?.toLowerCase() == 'success') {
        return model['data'];
      }
    }

    return null;
  }

  /// Limpar formulário
  void clearForm() {
    selectedServiceId = null;
    selectedPaymentType = null;
    update();
  }

  /// Abre URL de pagamento no navegador
  Future<void> _openPaymentUrl(String url) async {
    try {
      print('🔗 Tentando abrir URL: $url');
      
      // Importa o url_launcher
      final Uri uri = Uri.parse(url);
      print('🔗 URI parseado: $uri');
      
      final canLaunch = await canLaunchUrl(uri);
      print('🔗 Pode abrir URL: $canLaunch');
      
      if (canLaunch) {
        print('🔗 Abrindo URL...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('🔗 URL aberta com sucesso!');
      } else {
        print('❌ Não foi possível abrir a URL: $url');
        CustomSnackBar.error(errorList: ['Não foi possível abrir o link de pagamento']);
      }
    } catch (e) {
      print('❌ Erro ao abrir URL: $e');
      CustomSnackBar.error(errorList: ['Erro ao abrir link de pagamento']);
    }
  }

  /// Selecionar serviço
  void selectService(String serviceId) {
    selectedServiceId = serviceId;
    update();
  }

  /// Selecionar tipo de pagamento
  void selectPaymentType(String paymentType) {
    selectedPaymentType = paymentType;
    update();
  }

  /// Verificar se o tipo de pagamento é baseado em corridas
  bool get isRideBasedPayment => selectedPaymentType == 'monthly_ride_based';

  /// Obter texto do tipo de pagamento
  String getPaymentTypeText(String paymentType) {
    switch (paymentType) {
      case 'monthly_full':
        return 'Mensal Integral';
      case 'monthly_ride_based':
        return 'Mensal Diluído (30% por corrida)';
      default:
        return 'Desconhecido';
    }
  }

  /// Obter cor do status
  Color getStatusColor(String status) {
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

  /// Obter texto do status
  String getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'inactive':
        return 'Inativo';
      case 'expired':
        return 'Expirado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }

  /// Verificar se tem assinatura ativa
  bool get hasActiveSubscription => activeSubscription != null;

  /// Obter progresso de pagamento
  double getPaymentProgress(DriverSubscriptionModel subscription) {
    final amount = double.tryParse(subscription.amount ?? '0') ?? 0;
    final paid = double.tryParse(subscription.paidAmount ?? '0') ?? 0;
    if (amount == 0) return 0;
    return (paid / amount) * 100;
  }

  /// Obter valor restante
  String getRemainingAmount(DriverSubscriptionModel subscription) {
    final amount = double.tryParse(subscription.amount ?? '0') ?? 0;
    final paid = double.tryParse(subscription.paidAmount ?? '0') ?? 0;
    final remaining = amount - paid;
    return '${StringConverter.formatNumber(remaining.toString())} $curSymbol';
  }

  /// Obter valor pago
  String getPaidAmount(DriverSubscriptionModel subscription) {
    final paid = double.tryParse(subscription.paidAmount ?? '0') ?? 0;
    return '${StringConverter.formatNumber(paid.toString())} $curSymbol';
  }

  /// Obter valor total
  String getTotalAmount(DriverSubscriptionModel subscription) {
    final amount = double.tryParse(subscription.amount ?? '0') ?? 0;
    return '${StringConverter.formatNumber(amount.toString())} $curSymbol';
  }

  /// Verificar se deve mostrar campo de corridas
  // Métodos removidos - não precisa mais de validação de target_rides
}
