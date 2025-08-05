// ignore_for_file: library_prefixes

import 'dart:io';

import 'package:dio/dio.dart' as dioX;
import 'package:get/get.dart';
import 'package:ovoride_driver/core/helper/shared_preference_helper.dart';
import 'package:ovoride_driver/core/helper/string_format_helper.dart';
import 'package:ovoride_driver/core/route/route.dart';
import 'package:ovoride_driver/core/utils/method.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/data/model/authorization/authorization_response_model.dart';
import 'package:ovoride_driver/data/model/global/response_model/response_model.dart';
import 'package:ovoride_driver/data/model/global/response_model/unverified_response_model.dart';
import 'package:ovoride_driver/data/services/local_storage_service.dart';
import 'package:ovoride_driver/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient extends LocalStorageService {
  final dioX.Dio _dio = dioX.Dio();

  ApiClient({required super.sharedPreferences}) {
    _dio.options.headers = {
      "Accept": "application/json",
      "dev-token": Environment.devToken,
    };
    _dio.options.followRedirects = false;
    _dio.options.validateStatus = (status) {
      return status! < 500;
    };
  }

  static Future<void> init() async {
    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();

    // Initialize and register API client (which extends LocalStorageService)
    final apiClient = ApiClient(sharedPreferences: sharedPreferences);
    Get.put<ApiClient>(apiClient, permanent: true);

    // Also register it as LocalStorageService for any code that expects that type
    Get.put<LocalStorageService>(apiClient, permanent: true);
  }

  /// Request
  Future<ResponseModel> request(
    String uri,
    String method,
    Map<String, dynamic>? params, {
    bool passHeader = false,
    bool isOnlyAcceptType = false,
  }) async {
    // try {
    if (passHeader && !isOnlyAcceptType) {
      initToken();
    }

    dioX.Response response;

    switch (method) {
      case Method.postMethod:
        if (passHeader) {
          if (!isOnlyAcceptType) {
            _dio.options.headers["Authorization"] = "$tokenType $token";
          }
        }
        response = await _dio.post(uri, data: params);
        break;
      case Method.deleteMethod:
        response = await _dio.delete(uri);
        break;
      case Method.updateMethod:
        response = await _dio.patch(uri);
        break;
      default: // GET
        if (passHeader && !isOnlyAcceptType) {
          _dio.options.headers["Authorization"] = "$tokenType $token";
        }
        response = await _dio.get(uri);
        break;
    }

    printX('url--------------$uri');
    printX('params-----------${params.toString()}');
    printX('status-----------${response.statusCode}');
    printX('body-------------${response.data.toString()}');
    printX('token------------$token');

    // Process response
    if (response.statusCode == 200) {
      if (response.data == null || (response.data is String && response.data.isEmpty)) {
        Get.offAllNamed(RouteHelper.loginScreen);
        return ResponseModel(false, MyStrings.somethingWentWrong.tr, 499, '');
      }

      try {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(response.data);

        if (model.remark == 'profile_incomplete') {
          Get.toNamed(RouteHelper.profileCompleteScreen);
        } else if (model.remark == 'vehicle_verification' || model.remark == 'vehicle_verification_pending') {
          Get.offAndToNamed(RouteHelper.vehicleVerificationScreen);
        } else if (model.remark == 'unverified') {
          UnVerifiedUserResponseModel model = UnVerifiedUserResponseModel.fromJson(response.data);
          checkAndGotoUnverifiedScreen(model);
        } else if (model.remark == 'unauthenticated') {
          sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
          sharedPreferences.remove(SharedPreferenceHelper.token);
          Get.offAllNamed(RouteHelper.loginScreen);
        } else if (model.remark == 'document_unverified' || model.remark == 'document_verification_pending') {
          Get.toNamed(RouteHelper.driverProfileVerificationScreen);
        } else if (model.remark == 'vehicle_unverified') {
          Get.toNamed(RouteHelper.vehicleVerificationScreen);
        }
      } catch (e) {
        printX("Response parsing error: ${e.toString()}");
      }

      return ResponseModel(true, 'success', 200, response.data);
    } else if (response.statusCode == 401) {
      setRememberMe(false);
      Get.offAllNamed(RouteHelper.loginScreen);
      return ResponseModel(false, MyStrings.unAuthorized.tr, 401, response.data);
    } else if (response.statusCode == 500) {
      return ResponseModel(false, MyStrings.serverError.tr, 500, response.data);
    } else {
      return ResponseModel(false, MyStrings.somethingWentWrong.tr, response.statusCode ?? 499, response.data);
    }
    // } on dioX.DioException catch (e) {
    //   if (e.type == dioX.DioExceptionType.connectionTimeout || e.type == dioX.DioExceptionType.receiveTimeout || e.type == dioX.DioExceptionType.connectionError) {
    //     return ResponseModel(false, MyStrings.noInternet.tr, 503, '');
    //   } else {
    //     return ResponseModel(false, e.message ?? MyStrings.somethingWentWrong.tr, 499, '');
    //   }
    // } catch (e) {
    //   return ResponseModel(false, MyStrings.somethingWentWrong.tr, 499, '');
    // }
  }

  /// Multipart Request
  Future<ResponseModel> multipartRequest(
    String uri,
    String method,
    Map<String, dynamic>? fields, {
    required Map<String, File> files,
    bool passHeader = false,
  }) async {
    try {
      if (passHeader) {
        initToken();
        _dio.options.headers["Authorization"] = "$tokenType $token";
      }

      final formData = dioX.FormData();

      // Add text fields
      fields?.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Add files with dynamic keys
      files.forEach((fieldKey, file) async {
        formData.files.add(
          MapEntry(
            fieldKey, // Dynamic key for each file
            await dioX.MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      });

      dioX.Response response;
      switch (method) {
        case Method.postMethod:
          response = await _dio.post(uri, data: formData);
          break;
        case Method.updateMethod:
          response = await _dio.patch(uri, data: formData);
          break;
        default:
          return ResponseModel(false, 'Unsupported method', 405, '');
      }

      printX('url--------------$uri');
      printX('status-----------${response.statusCode}');
      printX('body-------------${response.data.toString()}');

      if (response.statusCode == 200) {
        return ResponseModel(true, 'success', 200, response.data);
      } else {
        return ResponseModel(false, MyStrings.somethingWentWrong.tr, response.statusCode ?? 499, response.data);
      }
    } on dioX.DioException catch (e) {
      if (e.type == dioX.DioExceptionType.connectionTimeout || e.type == dioX.DioExceptionType.receiveTimeout || e.type == dioX.DioExceptionType.connectionError) {
        return ResponseModel(false, MyStrings.noInternet.tr, 503, '');
      } else {
        return ResponseModel(false, e.message ?? MyStrings.somethingWentWrong.tr, 499, '');
      }
    } catch (e) {
      return ResponseModel(false, MyStrings.somethingWentWrong.tr, 499, '');
    }
  }

  String token = '';
  String tokenType = '';

  void initToken() {
    token = getToken();
    tokenType = getTokenType();
  }

  void checkAndGotoUnverifiedScreen(UnVerifiedUserResponseModel model) {
    var data = model.data;
    bool needSmsVerification = data?.mobileVerified == "0" ? true : false;
    bool needEmailVerification = data?.emailVerified == "0" ? true : false;
    if (needEmailVerification) {
      sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
      Get.offAllNamed(RouteHelper.emailVerificationScreen, arguments: [
        needSmsVerification,
        false,
        false,
      ]);
    } else if (needSmsVerification) {
      sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
      Get.offAllNamed(RouteHelper.smsVerificationScreen, arguments: [false, false]);
    } else {
      sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
      sharedPreferences.remove(SharedPreferenceHelper.token);
      Get.offAllNamed(RouteHelper.loginScreen);
    }
  }
}
