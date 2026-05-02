import 'package:flutter/material.dart';

// MuthoBazar Design Card Engine V1
// Mobile preview frame for admin card studio/customer lab.

class MBDesignCardMobilePreviewFrame extends StatelessWidget {
  const MBDesignCardMobilePreviewFrame({
    super.key,
    required this.child,
    this.width = 390,
    this.height = 760,
    this.title = 'Card preview',
    this.subtitle,
    this.showDeviceLabel = true,
  });

  final Widget child;
  final double width;
  final double height;
  final String title;
  final String? subtitle;
  final bool showDeviceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: BoxConstraints(
        minHeight: height,
        maxHeight: height,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          color: const Color(0xFFF6F7FB),
          child: Column(
            children: [
              const _StatusArea(),
              if (showDeviceLabel)
                _Label(
                  title: title,
                  subtitle: subtitle,
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusArea extends StatelessWidget {
  const _StatusArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      color: Colors.white,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 92,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Positioned(
            left: 16,
            top: 9,
            child: Text(
              '9:41',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Positioned(
            right: 14,
            top: 8,
            child: Icon(
              Icons.battery_full_rounded,
              size: 17,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF222222),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF777777),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
