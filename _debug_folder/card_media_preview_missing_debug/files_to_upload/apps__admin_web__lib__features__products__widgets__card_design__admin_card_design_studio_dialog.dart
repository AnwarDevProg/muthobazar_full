import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/design_studio/mb_card_design_studio.dart';

// MuthoBazar Admin Card Design Studio Dialog
// -----------------------------------------
// Admin-side bridge for the reusable MBCardDesignStudio.
//
// Purpose:
// - Open the new design-family card studio from admin product create/edit.
// - Use the current product form as the live preview product.
// - Return design JSON to the caller.
// - No Firestore write happens here; the product form/repository should decide
//   where to store the returned JSON.
//
// Intended next storage field:
// product.cardDesignJson or product.cardDesign
// depending on the final MBProduct model update.

class AdminCardDesignStudioDialogResult {
  const AdminCardDesignStudioDialogResult({
    required this.designState,
    required this.designJson,
  });

  final Map<String, Object?> designState;
  final String designJson;
}

class AdminCardDesignStudioDialog extends StatelessWidget {
  const AdminCardDesignStudioDialog({
    super.key,
    required this.previewProduct,
    this.initialDesignJson,
    this.title = 'Product Card Design Studio',
  });

  final MBProduct previewProduct;
  final String? initialDesignJson;
  final String title;

  static Future<AdminCardDesignStudioDialogResult?> show(
    BuildContext context, {
    required MBProduct previewProduct,
    String? initialDesignJson,
    String title = 'Product Card Design Studio',
  }) {
    return showDialog<AdminCardDesignStudioDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AdminCardDesignStudioDialog(
          previewProduct: previewProduct,
          initialDesignJson: initialDesignJson,
          title: title,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = math.min(1320.0, screenSize.width - 32);
    final dialogHeight = math.min(900.0, screenSize.height - 32);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            _DialogHeader(title: title),
            const Divider(height: 1),
            Expanded(
              child: MBCardDesignStudio(
                products: <MBProduct>[previewProduct],
                initialProductIndex: 0,
                wrapWithScaffold: false,
                backgroundColor: const Color(0xFFF6F7FB),
                title: title,
                initialDesignJson: initialDesignJson,
                showSaveButton: true,
                saveButtonLabel: 'Use this design',
                onSave: (designState, designJson) {
                  Navigator.of(context).pop(
                    AdminCardDesignStudioDialogResult(
                      designState: Map<String, Object?>.from(designState),
                      designJson: designJson,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      child: Row(
        children: [
          Icon(
            Icons.design_services_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
