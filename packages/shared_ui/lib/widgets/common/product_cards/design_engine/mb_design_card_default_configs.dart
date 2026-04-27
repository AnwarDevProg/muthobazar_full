import 'package:shared_models/shared_models.dart';

// MuthoBazar Design Card Engine V1
// Default configs for preview/admin card studio.
// This uses the new cardDesign system only.

class MBDesignCardDefaultConfigs {
  const MBDesignCardDefaultConfigs._();

  static MBCardDesignConfig heroPosterCircleDiagonalV1({
    String? presetId,
  }) {
    const templateId = MBCardDesignRegistry.heroPosterCircleDiagonalV1;

    return MBCardDesignConfig(
      designFamily: MBCardDesignFamily.heroPosterCircle,
      templateId: templateId,
      version: 1,
      presetId: presetId,
      layout: MBCardDesignRegistry.defaultLayoutForTemplate(templateId),
      elements: MBCardDesignRegistry.defaultElementsForTemplate(templateId),
      metadata: const <String, Object?>{
        'source': 'default_config_factory',
        'renderer': 'design_engine_v1',
      },
    );
  }
}
