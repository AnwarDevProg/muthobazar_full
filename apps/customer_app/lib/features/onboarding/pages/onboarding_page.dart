
import 'package:customer_app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_ui/shared_ui.dart';



class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.06;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF8A00),
              Color(0xFFFF6A00),
              Color(0xFFFFB347),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Obx(
                    () {
                  final index = controller.currentPageIndex.value;
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInOut,
                    top: -70 + (index * 8),
                    right: -50 + (index * 6),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  );
                },
              ),
              Obx(
                    () {
                  final index = controller.currentPageIndex.value;
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInOut,
                    bottom: -90 + (index * 10),
                    left: -60 + (index * 5),
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  );
                },
              ),

              PageView(
                controller: controller.pageController,
                onPageChanged: controller.updatePageIndicator,
                children: const [
                  _OnBoardingPageView(
                    headline: TTexts.onBoardingHeadline1,
                    lottieAnimation: 'assets/lottie/BuyOnline.json',
                    title: TTexts.onBoardingTitle1,
                    subTitle: TTexts.onBoardingSubTitle1,
                  ),
                  _OnBoardingPageView(
                    headline: TTexts.onBoardingHeadline2,
                    lottieAnimation: 'assets/lottie/Payment.json',
                    title: TTexts.onBoardingTitle2,
                    subTitle: TTexts.onBoardingSubTitle2,
                  ),
                  _OnBoardingPageView(
                    headline: TTexts.onBoardingHeadline3,
                    lottieAnimation: 'assets/lottie/Delivery.json',
                    title: TTexts.onBoardingTitle3,
                    subTitle: TTexts.onBoardingSubTitle3,
                  ),
                  _OnBoardingPageView(
                    headline: TTexts.onBoardingHeadline4,
                    lottieAnimation: 'assets/lottie/SaveTime.json',
                    title: TTexts.onBoardingTitle4,
                    subTitle: TTexts.onBoardingSubTitle4,
                  ),
                ],
              ),

              Obx(() {
                final isLastPage = controller.currentPageIndex.value == 3;

                if (isLastPage) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  top: 8,
                  right: horizontalPadding * 0.3,
                  child: TextButton(
                    onPressed: controller.skipPage,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),

              Positioned(
                left: horizontalPadding,
                bottom: bottomSafeArea + 34,
                child: SmoothPageIndicator(
                  controller: controller.pageController,
                  count: 4,
                  onDotClicked: controller.dotNavigationClick,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withValues(alpha: 0.35),
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3.2,
                    spacing: 8,
                  ),
                ),
              ),

              Positioned(
                right: horizontalPadding,
                bottom: bottomSafeArea + 18,
                child: Obx(
                      () {
                    final isLastPage = controller.currentPageIndex.value == 3;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 58,
                      width: isLastPage ? 150 : 58,
                      child: ElevatedButton(
                        onPressed: controller.nextPage,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF6A00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: isLastPage
                            ? const Text(
                          'Get Started',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        )
                            : const Icon(
                          Icons.arrow_forward_rounded,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnBoardingPageView extends StatefulWidget {
  final String headline;
  final String lottieAnimation;
  final String title;
  final String subTitle;

  const _OnBoardingPageView({
    required this.headline,
    required this.lottieAnimation,
    required this.title,
    required this.subTitle,
  });

  @override
  State<_OnBoardingPageView> createState() => _OnBoardingPageViewState();
}

class _OnBoardingPageViewState extends State<_OnBoardingPageView>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  late final AnimationController _textController;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textOffset;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 24,
      end: 40,
    ).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textOffset = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cardWidth = size.width > 700 ? 520 : size.width * 0.88;
    final double topSpacing = size.height * 0.10;
    final double animationSize = size.width * 0.60;

    return Padding(
      padding: EdgeInsets.only(
        top: topSpacing,
        left: size.width * 0.06,
        right: size.width * 0.06,
        bottom: size.height * 0.12,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: cardWidth),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.07,
              vertical: size.height * 0.045,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.90),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                  color: Colors.black.withValues(alpha: 0.10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color(0xFFFFF1E6),
                    border: Border.all(
                      color: const Color(0xFFFF8A00).withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    widget.headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFF6A00),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),

                const Spacer(),

                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: animationSize,
                      height: animationSize,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0x80FF5900),
                            Color(0x98FF5900),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: _glowAnimation.value,
                            spreadRadius: 4,
                            offset: const Offset(0, 18),
                            color: const Color(0xCAFF001E).withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ],
                      ),
                      child: Lottie.asset(
                        widget.lottieAnimation,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),

                SizedBox(height: size.height * 0.07),

                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textOffset,
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textOffset,
                    child: Text(
                      widget.subTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151).withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}















