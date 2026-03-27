// Phone Input With +88 Prefix
// ---------------------------
// Designed for MuthoBazar orange fintech style UI.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_ui/shared_ui.dart';

class PhoneInputWithPrefix extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;

  const PhoneInputWithPrefix({
    super.key,
    required this.controller,
    this.errorText,
    this.onTap,
    this.onEditingComplete,
    this.onChanged,
  });

  @override
  State<PhoneInputWithPrefix> createState() => _PhoneInputWithPrefixState();
}

class _PhoneInputWithPrefixState extends State<PhoneInputWithPrefix> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.errorText != null
        ? Colors.red
        : _focused
        ? MBColors.primary
        : Colors.grey.shade300;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: _focused ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          /// Prefix
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: MBColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
            child: const Text(
              '+88',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),

          /// Phone Input
          Expanded(
            child: Focus(
              onFocusChange: (value) {
                setState(() {
                  _focused = value;
                });
              },
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onTap: widget.onTap,
                onChanged: widget.onChanged,
                onEditingComplete: widget.onEditingComplete,
                decoration: const InputDecoration(
                  hintText: '017XXXXXXXX',
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}