// MuthoBazar Studio V4 Editor State
//
// Purpose:
// - Stores UI-only workspace state for Studio V4.
// - This is not the saved card-design JSON. The saved design document lives
//   in shared_models as MBCardDesignDocumentV4.

import 'package:flutter/foundation.dart';

enum MBStudioV4Tool {
  select,
  hand,
  text,
  shape,
  media,
}

@immutable
class MBStudioV4EditorState {
  const MBStudioV4EditorState({
    this.selectedNodeIds = const <String>[],
    this.activeTool = MBStudioV4Tool.select,
    this.zoom = 1,
    this.panX = 0,
    this.panY = 0,
    this.showGrid = true,
    this.showGuides = true,
    this.snapEnabled = true,
    this.layersPanelOpen = true,
    this.inspectorPanelOpen = true,
    this.dirty = false,
  });

  final List<String> selectedNodeIds;
  final MBStudioV4Tool activeTool;
  final double zoom;
  final double panX;
  final double panY;
  final bool showGrid;
  final bool showGuides;
  final bool snapEnabled;
  final bool layersPanelOpen;
  final bool inspectorPanelOpen;
  final bool dirty;

  bool get hasSelection => selectedNodeIds.isNotEmpty;
  String? get primarySelectedNodeId =>
      selectedNodeIds.isEmpty ? null : selectedNodeIds.first;

  MBStudioV4EditorState copyWith({
    List<String>? selectedNodeIds,
    MBStudioV4Tool? activeTool,
    double? zoom,
    double? panX,
    double? panY,
    bool? showGrid,
    bool? showGuides,
    bool? snapEnabled,
    bool? layersPanelOpen,
    bool? inspectorPanelOpen,
    bool? dirty,
  }) {
    return MBStudioV4EditorState(
      selectedNodeIds: selectedNodeIds ?? this.selectedNodeIds,
      activeTool: activeTool ?? this.activeTool,
      zoom: (zoom ?? this.zoom).clamp(0.25, 4).toDouble(),
      panX: panX ?? this.panX,
      panY: panY ?? this.panY,
      showGrid: showGrid ?? this.showGrid,
      showGuides: showGuides ?? this.showGuides,
      snapEnabled: snapEnabled ?? this.snapEnabled,
      layersPanelOpen: layersPanelOpen ?? this.layersPanelOpen,
      inspectorPanelOpen: inspectorPanelOpen ?? this.inspectorPanelOpen,
      dirty: dirty ?? this.dirty,
    );
  }

  MBStudioV4EditorState selectSingle(String nodeId) {
    return copyWith(selectedNodeIds: <String>[nodeId]);
  }

  MBStudioV4EditorState selectMany(List<String> nodeIds) {
    final unique = <String>[];
    for (final nodeId in nodeIds) {
      if (nodeId.trim().isEmpty) continue;
      if (!unique.contains(nodeId)) unique.add(nodeId);
    }
    return copyWith(selectedNodeIds: unique);
  }

  MBStudioV4EditorState toggleSelection(String nodeId) {
    if (nodeId.trim().isEmpty) return this;

    final next = <String>[...selectedNodeIds];
    if (next.contains(nodeId)) {
      next.remove(nodeId);
    } else {
      next.add(nodeId);
    }

    return copyWith(selectedNodeIds: next);
  }

  MBStudioV4EditorState clearSelection() {
    return copyWith(selectedNodeIds: const <String>[]);
  }
}
