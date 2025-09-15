
class DriverSubscriptionResponseModel {
  DriverSubscriptionResponseModel({
    String? remark,
    String? status,
    List<String>? message,
    DriverSubscriptionData? data,
  }) {
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
  }

  DriverSubscriptionResponseModel.fromJson(dynamic json) {
    _remark = json['remark'];
    
    // Suporte para diferentes estruturas de resposta
    if (json.containsKey('success')) {
      // Estrutura: {success: true, message: "string", data: {...}}
      _status = json['success'] == true ? 'success' : 'error';
      if (json["message"] == null) {
        _message = [];
      } else if (json["message"] is String) {
        _message = [json["message"]];
      } else if (json["message"] is List) {
        _message = List<String>.from(json["message"]!.map((x) => x.toString()));
      } else {
        _message = [];
      }
    } else {
      // Estrutura: {status: "success", message: [...], data: {...}}
      _status = json['status'];
      if (json["message"] == null) {
        _message = [];
      } else if (json["message"] is String) {
        _message = [json["message"]];
      } else if (json["message"] is List) {
        _message = List<String>.from(json["message"]!.map((x) => x.toString()));
      } else {
        _message = [];
      }
    }
    
    // Suporte para diferentes estruturas de data
    if (json['data'] != null) {
      if (json['data'] is List) {
        // Estrutura: {success: true, data: [...]}
        _data = DriverSubscriptionData.fromJson(json['data']);
      } else {
        // Estrutura: {status: "success", data: {...}}
        _data = DriverSubscriptionData.fromJson(json['data']);
      }
    } else {
      _data = null;
    }
  }

  String? _remark;
  String? _status;
  List<String>? _message;
  DriverSubscriptionData? _data;

  String? get remark => _remark;
  String? get status => _status;
  List<String>? get message => _message;
  DriverSubscriptionData? get data => _data;
}

class DriverSubscriptionData {
  DriverSubscriptionData({
    List<DriverSubscriptionModel>? subscriptions,
  }) {
    _subscriptions = subscriptions;
  }

  DriverSubscriptionData.fromJson(dynamic json) {
    if (json is List) {
      // Estrutura: [{...}, {...}] - array direto
      _subscriptions = [];
      json.forEach((v) {
        _subscriptions?.add(DriverSubscriptionModel.fromJson(v));
      });
    } else if (json['subscriptions'] != null) {
      // Estrutura: {subscriptions: [...]}
      _subscriptions = [];
      json['subscriptions'].forEach((v) {
        _subscriptions?.add(DriverSubscriptionModel.fromJson(v));
      });
    } else if (json['id'] != null) {
      // Estrutura: {id: 12, driver_id: 8, ...} - assinatura única
      _subscriptions = [DriverSubscriptionModel.fromJson(json)];
    }
  }

  List<DriverSubscriptionModel>? _subscriptions;

