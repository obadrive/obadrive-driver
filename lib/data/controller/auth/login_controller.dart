import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/route/route.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/data/model/auth/login/login_response_model.dart';
import 'package:ovoride_driver/data/model/global/response_model/response_model.dart';
import 'package:ovoride_driver/data/repo/auth/login_repo.dart';
import 'package:ovoride_driver/presentation/components/snack_bar/show_custom_snackbar.dart';
import 'package:ovoride_driver/data/controller/subscription/subscription_status_controller.dart';
import 'package:ovoride_driver/data/repo/subscription/subscription_repo.dart';
import 'package:ovoride_driver/view/screens/subscription/subscription_plans_screen.dart';

import '../../model/user/user.dart';

class LoginController extends GetxController {
  LoginRepo loginRepo;
  LoginController({required this.loginRepo});

  final FocusNode mobileNumberFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? email;
  String? password;

  List<String> errors = [];
  bool remember = false;

  void forgetPassword() {
    Get.toNamed(RouteHelper.forgotPasswordScreen);
  }

  bool isSubmitLoading = false;
  void loginUser() async {
    isSubmitLoading = true;
    update();

    ResponseModel model = await loginRepo.loginUser(emailController.text.toString(), passwordController.text.toString());

    if (model.statusCode == 200) {
      LoginResponseModel loginModel = LoginResponseModel.fromJson((model.responseJson));
      if (loginModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
        String accessToken = loginModel.data?.accessToken ?? "";
        String tokenType = loginModel.data?.tokenType ?? "";
        User? user = loginModel.data?.user;
        
         // Verifica o status de assinatura após login bem-sucedido
         await _checkSubscriptionStatus(accessToken, tokenType, user);
        
        if (remember) {
          changeRememberMe();
        }
      } else {
        CustomSnackBar.error(errorList: loginModel.message ?? [MyStrings.loginFailedTryAgain]);
      }
    } else {
      CustomSnackBar.error(errorList: [model.message]);
    }

    isSubmitLoading = false;
    update();
  }

  void changeRememberMe() {
    remember = !remember;
    update();
  }

  void clearTextField() {
    passwordController.text = '';
    emailController.text = '';

    if (remember) {
      remember = false;
    }
    update();
  }

  /// Verifica o status de assinatura após login
  Future<void> _checkSubscriptionStatus(String accessToken, String tokenType, User? user) async {
    try {
      // Inicializa o controller de status de assinatura
      Get.put(SubscriptionRepo(apiClient: Get.find()));
      Get.put(SubscriptionStatusController(subscriptionRepo: Get.find()));
      final subscriptionController = Get.find<SubscriptionStatusController>();
      
      // Verifica o status de assinatura
      await subscriptionController.checkSubscriptionStatus();
      
      // Se deve mostrar a tela de assinatura, navega para ela
      if (subscriptionController.shouldShowSubscriptionScreen.value) {
        Get.offAll(() => const SubscriptionPlansScreen());
      } else {
        // Se tem assinatura ativa, vai para o dashboard normal
        await RouteHelper.checkUserStatusAndGoToNextStep(user, accessToken: accessToken, tokenType: tokenType, isRemember: remember);
      }
    } catch (e) {
      print('❌ Erro ao verificar status de assinatura: $e');
      // Em caso de erro, vai para o dashboard normal
      await RouteHelper.checkUserStatusAndGoToNextStep(user, accessToken: accessToken, tokenType: tokenType, isRemember: remember);
    }
  }
}
