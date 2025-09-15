
class SubscriptionPaymentResponseModel {
  SubscriptionPaymentResponseModel({
    String? remark,
    String? status,
    List<String>? message,
    SubscriptionPaymentData? data,
  }) {
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
  }

  SubscriptionPaymentResponseModel.fromJson(dynamic json) {
    _remark = json['remark'];
    _status = json['status'];
    
    // Suporte para message como string ou lista
    if (json["message"] == null) {
      _message = [];
    } else if (json["message"] is String) {
      _message = [json["message"]];
    } else if (json["message"] is List) {
      _message = List<String>.from(json["message"]!.map((x) => x.toString()));
    } else {
      _message = [];
    }
    
    _data = json['data'] != null ? SubscriptionPaymentData.fromJson(json['data']) : null;
  }

  String? _remark;
  String? _status;
  List<String>? _message;
  SubscriptionPaymentData? _data;

  String? get remark => _remark;
  String? get status => _status;
  List<String>? get message => _message;
  SubscriptionPaymentData? get data => _data;
}

class SubscriptionPaymentData {
  SubscriptionPaymentData({
    List<SubscriptionPaymentModel>? payments,
    String? paymentUrl,
    String? trx,
    String? amount,
    String? currency,
  }) {
    _payments = payments;
    _paymentUrl = paymentUrl;
    _trx = trx;
    _amount = amount;
    _currency = currency;
  }

  SubscriptionPaymentData.fromJson(dynamic json) {
    if (json['payments'] != null) {
      _payments = [];
      json['payments'].forEach((v) {
        _payments?.add(SubscriptionPaymentModel.fromJson(v));
      });
    }
    _paymentUrl = json['payment_url']?.toString();
    _trx = json['trx']?.toString();
    _amount = json['amount']?.toString();
    _currency = json['currency']?.toString();
  }

  List<SubscriptionPaymentModel>? _payments;
  String? _paymentUrl;
  String? _trx;
  String? _amount;
  String? _currency;

  List<SubscriptionPaymentModel>? get payments => _payments;
  String? get paymentUrl => _paymentUrl;
  String? get trx => _trx;
  String? get amount => _amount;
  String? get currency => _currency;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_payments != null) {
      map['payments'] = _payments?.map((v) => v.toJson()).toList();
    }
    map['payment_url'] = _paymentUrl;
    map['trx'] = _trx;
    map['amount'] = _amount;
    map['currency'] = _currency;
    return map;
  }
}

class SubscriptionPaymentModel {
  SubscriptionPaymentModel({
    int? id,
    String? driverSubscriptionId,
    String? trx,
    String? methodCode,
    String? methodCurrency,
    String? amount,
    String? finalAmount,
    String? charge,
    String? rate,
    String? status,
    String? detail,
    String? successUrl,
    String? failedUrl,
    String? installmentNumber,
    String? createdAt,
    String? updatedAt,
    Gateway? gateway,
  }) {
    _id = id;
    _driverSubscriptionId = driverSubscriptionId;
    _trx = trx;
    _methodCode = methodCode;
    _methodCurrency = methodCurrency;
    _amount = amount;
    _finalAmount = finalAmount;
    _charge = charge;
    _rate = rate;
    _status = status;
    _detail = detail;
    _successUrl = successUrl;
    _failedUrl = failedUrl;
    _installmentNumber = installmentNumber;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _gateway = gateway;
  }

  SubscriptionPaymentModel.fromJson(dynamic json) {
    _id = json['id'];
    _driverSubscriptionId = json['driver_subscription_id'].toString();
    _trx = json['trx'].toString();
    _methodCode = json['method_code'].toString();
    _methodCurrency = json['method_currency']?.toString();
    _amount = json['amount'].toString();
    _finalAmount = json['final_amount'].toString();
    _charge = json['charge'].toString();
    _rate = json['rate'].toString();
    _status = json['status'].toString();
    _detail = json['detail']?.toString();
    _successUrl = json['success_url']?.toString();
    _failedUrl = json['failed_url']?.toString();
    _installmentNumber = json['installment_number'].toString();
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _gateway = json['gateway'] != null ? Gateway.fromJson(json['gateway']) : null;
  }

  int? _id;
  String? _driverSubscriptionId;
  String? _trx;
  String? _methodCode;
  String? _methodCurrency;
  String? _amount;
  String? _finalAmount;
  String? _charge;
  String? _rate;
  String? _status;
  String? _detail;
  String? _successUrl;
  String? _failedUrl;
  String? _installmentNumber;
  String? _createdAt;
  String? _updatedAt;
  Gateway? _gateway;

  int? get id => _id;
  String? get driverSubscriptionId => _driverSubscriptionId;
  String? get trx => _trx;
  String? get methodCode => _methodCode;
  String? get methodCurrency => _methodCurrency;
  String? get amount => _amount;
  String? get finalAmount => _finalAmount;
  String? get charge => _charge;
  String? get rate => _rate;
  String? get status => _status;
  String? get detail => _detail;
  String? get successUrl => _successUrl;
  String? get failedUrl => _failedUrl;
  String? get installmentNumber => _installmentNumber;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  Gateway? get gateway => _gateway;

  bool get isSuccessful => _status == 'success';
  bool get isPending => _status == 'pending';
  bool get isInitiated => _status == 'initiated';
  bool get isRejected => _status == 'rejected';

  String get statusText {
    switch (_status) {
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['driver_subscription_id'] = _driverSubscriptionId;
    map['trx'] = _trx;
    map['method_code'] = _methodCode;
    map['method_currency'] = _methodCurrency;
    map['amount'] = _amount;
    map['final_amount'] = _finalAmount;
    map['charge'] = _charge;
    map['rate'] = _rate;
    map['status'] = _status;
    map['detail'] = _detail;
    map['success_url'] = _successUrl;
    map['failed_url'] = _failedUrl;
    map['installment_number'] = _installmentNumber;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_gateway != null) {
      map['gateway'] = _gateway?.toJson();
    }
    return map;
  }
}

class Gateway {
  Gateway({
    int? id,
    String? name,
    String? alias,
    String? image,
    String? status,
    String? code,
  }) {
    _id = id;
    _name = name;
    _alias = alias;
    _image = image;
    _status = status;
    _code = code;
  }

  Gateway.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name']?.toString();
    _alias = json['alias']?.toString();
    _image = json['image']?.toString();
    _status = json['status']?.toString();
    _code = json['code']?.toString();
  }

  int? _id;
  String? _name;
  String? _alias;
  String? _image;
  String? _status;
  String? _code;

  int? get id => _id;
  String? get name => _name;
  String? get alias => _alias;
  String? get image => _image;
  String? get status => _status;
  String? get code => _code;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['alias'] = _alias;
    map['image'] = _image;
    map['status'] = _status;
    map['code'] = _code;
    return map;
  }
}
