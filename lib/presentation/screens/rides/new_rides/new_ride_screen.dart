import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ovoride_driver/core/route/route.dart';
import 'package:ovoride_driver/core/utils/dimensions.dart';
import 'package:ovoride_driver/core/utils/my_color.dart';
import 'package:ovoride_driver/core/utils/my_images.dart';
import 'package:ovoride_driver/core/utils/my_strings.dart';
import 'package:ovoride_driver/core/utils/style.dart';
import 'package:ovoride_driver/data/controller/dashboard/dashboard_controller.dart';
import 'package:ovoride_driver/presentation/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovoride_driver/presentation/components/image/custom_svg_picture.dart';
import 'package:ovoride_driver/presentation/components/image/my_network_image_widget.dart';
import 'package:ovoride_driver/presentation/components/no_data.dart';
import 'package:ovoride_driver/presentation/components/shimmer/ride_shimmer.dart';
import 'package:ovoride_driver/presentation/components/text/header_text.dart';
import 'package:ovoride_driver/presentation/screens/dashboard/widgets/driver_kyc_warning_section.dart';
import 'package:ovoride_driver/presentation/screens/dashboard/widgets/vahicle_kyc_warning_section.dart';
import 'package:ovoride_driver/presentation/screens/rides/new_rides/widget/offer_bid_bottom_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/helper/string_format_helper.dart';
import '../../../components/switch/lite_rolling_switch.dart';
import 'widget/new_ride_card.dart';
import 'package:ovoride_driver/data/controller/subscription/subscription_status_controller.dart';
import 'package:ovoride_driver/data/repo/subscription/subscription_repo.dart';
import 'package:ovoride_driver/presentation/components/snack_bar/show_custom_snackbar.dart';

class NewRidesScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? dashBoardScaffoldKey;
  const NewRidesScreen({super.key, this.dashBoardScaffoldKey});

  @override
  State<NewRidesScreen> createState() => _NewRidesScreenState();
}

class _NewRidesScreenState extends State<NewRidesScreen> {
  ScrollController? _scrollController;
  Color? _theme;

