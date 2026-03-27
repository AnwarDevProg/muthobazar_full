// Auth Header Widget
// ------------------

import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    //final bool isTablet = MediaQuery.of(context).size.width > 600;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.15,   // slightly taller to avoid compression
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: MBGradients.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(MBRadius.xl),
          bottomRight: Radius.circular(MBRadius.xl),
        ),
      ),
      child: Stack(
        children: [
          /// background circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// main header content
          SafeArea(
            bottom: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: MBSpacing.xxs,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// icon
                    //Container(
                    //  width: isTablet ? 76 : 66,
                    //  height: isTablet ? 76 : 66,
                    //  decoration: BoxDecoration(
                    //    color: Colors.white.withValues(alpha: 0.18),
                   //     borderRadius: BorderRadius.circular(MBRadius.lg),
                   //   ),
                      //child: Icon(
                       // Icons.shopping_cart_outlined,
                       // color: Colors.white,
                      //  size: MBSizeTokens.iconXl(context),
                      //),
                   // ),

                    //MBSpacing.h(MBSpacing.md),

                    /// title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MBAppText.headline1(context).copyWith(
                        color: MBColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    MBSpacing.h(MBSpacing.xs),

                    /// subtitle
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: MBAppText.body(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}