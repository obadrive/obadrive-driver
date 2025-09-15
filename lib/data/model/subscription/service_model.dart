class SubscriptionServiceModel {
  int? _id;
  String? _name;
  String? _subscriptionPrice;
  String? _subscriptionType;
  String? _subscriptionDescription;

  SubscriptionServiceModel({
    int? id,
    String? name,
    String? subscriptionPrice,
    String? subscriptionType,
    String? subscriptionDescription,
  }) {
    _id = id;
    _name = name;
    _subscriptionPrice = subscriptionPrice;
    _subscriptionType = subscriptionType;
    _subscriptionDescription = subscriptionDescription;
  }

  int? get id => _id;
  String? get name => _name;
  String? get subscriptionPrice => _subscriptionPrice;
  String? get subscriptionType => _subscriptionType;
  String? get subscriptionDescription => _subscriptionDescription;

  SubscriptionServiceModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _subscriptionPrice = json['subscription_price']?.toString();
    _subscriptionType = json['subscription_type'];
    _subscriptionDescription = json['subscription_description'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['subscription_price'] = _subscriptionPrice;
    map['subscription_type'] = _subscriptionType;
    map['subscription_description'] = _subscriptionDescription;
    return map;
  }

  /// Verificar se o serviço requer assinatura
  bool get requiresSubscription => _subscriptionPrice != null && _subscriptionPrice!.isNotEmpty;

  /// Obter preço formatado
  String get formattedPrice {
    if (_subscriptionPrice == null || _subscriptionPrice!.isEmpty) return '0,00';
    try {
      double price = double.parse(_subscriptionPrice!);
      return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$ 0,00';
    }
  }

  /// Obter tipo de assinatura formatado
  String get formattedSubscriptionType {
    switch (_subscriptionType) {
      case 'monthly':
        return 'Mensal';
      case 'yearly':
        return 'Anual';
      default:
        return 'Mensal';
    }
  }
}
