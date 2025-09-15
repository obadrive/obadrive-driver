import 'service_model.dart';

class ServiceResponseModel {
  String? _status;
  String? _message;
  ServiceData? _data;

  ServiceResponseModel({
    String? status,
    String? message,
    ServiceData? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  String? get status => _status;
  String? get message => _message;
  ServiceData? get data => _data;

  ServiceResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Suporte para ambas as estruturas de resposta
      if (json.containsKey('status')) {
        // Nova estrutura: {status: "success", message: "...", data: {services: [...]}}
        _status = json['status'];
        _message = json['message'];
        if (json['data'] != null && json['data'] is Map<String, dynamic>) {
          _data = ServiceData.fromJson(json['data']);
        }
      } else if (json.containsKey('success')) {
        // Estrutura atual da API: {success: true, data: [...]}
        _status = json['success'] == true ? 'success' : 'error';
        _message = json['message'] ?? 'Serviços carregados com sucesso';
        // Converter lista direta para estrutura esperada
        if (json['data'] != null) {
          _data = ServiceData.fromJson({'services': json['data']});
        }
      }
    } catch (e) {
      print('❌ Erro ao fazer parsing do ServiceResponseModel: $e');
      print('📄 JSON recebido: $json');
      _status = 'error';
      _message = 'Erro ao processar resposta';
      _data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data!.toJson();
    }
    return map;
  }
}

class ServiceData {
  List<SubscriptionServiceModel>? _services;

  ServiceData({
    List<SubscriptionServiceModel>? services,
  }) {
    _services = services;
  }

  List<SubscriptionServiceModel>? get services => _services;

  ServiceData.fromJson(Map<String, dynamic> json) {
    try {
      if (json['services'] != null) {
        _services = <SubscriptionServiceModel>[];
        // Verificar se é uma lista
        if (json['services'] is List) {
          json['services'].forEach((v) {
            if (v is Map<String, dynamic>) {
              _services!.add(SubscriptionServiceModel.fromJson(v));
            }
          });
          print('✅ ${_services!.length} serviços processados com sucesso');
        } else if (json['services'] is String) {
          // Se for uma string, não há serviços para processar
          print('⚠️ Serviços retornados como string: ${json['services']}');
        } else {
          print('⚠️ Tipo inesperado para services: ${json['services'].runtimeType}');
        }
      } else {
        print('⚠️ Campo services não encontrado no JSON');
      }
    } catch (e) {
      print('❌ Erro ao fazer parsing do ServiceData: $e');
      print('📄 JSON recebido: $json');
      _services = <SubscriptionServiceModel>[];
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_services != null) {
      map['services'] = _services!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
