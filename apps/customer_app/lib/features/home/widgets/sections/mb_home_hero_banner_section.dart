import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

// MB Home Hero Banner Section
// ---------------------------
// Brand-aligned banner slider that fits under the header without changing
// the approved MuthoBazar visual tone.

class MBHomeHeroBannerSection extends StatelessWidget {
  final MBHomeSection section;
  final List<MBBanner> banners;
  final void Function(MBBanner banner)? onBannerTap;

  const MBHomeHeroBannerSection({
    super.key,
    required this.section,
    required this.banners,
    this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 170,
      child: PageView.builder(
        itemCount: banners.length,
        controller: PageController(viewportFraction: 0.92),
        padEnds: false,
        itemBuilder: (context, index) {
          final banner = banners[index];

          return Padding(
            padding: const EdgeInsets.only(
              right: MBSpacing.sm,
            ),
            child: GestureDetector(
              onTap: () => onBannerTap?.call(banner),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MBRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: MBColors.shadow.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(MBRadius.xl),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        banner.mobileImageUrl.isNotEmpty
                            ? banner.mobileImageUrl
                            : banner.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(color: MBColors.card);
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.34),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner.titleEn,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: MBAppText.headline3(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (banner.subtitleEn.isNotEmpty) ...[
                                MBSpacing.h(MBSpacing.xxxs),
                                Text(
                                  banner.subtitleEn,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: MBAppText.bodySmall(context).copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}