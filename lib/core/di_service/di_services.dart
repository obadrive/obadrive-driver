import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ovoride_driver/data/controller/common/theme_controller.dart';
import 'package:ovoride_driver/data/controller/localization/localization_controller.dart';
import 'package:ovoride_driver/data/controller/splash/splash_controller.dart';
import 'package:ovoride_driver/data/repo/auth/general_setting_repo.dart';
import 'package:ovoride_driver/data/repo/splash/splash_repo.dart';
import 'package:ovoride_driver/data/services/api_client.dart';
import 'package:ovoride_driver/data/repo/subscription/subscription_repo.dart';
import 'package:ovoride_driver/data/controller/subscription/subscription_status_controller.dart';

Future<Map<String, Map<String, String>>> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.lazyPut(() => sharedPreferences, fenix: true);
  Get.lazyPut(() => ApiClient(sharedPreferences: Get.find()));
  Get.lazyPut(() => GeneralSettingRepo(apiClient: Get.find()));
  Get.lazyPut(() => SplashRepo(apiClient: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(repo: Get.find(), localizationController: Get.find()));
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  
  // Registrar controladores de assinatura cedo no ciclo de vida
  Get.lazyPut(() => SubscriptionRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => SubscriptionStatusController(subscriptionRepo: Get.find()), fenix: true);

  Map<String, Map<String, String>> language = {};
  language['en_US'] = {'': ''};

  return language;
}
