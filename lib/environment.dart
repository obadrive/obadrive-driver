class Environment {
  // ATTENTION Please update your desired data.
  static const String appName = 'OvoRide DRIVER';
  static const String version = '1.0.0';
  static String defaultLangCode = "en";
  static String defaultLanguageName = "PT";
  static const String baseCurrency = "\$";

  // API CONFIGURATION
  static const String domainUrl = 'https://obadrive.com.br'; //YOUR WEBSITE DOMAIN URL HERE
  static const String baseUrl = '$domainUrl/api/';

  // LOGIN AND REG PART
  static const int otpResendSecond = 120; //OTP RESEND second
  static const String defaultCountryCode = 'BR'; //Default Country Code
  static const String defaultDialCode = '1'; //Default Country Code
  static const String defaultCountry = 'Brazil'; //Default Country Code

  //MAP CONFIG
  // static const String mapKey = "Enter Your Map Api Key"; //Enter Your Map Api Key
  static const String mapKey = "AIzaSyAlr1yhXQkzC49cLhB7xC8SValIINAI28E"; //Enter Your Map Api Key
  static const double mapDefaultZoom = 20;
  static const String devToken = "\$2y\$12\$mEVBW3QASB5HMBv8igls3ejh6zw2A0Xb480HWAmYq6BY9xEifyBjG"; //Do not change this token
}
