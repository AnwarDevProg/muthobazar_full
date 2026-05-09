// MuthoBazar Studio V4 Draft Bridge Result
//
// Purpose:
// - Carries a returned Studio V4 draft JSON plus safe metadata.
// - Used as the bridge between the preview-only V4 Lab and the current
//   production Studio V3 screen.
// - Product save is intentionally not wired yet; this prepares the future
//   admin product-form integration path.

import 'dart:convert';

class MBStudioV4DraftBridgeResult {
  const MBStudioV4DraftBridgeResult({
    required this.json,
    this.schemaVersion,
    this.documentId,
    this.documentName,
    this.nodeCount = 0,
    this.canvasWidth,
    this.canvasHeight,
    this.layoutType,
    this.previewOnly = true,
    this.source = 'studio_v4_lab',
    this.createdAtIso,
    this.summary = const <String, dynamic>{},
  });

  final String json;
  final int? schemaVersion;
  final String? documentId;
  final String? documentName;
  final int nodeCount;
  final double? canvasWidth;
  final double? canvasHeight;
  final String? layoutType;
  final bool previewOnly;
  final String source;
  final String? createdAtIso;
  final Map<String, dynamic> summary;

  bool get hasJson => json.trim().isNotEmpty;
  bool get hasValidCanvas =>
      canvasWidth != null &&
      canvasHeight != null &&
      canvasWidth! > 0 &&
      canvasHeight! > 0;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'documentId': documentId,
      'documentName': documentName,
      'nodeCount': nodeCount,
      'canvasWidth': canvasWidth,
      'canvasHeight': canvasHeight,
      'layoutType': layoutType,
      'previewOnly': previewOnly,
      'source': source,
      'createdAtIso': createdAtIso,
      'summary': summary,
    };
  }

  String toPrettySummaryJson() {
    return const JsonEncoder.withIndent('  ').convert(toMap());
  }

  factory MBStudioV4DraftBridgeResult.fromJsonString(
    String json, {
    bool previewOnly = true,
    String source = 'studio_v4_lab',
  }) {
    int? schemaVersion;
    String? documentId;
    String? documentName;
    var nodeCount = 0;
    double? canvasWidth;
    double? canvasHeight;
    String? layoutType;
    Map<String, dynamic> summary = const <String, dynamic>{};

    try {
      final decoded = jsonDecode(json);
      if (decoded is Map) {
        final map = <String, dynamic>{
          for (final entry in decoded.entries) entry.key.toString(): entry.value,
        };

        final rawSchema = map['schemaVersion'];
        if (rawSchema is num) schemaVersion = rawSchema.toInt();

        final rawId = map['id'];
        if (rawId is String && rawId.trim().isNotEmpty) {
          documentId = rawId.trim();
        }

        final rawName = map['name'];
        if (rawName is String && rawName.trim().isNotEmpty) {
          documentName = rawName.trim();
        }

        final rawNodes = map['nodes'];
        if (rawNodes is List) nodeCount = rawNodes.length;

        final rawCanvas = map['canvas'];
        if (rawCanvas is Map) {
          final canvasMap = <String, dynamic>{
            for (final entry in rawCanvas.entries)
              entry.key.toString(): entry.value,
          };
          final rawWidth = canvasMap['width'];
          final rawHeight = canvasMap['height'];
          final rawLayoutType = canvasMap['layoutType'];
          if (rawWidth is num) canvasWidth = rawWidth.toDouble();
          if (rawHeight is num) canvasHeight = rawHeight.toDouble();
          if (rawLayoutType is String && rawLayoutType.trim().isNotEmpty) {
            layoutType = rawLayoutType.trim();
          }
        }

        summary = <String, dynamic>{
          'schemaVersion': schemaVersion,
          'documentId': documentId,
          'documentName': documentName,
          'nodeCount': nodeCount,
          'canvasWidth': canvasWidth,
          'canvasHeight': canvasHeight,
          'layoutType': layoutType,
          'previewOnly': previewOnly,
          'source': source,
        };
      }
    } catch (_) {
      summary = <String, dynamic>{
        'previewOnly': previewOnly,
        'source': source,
        'parseStatus': 'invalid_json',
      };
    }

    return MBStudioV4DraftBridgeResult(
      json: json,
      schemaVersion: schemaVersion,
      documentId: documentId,
      documentName: documentName,
      nodeCount: nodeCount,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      layoutType: layoutType,
      previewOnly: previewOnly,
      source: source,
      createdAtIso: DateTime.now().toIso8601String(),
      summary: summary,
    );
  }
}