  List<DriverSubscriptionModel>? get subscriptions => _subscriptions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_subscriptions != null) {
      map['subscriptions'] = _subscriptions?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class DriverSubscriptionModel {
  DriverSubscriptionModel({
    int? id,
    String? driverId,
    String? serviceId,
    String? status,
    String? paymentType,
    String? amount,
    String? paidAmount,
    String? installmentCount,
    String? paidInstallments,
    String? targetRides,
    String? completedRides,
    String? perRideAmount,
    String? startDate,
    String? endDate,
    String? nextPaymentDate,
    String? notes,
    String? createdAt,
    String? updatedAt,
    ServiceModel? service,
    List<SubscriptionPaymentModel>? payments,
  }) {
    _id = id;
    _driverId = driverId;
    _serviceId = serviceId;
    _status = status;
    _paymentType = paymentType;
    _amount = amount;
    _paidAmount = paidAmount;
    _installmentCount = installmentCount;
    _paidInstallments = paidInstallments;
    _targetRides = targetRides;
    _completedRides = completedRides;
    _perRideAmount = perRideAmount;
    _startDate = startDate;
    _endDate = endDate;
    _nextPaymentDate = nextPaymentDate;
    _notes = notes;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _service = service;
    _payments = payments;
  }

  DriverSubscriptionModel.fromJson(dynamic json) {
    _id = json['id'];
    _driverId = json['driver_id']?.toString();
    _serviceId = json['service_id']?.toString();
    _status = json['status']?.toString();
    _paymentType = json['payment_type']?.toString();
    _amount = json['amount']?.toString();
    _paidAmount = json['paid_amount']?.toString();
    _installmentCount = json['installment_count']?.toString();
    _paidInstallments = json['paid_installments']?.toString();
    _targetRides = json['target_rides']?.toString();
    _completedRides = json['completed_rides']?.toString();
    _perRideAmount = json['per_ride_amount']?.toString();
    _startDate = json['start_date'];
    _endDate = json['end_date'];
    _nextPaymentDate = json['next_payment_date'];
    _notes = json['notes'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _service = json['service'] != null ? ServiceModel.fromJson(json['service']) : null;
    if (json['payments'] != null) {
      _payments = [];
      json['payments'].forEach((v) {
        _payments?.add(SubscriptionPaymentModel.fromJson(v));
      });
    }
  }

  int? _id;
  String? _driverId;
  String? _serviceId;
  String? _status;
  String? _paymentType;
  String? _amount;
  String? _paidAmount;
  String? _installmentCount;
  String? _paidInstallments;
  String? _targetRides;
  String? _completedRides;
  String? _perRideAmount;
  String? _startDate;
  String? _endDate;
  String? _nextPaymentDate;
  String? _notes;
  String? _createdAt;
  String? _updatedAt;
  ServiceModel? _service;
  List<SubscriptionPaymentModel>? _payments;

  int? get id => _id;
  String? get driverId => _driverId;
  String? get serviceId => _serviceId;
  String? get status => _status;
  String? get paymentType => _paymentType;
  String? get amount => _amount;
  String? get paidAmount => _paidAmount;
  String? get installmentCount => _installmentCount;
  String? get paidInstallments => _paidInstallments;
  String? get targetRides => _targetRides;
  String? get completedRides => _completedRides;
  String? get perRideAmount => _perRideAmount;
  String? get startDate => _startDate;
  String? get endDate => _endDate;
  String? get nextPaymentDate => _nextPaymentDate;
  String? get notes => _notes;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  ServiceModel? get service => _service;
  List<SubscriptionPaymentModel>? get payments => _payments;

  // Helper methods
  bool get isActive => _status == 'active';
  bool get isExpired => _status == 'expired';
  bool get isMonthlyFull => _paymentType == 'monthly_full';
  bool get isMonthlyRideBased => _paymentType == 'monthly_ride_based';
  bool get isYearlyFull => _paymentType == 'yearly_full';

  double get remainingAmount {
    final amount = double.tryParse(_amount ?? '0') ?? 0;
    final paid = double.tryParse(_paidAmount ?? '0') ?? 0;
    return amount - paid;
  }

  double get progressPercentage {
    final amount = double.tryParse(_amount ?? '0') ?? 0;
    final paid = double.tryParse(_paidAmount ?? '0') ?? 0;
    if (amount == 0) return 0;
    return (paid / amount) * 100;
  }

  String get paymentTypeText {
    switch (_paymentType) {
      case 'monthly_full':
        return 'Mensal Integral';
      case 'monthly_ride_based':
        return 'Mensal Diluído';
      case 'yearly_full':
        return 'Anual Integral';
      default:
        return 'Desconhecido';
    }
  }

  String get statusText {
    switch (_status) {
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['driver_id'] = _driverId;
    map['service_id'] = _serviceId;
    map['status'] = _status;
    map['payment_type'] = _paymentType;
    map['amount'] = _amount;
    map['paid_amount'] = _paidAmount;
    map['installment_count'] = _installmentCount;
    map['paid_installments'] = _paidInstallments;
    map['target_rides'] = _targetRides;
    map['completed_rides'] = _completedRides;
    map['per_ride_amount'] = _perRideAmount;
    map['start_date'] = _startDate;
    map['end_date'] = _endDate;
    map['next_payment_date'] = _nextPaymentDate;
    map['notes'] = _notes;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_service != null) {
      map['service'] = _service?.toJson();
    }
    if (_payments != null) {
      map['payments'] = _payments?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ServiceModel {
  ServiceModel({
    int? id,
    String? name,
    String? image,
    String? status,
    String? subscriptionPrice,
    String? subscriptionType,
    String? subscriptionRequired,
    String? subscriptionDescription,
  }) {
    _id = id;
    _name = name;
    _image = image;
    _status = status;
    _subscriptionPrice = subscriptionPrice;
    _subscriptionType = subscriptionType;
    _subscriptionRequired = subscriptionRequired;
    _subscriptionDescription = subscriptionDescription;
  }

  ServiceModel.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name']?.toString();
    _image = json['image']?.toString();
    _status = json['status']?.toString();
    _subscriptionPrice = json['subscription_price']?.toString();
    _subscriptionType = json['subscription_type']?.toString();
    _subscriptionRequired = json['subscription_required']?.toString();
    _subscriptionDescription = json['subscription_description']?.toString();
  }

  int? _id;
  String? _name;
  String? _image;
  String? _status;
  String? _subscriptionPrice;
  String? _subscriptionType;
  String? _subscriptionRequired;
  String? _subscriptionDescription;

  int? get id => _id;
  String? get name => _name;
  String? get image => _image;
  String? get status => _status;
  String? get subscriptionPrice => _subscriptionPrice;
  String? get subscriptionType => _subscriptionType;
  String? get subscriptionRequired => _subscriptionRequired;
  String? get subscriptionDescription => _subscriptionDescription;

  bool get requiresSubscription => _subscriptionRequired == '1';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['image'] = _image;
    map['status'] = _status;
    map['subscription_price'] = _subscriptionPrice;
    map['subscription_type'] = _subscriptionType;
    map['subscription_required'] = _subscriptionRequired;
    map['subscription_description'] = _subscriptionDescription;
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
    _driverSubscriptionId = json['driver_subscription_id']?.toString();
    _trx = json['trx']?.toString();
    _methodCode = json['method_code']?.toString();
    _methodCurrency = json['method_currency']?.toString();
    _amount = json['amount']?.toString();
    _finalAmount = json['final_amount']?.toString();
    _charge = json['charge']?.toString();
    _rate = json['rate']?.toString();
    _status = json['status']?.toString();
    _detail = json['detail']?.toString();
    _successUrl = json['success_url']?.toString();
    _failedUrl = json['failed_url']?.toString();
    _installmentNumber = json['installment_number']?.toString();
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