  @override
  void initState() {
    super.initState();
    checkAppBarExpanded();
    // Garantir controlador de assinatura ANTES do primeiro build
    if (!Get.isRegistered<SubscriptionStatusController>()) {
      Get.put(SubscriptionRepo(apiClient: Get.find()));
      Get.put(SubscriptionStatusController(subscriptionRepo: Get.find()));
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<DashBoardController>().isLoading = true;
      Get.find<DashBoardController>().initialData(shouldLoad: true);
      // Atualizar status após montar
      Get.find<SubscriptionStatusController>().refreshSubscriptionStatus();
    });
  }

  void checkAppBarExpanded() {
    _scrollController = ScrollController()
      ..addListener(
        () => _isAppBarExpanded
            ? _theme != MyColor.getHeaderBGColor()
                ? setState(
                    () {
                      _theme = MyColor.getHeaderBGColor();
                      printX('setState is called');
                    },
                  )
                : {}
            : _theme != Colors.transparent
                ? setState(() {
                    printX('setState is called');
                    _theme = Colors.transparent;
                  })
                : {},
      );
  }

  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (140 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(statusBarColor: MyColor.primaryColor, statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.dark),
        child: Scaffold(
          backgroundColor: MyColor.screenBgColor,
          body: RefreshIndicator(
            edgeOffset: 80,
            backgroundColor: MyColor.colorWhite,
            color: MyColor.primaryColor,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            onRefresh: () async {
              controller.loadData();
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              controller: _scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  surfaceTintColor: MyColor.transparentColor,
                  systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: MyColor.screenBgColor, statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.dark),
                  toolbarHeight: 70,
                  pinned: true,
                  backgroundColor: MyColor.screenBgColor,
                  elevation: 1,
                  automaticallyImplyLeading: false,
                  actions: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(end: 0, top: 8, bottom: 3, start: 12),
                      padding: const EdgeInsets.all(5),
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(RouteHelper.profileAndSettingsScreen);
                        },
                        child: MyImageWidget(imageUrl: controller.profileImageUrl ?? "", isProfile: true, height: 45, width: 45, radius: 50, errorWidget: Image.asset(MyImages.defaultAvatar, height: 50)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 13),
                          HeaderText(text: controller.driver.getFullName(), textStyle: boldLarge.copyWith(color: MyColor.titleColor, fontSize: 16)),
                          Row(
                            children: [
                              CustomSvgPicture(image: MyImages.focus, width: 16, height: 16),
                              SizedBox(width: 5),
                              Expanded(child: Text(controller.currentAddress, style: regularDefault.copyWith(color: Color(0xff475569), fontSize: 12, fontWeight: FontWeight.w400), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GetBuilder<DashBoardController>(builder: (dashController) {
                        // Verificar se o SubscriptionStatusController está disponível
                        if (!Get.isRegistered<SubscriptionStatusController>()) {
                          return SizedBox(
                            height: Dimensions.space45,
                            child: LiteRollingSwitch(
                              tValue: dashController.userOnline,
                              width: Dimensions.space50 + 60,
                              textOn: MyStrings.onLine.tr,
                              textOnColor: MyColor.colorWhite,
                              textOff: MyStrings.offLine.tr,
                              colorOn: MyColor.colorGreen,
                              colorOff: MyColor.colorBlack.withValues(alpha: 0.6),
                              iconOn: Icons.network_check,
                              iconOff: Icons.network_locked,
                              animationDuration: const Duration(milliseconds: 300),
                              onChanged: (bool state) {
                                if (dashController.isLoaderLoading == false) {
                                  dashController.changeOnlineStatus(state);
                                }
                              },
                            ),
                          );
                        }
                        
                        final subscriptionController = Get.find<SubscriptionStatusController>();
                        final bool canGoOnline = subscriptionController.hasActiveSubscription.value;
                        final bool effectiveOnline = canGoOnline && dashController.userOnline;
                        
                        return SizedBox(
                          height: Dimensions.space45,
                          child: Opacity(
                            opacity: canGoOnline ? 1.0 : 0.6,
                            child: LiteRollingSwitch(
                              tValue: effectiveOnline,
                              width: Dimensions.space50 + 60,
                              textOn: MyStrings.onLine.tr,
                              textOnColor: MyColor.colorWhite,
                              textOff: MyStrings.offLine.tr,
                              colorOn: canGoOnline ? MyColor.colorGreen : MyColor.colorGrey,
                              colorOff: MyColor.colorBlack.withValues(alpha: 0.6),
                              iconOn: canGoOnline ? Icons.network_check : Icons.lock,
                              iconOff: Icons.network_locked,
                              animationDuration: const Duration(milliseconds: 300),
                              onChanged: (bool state) {
                                if (!canGoOnline && state == true) {
                                  // Bloquear mudança para online sem assinatura
                                  CustomSnackBar.error(errorList: ['Ative sua assinatura para ficar Online']);
                                  return;
                                }
                                if (dashController.isLoaderLoading == false) {
                                  dashController.changeOnlineStatus(state);
                                }
                              },
                              onTap: () {
                                if (!canGoOnline) {
                                  CustomSnackBar.error(errorList: ['Assinatura necessária para ficar Online']);
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(width: 10)
                  ],
                  floating: true,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      // Aviso quando não há assinatura ativa
                      Builder(builder: (context) {
                        // Verificar se o SubscriptionStatusController está disponível
                        if (!Get.isRegistered<SubscriptionStatusController>()) {
                          return const SizedBox.shrink();
                        }
                        
                        final subscriptionController = Get.find<SubscriptionStatusController>();
                        if (subscriptionController.hasActiveSubscription.value) {
                          return const SizedBox.shrink();
                        }
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                          padding: const EdgeInsets.all(Dimensions.space12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.withOpacity(0.25)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lock, color: Colors.orange, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Você está Offline. Ative sua assinatura para ficar Online e receber corridas.',
                                  style: regularSmall.copyWith(color: MyColor.colorBlack),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      DriverKYCWarningSection(),
                      SizedBox(height: 2),
                      VehicleKYCWarningSection(),
                    ],
                  ),
                ),
                if (controller.isLoading == false) ...[
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
                      padding: const EdgeInsets.only(bottom: 5),
                      child: controller.runningRide?.id == "-1"
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(MyStrings.runningRide.tr, style: semiBoldLarge.copyWith(color: MyColor.primaryColor, fontSize: 16)),
                                SizedBox(height: 10),
                                NewRideCardWidget(
                                  isActive: true,
                                  ride: controller.runningRide!,
                                  currency: controller.currencySym,
                                  driverImagePath: '${controller.userImagePath}/${controller.runningRide?.user?.avatar}',
                                  press: () {
                                    final ride = controller.runningRide!;
                                    Get.toNamed(RouteHelper.rideDetailsScreen, arguments: ride.id);
                                  },
                                ).animate(onPlay: (controller) => controller.repeat()).shakeX(duration: 1000.ms, delay: 4000.ms, curve: Curves.easeInOut, hz: 4),
                                SizedBox(height: 10),
                                if (controller.rideList.isNotEmpty) ...[
                                  Text(MyStrings.newRide.tr, style: regularDefault.copyWith(color: MyColor.colorBlack, fontSize: 18)),
                                  SizedBox(height: 5),
                                ]
                              ],
                            ),
                    ),
                  ),
                ],
                if (controller.isLoading) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(top: Dimensions.space15, start: Dimensions.space15, end: Dimensions.space15),
                      child: Column(children: List.generate(10, (index) => const RideShimmer())),
                    ),
                  )
                ] else if (controller.isLoading == false && controller.rideList.isEmpty) ...[
                  SliverToBoxAdapter(
                    child: NoDataWidget(text: MyStrings.noRideFoundInYourArea.tr, isRide: true, margin: controller.runningRide?.id != "-1" ? 4 : 8),
                  )
                ] else ...[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        bool isLast = index == controller.rideList.length - 1;

                        return Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: isLast ? 100.0 : 0.0),
                          child: NewRideCardWidget(
                            isActive: true,
                            ride: controller.rideList[index],
                            currency: controller.currencySym,
                            driverImagePath: '${controller.userImagePath}/${controller.rideList[index].user?.avatar}',
                            press: () {
                              final ride = controller.rideList[index];
                              printE((ride.amount));
                              controller.updateMainAmount(StringConverter.formatDouble(ride.amount.toString()));
                              CustomBottomSheet(
                                child: OfferBidBottomSheet(ride: ride),
                              ).customBottomSheet(context);
                            },
                          ),
                        );
                      },
                      childCount: controller.rideList.length,
                    ),
                  ),
                  //   SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(bottom: context.width / 2)))
                ]
              ],
            ),
          ),
        ),
      );
    });
  }
}
