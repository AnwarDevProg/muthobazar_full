// MuthoBazar Studio V4 Controller
//
// Purpose:
// - Owns Studio V4 editor state and document mutations.
// - Uses command history so future UI patches can support undo/redo.
// - Includes layer, canvas, inspector, element-library, and block-library commands for Studio V4.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

import '../commands/mb_studio_v4_command.dart';
import '../models/mb_studio_v4_editor_state.dart';
import 'mb_studio_v4_history_controller.dart';

class MBStudioV4Controller extends ChangeNotifier {
  MBStudioV4Controller({
    MBCardDesignDocumentV4? initialDocument,
    MBStudioV4HistoryController? historyController,
  })  : _document = initialDocument ?? MBCardDesignDocumentV4.blank(),
        history = historyController ?? MBStudioV4HistoryController();

  MBCardDesignDocumentV4 _document;
  MBStudioV4EditorState _editorState = const MBStudioV4EditorState();

  final MBStudioV4HistoryController history;

  List<MBDesignNodeV4> _clipboardNodes = const <MBDesignNodeV4>[];

  bool get canUndo => history.canUndo;
  bool get canRedo => history.canRedo;
  int get undoCount => history.undoCount;
  int get redoCount => history.redoCount;
  String get lastUndoDescription => history.lastUndoDescription;
  String get lastRedoDescription => history.lastRedoDescription;
  bool get hasClipboard => _clipboardNodes.isNotEmpty;
  int get clipboardCount => _clipboardNodes.length;

  String get clipboardStatusLabel {
    if (_clipboardNodes.isEmpty) return 'Clipboard empty';
    if (_clipboardNodes.length == 1) return '1 copied layer';
    return '${_clipboardNodes.length} copied layers';
  }

  MBCardDesignDocumentV4 get document => _document;
  MBStudioV4EditorState get editorState => _editorState;

  List<MBDesignNodeV4> get layerNodes => <MBDesignNodeV4>[
        ..._document.sortedNodes.reversed,
      ];

  MBDesignNodeV4? get selectedNode {
    final id = _editorState.primarySelectedNodeId;
    if (id == null) return null;
    return _document.nodeById(id);
  }

  List<MBDesignNodeV4> get selectedNodes {
    return <MBDesignNodeV4>[
      for (final nodeId in _editorState.selectedNodeIds)
        if (_document.nodeById(nodeId) != null) _document.nodeById(nodeId)!,
    ];
  }

  bool get hasMultiSelection => selectedNodes.length > 1;

  bool get canGroupSelected {
    final nodes = selectedNodes
        .where((node) => !node.locked && node.type != MBDesignNodeTypeV4.group)
        .toList();
    return nodes.length > 1;
  }

  bool get canUngroupSelected {
    final node = selectedNode;
    return node != null && node.type == MBDesignNodeTypeV4.group && !node.locked;
  }

  void replaceDocument(MBCardDesignDocumentV4 document, {bool resetHistory = true}) {
    _document = document;
    _editorState = _editorState.clearSelection().copyWith(dirty: false);
    if (resetHistory) history.clear();
    notifyListeners();
  }

  void updateEditorState(MBStudioV4EditorState next) {
    _editorState = next;
    notifyListeners();
  }

  void selectCard() {
    _editorState = _editorState.clearSelection();
    notifyListeners();
  }

  void selectNode(String nodeId, {bool additive = false}) {
    if (_document.nodeById(nodeId) == null) return;

    if (additive) {
      final nextState = _editorState.toggleSelection(nodeId);
      _editorState = nextState.hasSelection ? nextState : _editorState.selectSingle(nodeId);
    } else {
      _editorState = _editorState.selectSingle(nodeId);
    }

    notifyListeners();
  }

  void selectNodes(List<String> nodeIds) {
    final valid = <String>[
      for (final nodeId in nodeIds)
        if (_document.nodeById(nodeId) != null) nodeId,
    ];
    _editorState = valid.isEmpty
        ? _editorState.clearSelection()
        : _editorState.selectMany(valid);
    notifyListeners();
  }

  void setTool(MBStudioV4Tool tool) {
    _editorState = _editorState.copyWith(activeTool: tool);
    notifyListeners();
  }

  void commitDocument(
    MBCardDesignDocumentV4 next, {
    required String description,
  }) {
    final before = _document;
    if (identical(before, next) || before.toJson() == next.toJson()) return;
    _document = next;
    _editorState = _editorState.copyWith(dirty: true);
    history.record(
      MBStudioV4DocumentCommand(
        description: description,
        before: before,
        after: next,
      ),
    );
    notifyListeners();
  }

  void upsertNode(MBDesignNodeV4 node, {String description = 'Update node'}) {
    commitDocument(_document.upsertNode(node), description: description);
    selectNode(node.id);
  }

  void removeSelectedNode() {
    final id = _editorState.primarySelectedNodeId;
    if (id == null) return;
    deleteNode(id);
  }

  void toggleNodeVisibility(String nodeId) {
    final node = _document.nodeById(nodeId);
    if (node == null) return;

    final nextNode = node.copyWith(visible: !node.visible);
    commitDocument(
      _document.upsertNode(nextNode),
      description: node.visible ? 'Hide layer' : 'Show layer',
    );
    selectNode(nodeId);
  }

  void toggleNodeLock(String nodeId) {
    final node = _document.nodeById(nodeId);
    if (node == null) return;

    final nextNode = node.copyWith(locked: !node.locked);
    commitDocument(
      _document.upsertNode(nextNode),
      description: node.locked ? 'Unlock layer' : 'Lock layer',
    );
    selectNode(nodeId);
  }

  void duplicateNode(String nodeId) {
    final node = _document.nodeById(nodeId);
    if (node == null || node.locked) return;

    final now = DateTime.now().microsecondsSinceEpoch;
    final duplicate = node.copyWith(
      id: '${node.id}_copy_$now',
      name: '${node.name} copy',
      transform: node.transform.copyWith(
        x: node.transform.x + 0.03,
        y: node.transform.y + 0.03,
        zIndex: node.transform.zIndex + 1,
      ),
    );

    commitDocument(
      _document.upsertNode(duplicate),
      description: 'Duplicate layer',
    );
    selectNode(duplicate.id);
  }

  void deleteNode(String nodeId) {
    final node = _document.nodeById(nodeId);
    if (node == null || node.locked) return;

    commitDocument(
      _document.removeNode(nodeId),
      description: 'Delete layer',
    );

    final remainingSelection = <String>[
      for (final id in _editorState.selectedNodeIds)
        if (id != nodeId && _document.nodeById(id) != null) id,
    ];
    _editorState = _editorState.copyWith(selectedNodeIds: remainingSelection);
    notifyListeners();
  }

  void bringNodeForward(String nodeId) {
    _moveNodeLayer(nodeId, 1, 'Bring layer forward');
  }

  void sendNodeBackward(String nodeId) {
    _moveNodeLayer(nodeId, -1, 'Send layer backward');
  }

  void bringNodeToFront(String nodeId) {
    final node = _document.nodeById(nodeId);
    if (node == null || node.locked) return;

    final highest = _document.nodes.isEmpty
        ? 0
        : _document.nodes
            .map((item) => item.transform.zIndex)
            .reduce((a, b) => a > b ? a : b);

    final nextNode = node.copyWith(
      transform: node.transform.copyWith(zIndex: highest + 1),
    );

    commitDocument(
      _document.upsertNode(nextNode),
      description: 'Bring layer to front',
    );
    selectNode(nodeId);
  }

  void sendNodeToBack(String nodeId) {
    final node = _document.nodeById(nodeId);
    if (node == null || node.locked) return;

    final lowest = _document.nodes.isEmpty
        ? 0
        : _document.nodes
            .map((item) => item.transform.zIndex)
            .reduce((a, b) => a < b ? a : b);

    final nextNode = node.copyWith(
      transform: node.transform.copyWith(zIndex: lowest - 1),
    );

    commitDocument(
      _document.upsertNode(nextNode),
      description: 'Send layer to back',
    );
    selectNode(nodeId);
  }

  void _moveNodeLayer(String nodeId, int delta, String description) {
    final node = _document.nodeById(nodeId);
    if (node == null || node.locked) return;

    final nextZ = node.transform.zIndex + delta;
    final nextNode = node.copyWith(
      transform: node.transform.copyWith(zIndex: nextZ),
    );

    commitDocument(
      _document.upsertNode(nextNode),
      description: description,
    );
    selectNode(nodeId);
  }



  void setZoom(double zoom) {
    _editorState = _editorState.copyWith(zoom: zoom);
    notifyListeners();
  }

  void zoomIn() {
    setZoom(_editorState.zoom + 0.1);
  }

  void zoomOut() {
    setZoom(_editorState.zoom - 0.1);
  }

  void resetViewport() {
    _editorState = _editorState.copyWith(
      zoom: 1,
      panX: 0,
      panY: 0,
    );
    notifyListeners();
  }

  void toggleGrid() {
    _editorState = _editorState.copyWith(showGrid: !_editorState.showGrid);
    notifyListeners();
  }

  void toggleGuides() {
    _editorState = _editorState.copyWith(showGuides: !_editorState.showGuides);
    notifyListeners();
  }

  void toggleSnap() {
    _editorState = _editorState.copyWith(snapEnabled: !_editorState.snapEnabled);
    notifyListeners();
  }

  void alignSelectedLeft() {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final canvasWidth = _safeDimension(_document.canvas.width);
    _updateSelectedNodePosition(
      node,
      x: (node.transform.width / 2) / canvasWidth,
      description: 'Align layer left',
    );
  }

  void alignSelectedCenterX() {
    final node = selectedNode;
    if (node == null || node.locked) return;

    _updateSelectedNodePosition(
      node,
      x: 0.5,
      description: 'Align layer center',
    );
  }

  void alignSelectedRight() {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final canvasWidth = _safeDimension(_document.canvas.width);
    _updateSelectedNodePosition(
      node,
      x: 1 - ((node.transform.width / 2) / canvasWidth),
      description: 'Align layer right',
    );
  }

  void alignSelectedTop() {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final canvasHeight = _safeDimension(_document.canvas.height);
    _updateSelectedNodePosition(
      node,
      y: (node.transform.height / 2) / canvasHeight,
      description: 'Align layer top',
    );
  }

  void alignSelectedMiddleY() {
    final node = selectedNode;
    if (node == null || node.locked) return;

    _updateSelectedNodePosition(
      node,
      y: 0.5,
      description: 'Align layer middle',
    );
  }

  void alignSelectedBottom() {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final canvasHeight = _safeDimension(_document.canvas.height);
    _updateSelectedNodePosition(
      node,
      y: 1 - ((node.transform.height / 2) / canvasHeight),
      description: 'Align layer bottom',
    );
  }

  void snapSelectedToCardCenterX() {
    final node = selectedNode;
    if (node == null || node.locked) return;

    _updateSelectedNodePosition(
      node,
      x: 0.5,
      description: 'Snap layer to card center X',
    );
  }

  void snapSelectedToCardCenterY() {
    final node = selectedNode;
    if (node == null || node.locked) return;

    _updateSelectedNodePosition(
      node,
      y: 0.5,
      description: 'Snap layer to card center Y',
    );
  }

  void _updateSelectedNodePosition(
    MBDesignNodeV4 node, {
    double? x,
    double? y,
    required String description,
  }) {
    final nextTransform = node.transform.copyWith(
      x: x == null ? null : _clamp01(x),
      y: y == null ? null : _clamp01(y),
    );

    if (nextTransform.toMap().toString() == node.transform.toMap().toString()) {
      return;
    }

    commitDocument(
      _document.upsertNode(node.copyWith(transform: nextTransform)),
      description: description,
    );
    selectNode(node.id);
  }

  void nudgeSelectedNode({double dx = 0, double dy = 0}) {
    final id = _editorState.primarySelectedNodeId;
    if (id == null) return;
    moveNodeByCanvasDelta(id, dx: dx, dy: dy, description: 'Nudge layer');
  }

  void moveSelectedNodeByCanvasDelta({required double dx, required double dy}) {
    final id = _editorState.primarySelectedNodeId;
    if (id == null) return;
    moveNodeByCanvasDelta(id, dx: dx, dy: dy, description: 'Move layer');
  }

  void moveNodeByCanvasDelta(
    String nodeId, {
    required double dx,
    required double dy,
    String description = 'Move layer',
  }) {
    final node = _document.nodeById(nodeId);
    if (node == null || node.locked) return;

    final canvasWidth = _safeDimension(_document.canvas.width);
    final canvasHeight = _safeDimension(_document.canvas.height);
    var nextTransform = node.transform.copyWith(
      x: _clamp01(node.transform.x + (dx / canvasWidth)),
      y: _clamp01(node.transform.y + (dy / canvasHeight)),
    );

    if (_editorState.snapEnabled) {
      nextTransform = _snapTransformToCanvas(nextTransform);
    }

    commitDocument(
      _document.upsertNode(node.copyWith(transform: nextTransform)),
      description: description,
    );
    selectNode(nodeId);
  }



  void updateSelectedNodeName(String value) {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final nextName = value.trim();
    if (nextName.isEmpty || nextName == node.name) return;

    commitDocument(
      _document.upsertNode(node.copyWith(name: nextName)),
      description: 'Rename layer',
    );
    selectNode(node.id);
  }

  void setSelectedNodeVisibility(bool visible) {
    final node = selectedNode;
    if (node == null || node.visible == visible) return;

    commitDocument(
      _document.upsertNode(node.copyWith(visible: visible)),
      description: visible ? 'Show layer' : 'Hide layer',
    );
    selectNode(node.id);
  }

  void setSelectedNodeLocked(bool locked) {
    final node = selectedNode;
    if (node == null || node.locked == locked) return;

    commitDocument(
      _document.upsertNode(node.copyWith(locked: locked)),
      description: locked ? 'Lock layer' : 'Unlock layer',
    );
    selectNode(node.id);
  }

  void updateSelectedNodeTransform({
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? opacity,
    int? zIndex,
  }) {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final nextTransform = node.transform.copyWith(
      x: x == null ? null : _clamp01(x),
      y: y == null ? null : _clamp01(y),
      width: width == null ? null : _clampDimension(width),
      height: height == null ? null : _clampDimension(height),
      rotation: rotation,
      opacity: opacity == null ? null : _clamp01(opacity),
      zIndex: zIndex,
    );

    if (nextTransform.toMap().toString() == node.transform.toMap().toString()) {
      return;
    }

    commitDocument(
      _document.upsertNode(node.copyWith(transform: nextTransform)),
      description: 'Update layer layout',
    );
    selectNode(node.id);
  }



  void updateSelectedNodeFill(String value) {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final raw = value.trim();
    final clearFill = raw.isEmpty || raw.toLowerCase() == 'none';
    final normalized = clearFill ? null : _normalizeColorHex(raw);
    if (!clearFill && normalized == null) return;

    _commitSelectedNodeStyle(
      node,
      node.style.copyWith(
        fill: normalized,
        clearFill: clearFill,
      ),
      description: clearFill ? 'Clear layer fill' : 'Update layer fill',
    );
  }

  void updateSelectedNodeTextColor(String value) {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final raw = value.trim();
    final nextExtra = <String, dynamic>{...node.style.extra};

    if (raw.isEmpty || raw.toLowerCase() == 'none') {
      nextExtra.remove('textColor');
    } else {
      final normalized = _normalizeColorHex(raw);
      if (normalized == null) return;
      nextExtra['textColor'] = normalized;
    }

    _commitSelectedNodeStyle(
      node,
      node.style.copyWith(extra: nextExtra),
      description: 'Update layer text color',
    );
  }

  void updateSelectedNodeBorderColor(String value) {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final raw = value.trim();
    if (raw.isEmpty || raw.toLowerCase() == 'none') {
      _commitSelectedNodeStyle(
        node,
        node.style.copyWith(clearBorder: true),
        description: 'Clear layer border',
      );
      return;
    }

    final normalized = _normalizeColorHex(raw);
    if (normalized == null) return;

    final current = node.style.border;
    _commitSelectedNodeStyle(
      node,
      node.style.copyWith(
        border: MBBorderStyleV4(
          color: normalized,
          width: current?.width ?? 1,
          style: current?.style ?? 'solid',
        ),
      ),
      description: 'Update layer border color',
    );
  }

  void updateSelectedNodeBorderWidth(double value) {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final width = value < 0 ? 0.0 : value;
    if (width <= 0) {
      _commitSelectedNodeStyle(
        node,
        node.style.copyWith(clearBorder: true),
        description: 'Clear layer border',
      );
      return;
    }

    final current = node.style.border;
    _commitSelectedNodeStyle(
      node,
      node.style.copyWith(
        border: MBBorderStyleV4(
          color: current?.color ?? '#FFFFFF',
          width: width,
          style: current?.style ?? 'solid',
        ),
      ),
      description: 'Update layer border width',
    );
  }

  void updateSelectedNodeRadius(double value) {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final radius = value < 0 ? 0.0 : value;
    _commitSelectedNodeStyle(
      node,
      node.style.copyWith(radius: radius),
      description: 'Update layer radius',
    );
  }

  void setSelectedNodeSoftShadow(bool enabled) {
    final node = selectedNode;
    if (node == null || node.locked) return;

    _commitSelectedNodeStyle(
      node,
      node.style.copyWith(
        shadows: enabled
            ? const <MBShadowStyleV4>[
                MBShadowStyleV4(
                  color: '#33000000',
                  blur: 18,
                  spread: 0,
                  offsetX: 0,
                  offsetY: 8,
                ),
              ]
            : const <MBShadowStyleV4>[],
      ),
      description: enabled ? 'Enable soft shadow' : 'Disable soft shadow',
    );
  }


  void setSelectedNodeEffectPreset(String preset) {
    final node = selectedNode;
    if (node == null || node.locked) return;

    final normalized = preset.trim().toLowerCase();
    late final MBDesignStyleV4 nextStyle;
    late final List<MBDesignEffectV4> nextEffects;
    late final String description;

    switch (normalized) {
      case 'soft_shadow':
      case 'softshadow':
        nextStyle = node.style.copyWith(
          shadows: const <MBShadowStyleV4>[
            MBShadowStyleV4(
              color: '#33000000',
              blur: 18,
              spread: 0,
              offsetX: 0,
              offsetY: 8,
            ),
          ],
        );
        nextEffects = const <MBDesignEffectV4>[
          MBDesignEffectV4(
            type: 'softShadow',
            params: <String, dynamic>{'preset': 'soft_shadow'},
          ),
        ];
        description = 'Apply soft shadow effect';
        break;
      case 'product_glow':
      case 'productglow':
        nextStyle = node.style.copyWith(
          shadows: const <MBShadowStyleV4>[
            MBShadowStyleV4(
              color: '#66FFB020',
              blur: 24,
              spread: 2,
              offsetX: 0,
              offsetY: 8,
            ),
          ],
        );
        nextEffects = const <MBDesignEffectV4>[
          MBDesignEffectV4(
            type: 'productGlow',
            params: <String, dynamic>{
              'preset': 'product_glow',
              'color': '#FFFFB020',
            },
          ),
        ];
        description = 'Apply product glow effect';
        break;
      case 'spotlight':
        nextStyle = node.style.copyWith(
          fill: node.style.fill ?? '#22FFFFFF',
          shadows: const <MBShadowStyleV4>[
            MBShadowStyleV4(
              color: '#22000000',
              blur: 20,
              spread: 0,
              offsetX: 0,
              offsetY: 8,
            ),
          ],
        );
        nextEffects = const <MBDesignEffectV4>[
          MBDesignEffectV4(
            type: 'spotlight',
            params: <String, dynamic>{
              'preset': 'spotlight',
              'centerColor': '#CCFFFFFF',
              'edgeColor': '#00FFFFFF',
            },
          ),
        ];
        description = 'Apply spotlight effect';
        break;
      case 'glass_surface':
      case 'glasssurface':
      case 'glass':
        nextStyle = node.style.copyWith(
          fill: '#33FFFFFF',
          border: node.style.border ??
              const MBBorderStyleV4(
                color: '#77FFFFFF',
                width: 1,
              ),
          radius: node.style.radius ?? 18,
          shadows: const <MBShadowStyleV4>[
            MBShadowStyleV4(
              color: '#22000000',
              blur: 22,
              spread: 0,
              offsetX: 0,
              offsetY: 10,
            ),
          ],
        );
        nextEffects = const <MBDesignEffectV4>[
          MBDesignEffectV4(
            type: 'glassSurface',
            params: <String, dynamic>{'preset': 'glass_surface'},
          ),
        ];
        description = 'Apply glass surface effect';
        break;
      case 'none':
      default:
        nextStyle = node.style.copyWith(shadows: const <MBShadowStyleV4>[]);
        nextEffects = const <MBDesignEffectV4>[];
        description = 'Clear layer effects';
        break;
    }

    final nextNode = node.copyWith(
      style: nextStyle,
      effects: nextEffects,
    );

    if (nextNode.toMap().toString() == node.toMap().toString()) return;

    commitDocument(
      _document.upsertNode(nextNode),
      description: description,
    );
    selectNode(node.id);
  }

  void _commitSelectedNodeStyle(
    MBDesignNodeV4 node,
    MBDesignStyleV4 nextStyle, {
    required String description,
  }) {
    if (nextStyle.toMap().toString() == node.style.toMap().toString()) return;

    commitDocument(
      _document.upsertNode(node.copyWith(style: nextStyle)),
      description: description,
    );
    selectNode(node.id);
  }


  void addTextLayer() {
    _insertPresetNode(
      name: 'Product title',
      type: MBDesignNodeTypeV4.text,
      transform: MBDesignTransformV4(
        x: _defaultInsertX(),
        y: _defaultInsertY(),
        width: 142,
        height: 42,
        zIndex: _nextZIndex(),
      ),
      style: const MBDesignStyleV4(
        fill: '#00000000',
        textStyleId: 'card_title_bold',
      ),
      binding: const MBDesignBindingV4(
        source: 'product',
        path: 'titleEn',
        fallbackMode: 'value',
        fallbackValue: 'Fresh product',
      ),
      content: const <String, dynamic>{'text': 'Fresh product'},
      props: const <String, dynamic>{
        'label': 'Title',
        'fontSize': 18,
        'fontWeight': 'w900',
      },
      description: 'Add text layer',
    );
  }

  void addPriceLayer() {
    _insertPresetNode(
      name: 'Price',
      type: MBDesignNodeTypeV4.price,
      transform: MBDesignTransformV4(
        x: _defaultInsertX(),
        y: _defaultInsertY(),
        width: 92,
        height: 38,
        zIndex: _nextZIndex(),
      ),
      style: const MBDesignStyleV4(
        fill: '#111827',
        radius: 16,
        textStyleId: 'price_bold',
      ),
      binding: const MBDesignBindingV4(
        source: 'product',
        path: 'effectivePrice',
        fallbackMode: 'value',
        fallbackValue: '৳120',
        formatter: 'bdt',
      ),
      content: const <String, dynamic>{'text': '৳120'},
      props: const <String, dynamic>{'label': 'Price'},
      description: 'Add price layer',
    );
  }

  void addBadgeLayer() {
    _insertPresetNode(
      name: 'Offer badge',
      type: MBDesignNodeTypeV4.badge,
      transform: MBDesignTransformV4(
        x: _defaultInsertX(),
        y: _defaultInsertY(),
        width: 78,
        height: 30,
        zIndex: _nextZIndex(),
      ),
      style: const MBDesignStyleV4(
        fill: '#EF4444',
        radius: 999,
        shadows: <MBShadowStyleV4>[
          MBShadowStyleV4(
            color: '#33000000',
            blur: 10,
            offsetY: 4,
          ),
        ],
      ),
      content: const <String, dynamic>{'text': '20% OFF'},
      props: const <String, dynamic>{'label': 'Badge'},
      description: 'Add badge layer',
    );
  }

  void addMediaLayer() {
    _insertPresetNode(
      name: 'Product image',
      type: MBDesignNodeTypeV4.media,
      transform: MBDesignTransformV4(
        x: _defaultInsertX(),
        y: _defaultInsertY(),
        width: 126,
        height: 126,
        zIndex: _nextZIndex(),
      ),
      style: const MBDesignStyleV4(
        fill: '#33FFFFFF',
        radius: 22,
      ),
      binding: const MBDesignBindingV4(
        source: 'product',
        path: 'resolvedCardImageUrl',
        fallbackMode: 'placeholder',
      ),
      content: const <String, dynamic>{'text': 'Image'},
      props: const <String, dynamic>{
        'label': 'Product image',
        'imageSource': 'card',
        'fit': 'contain',
      },
      description: 'Add media layer',
    );
  }

  void addTransparentMediaLayer() {
    _insertPresetNode(
      name: 'Transparent product image',
      type: MBDesignNodeTypeV4.media,
      transform: MBDesignTransformV4(
        x: _defaultInsertX(),
        y: _defaultInsertY(),
        width: 136,
        height: 136,
        zIndex: _nextZIndex(),
      ),
      style: const MBDesignStyleV4(
        fill: '#00000000',
        radius: 0,
        shadows: <MBShadowStyleV4>[
          MBShadowStyleV4(
            color: '#44000000',
            blur: 18,
            offsetY: 10,
          ),
        ],
      ),
      binding: const MBDesignBindingV4(
        source: 'product',
        path: 'resolvedCardTransparentImageUrl',
        fallbackMode: 'placeholder',
      ),
      content: const <String, dynamic>{'text': 'Cutout'},
      props: const <String, dynamic>{
        'label': 'Transparent image',
        'imageSource': 'cardTransparent',
        'fit': 'contain',
        'transparentCutout': true,
      },
      description: 'Add transparent media layer',
    );
  }

  void addButtonLayer() {
    _insertPresetNode(
      name: 'CTA button',
      type: MBDesignNodeTypeV4.button,
      transform: MBDesignTransformV4(
        x: _defaultInsertX(),
        y: _defaultInsertY(),
        width: 116,
        height: 38,
        zIndex: _nextZIndex(),
      ),
      style: const MBDesignStyleV4(
        fill: '#16A34A',
        radius: 999,
        shadows: <MBShadowStyleV4>[
          MBShadowStyleV4(
            color: '#3316A34A',
            blur: 14,
            offsetY: 6,
          ),
        ],
      ),
      content: const <String, dynamic>{'text': 'Buy now'},
      props: const <String, dynamic>{'label': 'CTA'},
      description: 'Add CTA button layer',
    );
  }

  void addShapeLayer() {
    _insertPresetNode(
      name: 'Soft shape',
      type: MBDesignNodeTypeV4.shape,
      transform: MBDesignTransformV4(
        x: _defaultInsertX(),
        y: _defaultInsertY(),
        width: 112,
        height: 88,
        zIndex: _nextZIndex(),
      ),
      style: const MBDesignStyleV4(
        fill: '#22FFFFFF',
        radius: 26,
      ),
      content: const <String, dynamic>{'text': ''},
      props: const <String, dynamic>{'label': 'Shape'},
      description: 'Add shape layer',
    );
  }

  void addDeliveryLayer() {
    _insertPresetNode(
      name: 'Delivery chip',
      type: MBDesignNodeTypeV4.delivery,
      transform: MBDesignTransformV4(
        x: _defaultInsertX(),
        y: _defaultInsertY(),
        width: 110,
        height: 28,
        zIndex: _nextZIndex(),
      ),
      style: const MBDesignStyleV4(
        fill: '#0F766E',
        radius: 999,
      ),
      content: const <String, dynamic>{'text': 'Fast delivery'},
      props: const <String, dynamic>{'label': 'Delivery'},
      description: 'Add delivery layer',
    );
  }



  void addPriceOfferBlock() {
    final blockId = _newNodeId('block_price_offer');
    final baseZ = _nextZIndex();
    final priceId = '${blockId}_price';

    _insertBlockNodes(
      description: 'Add price offer block',
      primaryNodeId: priceId,
      nodes: <MBDesignNodeV4>[
        MBDesignNodeV4(
          id: priceId,
          name: 'Block price',
          type: MBDesignNodeTypeV4.price,
          transform: MBDesignTransformV4(
            x: 0.28,
            y: 0.78,
            width: 92,
            height: 38,
            zIndex: baseZ,
          ),
          style: const MBDesignStyleV4(
            fill: '#111827',
            radius: 18,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(
                color: '#33000000',
                blur: 16,
                offsetY: 8,
              ),
            ],
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'effectivePrice',
            fallbackMode: 'value',
            fallbackValue: '৳120',
            formatter: 'bdt',
          ),
          content: const <String, dynamic>{'text': '৳120'},
          props: _blockProps(blockId, 'price', label: 'Price'),
        ),
        MBDesignNodeV4(
          id: '${blockId}_mrp',
          name: 'Block MRP',
          type: MBDesignNodeTypeV4.text,
          transform: MBDesignTransformV4(
            x: 0.63,
            y: 0.79,
            width: 76,
            height: 24,
            zIndex: baseZ + 1,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            textStyleId: 'mrp_strike_small',
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'regularPrice',
            fallbackMode: 'value',
            fallbackValue: '৳150',
            formatter: 'bdtStrike',
          ),
          content: const <String, dynamic>{'text': '৳150'},
          props: _blockProps(blockId, 'mrp', label: 'MRP'),
        ),
        MBDesignNodeV4(
          id: '${blockId}_discount',
          name: 'Block discount badge',
          type: MBDesignNodeTypeV4.badge,
          transform: MBDesignTransformV4(
            x: 0.72,
            y: 0.69,
            width: 78,
            height: 30,
            zIndex: baseZ + 2,
          ),
          style: const MBDesignStyleV4(
            fill: '#EF4444',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(
                color: '#33EF4444',
                blur: 14,
                offsetY: 6,
              ),
            ],
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'discountPercent',
            fallbackMode: 'value',
            fallbackValue: '20% OFF',
          ),
          content: const <String, dynamic>{'text': '20% OFF'},
          props: _blockProps(blockId, 'discount', label: 'Discount'),
        ),
      ],
    );
  }

  void addProductTitleBlock() {
    final blockId = _newNodeId('block_title');
    final baseZ = _nextZIndex();
    final titleId = '${blockId}_title';

    _insertBlockNodes(
      description: 'Add product title block',
      primaryNodeId: titleId,
      nodes: <MBDesignNodeV4>[
        MBDesignNodeV4(
          id: titleId,
          name: 'Block title',
          type: MBDesignNodeTypeV4.text,
          transform: MBDesignTransformV4(
            x: 0.48,
            y: 0.18,
            width: 158,
            height: 42,
            zIndex: baseZ,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            textStyleId: 'card_title_bold',
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'titleEn',
            fallbackMode: 'value',
            fallbackValue: 'Fresh premium product',
          ),
          content: const <String, dynamic>{'text': 'Fresh premium product'},
          props: _blockProps(blockId, 'title', label: 'Title'),
        ),
        MBDesignNodeV4(
          id: '${blockId}_subtitle',
          name: 'Block subtitle',
          type: MBDesignNodeTypeV4.text,
          transform: MBDesignTransformV4(
            x: 0.48,
            y: 0.29,
            width: 148,
            height: 26,
            zIndex: baseZ + 1,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            textStyleId: 'card_subtitle_medium',
          ),
          content: const <String, dynamic>{'text': 'Best quality · fresh stock'},
          props: _blockProps(blockId, 'subtitle', label: 'Subtitle'),
        ),
      ],
    );
  }

  void addCtaBottomBlock() {
    final blockId = _newNodeId('block_cta_bottom');
    final baseZ = _nextZIndex();
    final buttonId = '${blockId}_button';

    _insertBlockNodes(
      description: 'Add CTA bottom block',
      primaryNodeId: buttonId,
      nodes: <MBDesignNodeV4>[
        MBDesignNodeV4(
          id: '${blockId}_surface',
          name: 'CTA glass surface',
          type: MBDesignNodeTypeV4.shape,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.88,
            width: 170,
            height: 52,
            zIndex: baseZ,
          ),
          style: const MBDesignStyleV4(
            fill: '#30FFFFFF',
            radius: 26,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(
                color: '#22000000',
                blur: 16,
                offsetY: 8,
              ),
            ],
          ),
          content: const <String, dynamic>{'text': ''},
          props: _blockProps(blockId, 'surface', label: 'CTA surface'),
        ),
        MBDesignNodeV4(
          id: '${blockId}_mini_price',
          name: 'CTA mini price',
          type: MBDesignNodeTypeV4.price,
          transform: MBDesignTransformV4(
            x: 0.31,
            y: 0.88,
            width: 62,
            height: 30,
            zIndex: baseZ + 1,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            textStyleId: 'price_bold',
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'effectivePrice',
            fallbackMode: 'value',
            fallbackValue: '৳120',
            formatter: 'bdt',
          ),
          content: const <String, dynamic>{'text': '৳120'},
          props: _blockProps(blockId, 'price', label: 'Mini price'),
        ),
        MBDesignNodeV4(
          id: buttonId,
          name: 'CTA buy button',
          type: MBDesignNodeTypeV4.button,
          transform: MBDesignTransformV4(
            x: 0.68,
            y: 0.88,
            width: 88,
            height: 34,
            zIndex: baseZ + 2,
          ),
          style: const MBDesignStyleV4(
            fill: '#16A34A',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(
                color: '#3316A34A',
                blur: 14,
                offsetY: 6,
              ),
            ],
          ),
          content: const <String, dynamic>{'text': 'Buy now'},
          props: _blockProps(blockId, 'button', label: 'CTA'),
        ),
      ],
    );
  }

  void addOfferBadgeBlock() {
    final blockId = _newNodeId('block_offer_badge');
    final baseZ = _nextZIndex();
    final badgeId = '${blockId}_badge';

    _insertBlockNodes(
      description: 'Add offer badge block',
      primaryNodeId: badgeId,
      nodes: <MBDesignNodeV4>[
        MBDesignNodeV4(
          id: '${blockId}_shadow',
          name: 'Offer badge shadow',
          type: MBDesignNodeTypeV4.shape,
          transform: MBDesignTransformV4(
            x: 0.76,
            y: 0.16,
            width: 88,
            height: 44,
            rotation: -8,
            zIndex: baseZ,
          ),
          style: const MBDesignStyleV4(
            fill: '#33FFFFFF',
            radius: 18,
          ),
          content: const <String, dynamic>{'text': ''},
          props: _blockProps(blockId, 'shadow', label: 'Badge shadow'),
        ),
        MBDesignNodeV4(
          id: badgeId,
          name: 'Offer sticker',
          type: MBDesignNodeTypeV4.badge,
          transform: MBDesignTransformV4(
            x: 0.76,
            y: 0.16,
            width: 82,
            height: 36,
            rotation: -8,
            zIndex: baseZ + 1,
          ),
          style: const MBDesignStyleV4(
            fill: '#F97316',
            radius: 16,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(
                color: '#44F97316',
                blur: 16,
                offsetY: 8,
              ),
            ],
          ),
          content: const <String, dynamic>{'text': 'HOT DEAL'},
          props: _blockProps(blockId, 'badge', label: 'Offer badge'),
        ),
      ],
    );
  }

  void addDeliveryChipBlock() {
    final blockId = _newNodeId('block_delivery_chip');
    final baseZ = _nextZIndex();
    final chipId = '${blockId}_delivery';

    _insertBlockNodes(
      description: 'Add delivery chip block',
      primaryNodeId: chipId,
      nodes: <MBDesignNodeV4>[
        MBDesignNodeV4(
          id: chipId,
          name: 'Fast delivery chip',
          type: MBDesignNodeTypeV4.delivery,
          transform: MBDesignTransformV4(
            x: 0.35,
            y: 0.09,
            width: 112,
            height: 28,
            zIndex: baseZ,
          ),
          style: const MBDesignStyleV4(
            fill: '#0F766E',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(
                color: '#330F766E',
                blur: 12,
                offsetY: 5,
              ),
            ],
          ),
          content: const <String, dynamic>{'text': 'Fast delivery'},
          props: _blockProps(blockId, 'delivery', label: 'Delivery'),
        ),
        MBDesignNodeV4(
          id: '${blockId}_stock',
          name: 'Fresh stock chip',
          type: MBDesignNodeTypeV4.stock,
          transform: MBDesignTransformV4(
            x: 0.72,
            y: 0.09,
            width: 74,
            height: 26,
            zIndex: baseZ + 1,
          ),
          style: const MBDesignStyleV4(
            fill: '#ECFDF5',
            radius: 999,
          ),
          content: const <String, dynamic>{'text': 'In stock'},
          props: _blockProps(blockId, 'stock', label: 'Stock'),
        ),
      ],
    );
  }

  void addHeroImageBlock() {
    final blockId = _newNodeId('block_hero_image');
    final baseZ = _nextZIndex();
    final mediaId = '${blockId}_media';

    _insertBlockNodes(
      description: 'Add hero image block',
      primaryNodeId: mediaId,
      nodes: <MBDesignNodeV4>[
        MBDesignNodeV4(
          id: '${blockId}_spotlight',
          name: 'Product spotlight',
          type: MBDesignNodeTypeV4.shape,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.43,
            width: 164,
            height: 164,
            zIndex: baseZ,
          ),
          style: const MBDesignStyleV4(
            fill: '#38FFFFFF',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(
                color: '#22FFFFFF',
                blur: 28,
                offsetY: 0,
              ),
            ],
          ),
          content: const <String, dynamic>{'text': ''},
          props: _blockProps(blockId, 'spotlight', label: 'Spotlight'),
        ),
        MBDesignNodeV4(
          id: mediaId,
          name: 'Hero cutout image',
          type: MBDesignNodeTypeV4.media,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.43,
            width: 154,
            height: 154,
            zIndex: baseZ + 1,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            radius: 0,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(
                color: '#44000000',
                blur: 22,
                offsetY: 12,
              ),
            ],
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'resolvedCardTransparentImageUrl',
            fallbackMode: 'placeholder',
          ),
          content: const <String, dynamic>{'text': 'Cutout'},
          props: _blockProps(
            blockId,
            'media',
            label: 'Hero image',
            extra: const <String, dynamic>{
              'imageSource': 'cardTransparent',
              'fit': 'contain',
              'transparentCutout': true,
            },
          ),
        ),
      ],
    );
  }

  void _insertBlockNodes({
    required List<MBDesignNodeV4> nodes,
    required String description,
    String? primaryNodeId,
  }) {
    if (nodes.isEmpty) return;

    var next = _document;
    for (final node in nodes) {
      next = next.upsertNode(node);
    }

    commitDocument(next, description: description);

    final selectedId = primaryNodeId ?? nodes.first.id;
    if (next.nodeById(selectedId) != null) {
      selectNode(selectedId);
    }
  }

  Map<String, dynamic> _blockProps(
    String blockId,
    String role, {
    String? label,
    Map<String, dynamic> extra = const <String, dynamic>{},
  }) {
    return <String, dynamic>{
      'blockId': blockId,
      'blockRole': role,
      if (label != null) 'label': label,
      ...extra,
    };
  }

  void _insertPresetNode({
    required String name,
    required MBDesignNodeTypeV4 type,
    required MBDesignTransformV4 transform,
    required String description,
    MBDesignStyleV4 style = const MBDesignStyleV4(),
    MBDesignBindingV4? binding,
    Map<String, dynamic> content = const <String, dynamic>{},
    Map<String, dynamic> props = const <String, dynamic>{},
  }) {
    final node = MBDesignNodeV4(
      id: _newNodeId(type.name),
      name: name,
      type: type,
      transform: transform,
      style: style,
      binding: binding,
      content: content,
      props: props,
    );

    commitDocument(
      _document.upsertNode(node),
      description: description,
    );
    selectNode(node.id);
  }

  String _newNodeId(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
  }

  String _copyLayerName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Layer copy';
    if (trimmed.toLowerCase().endsWith(' copy')) return trimmed;
    return '$trimmed copy';
  }

  int _nextZIndex() {
    if (_document.nodes.isEmpty) return 10;
    final highest = _document.nodes
        .map((item) => item.transform.zIndex)
        .reduce((a, b) => a > b ? a : b);
    return highest + 1;
  }

  double _defaultInsertX() {
    final step = (_document.nodes.length % 5) * 0.035;
    return _clamp01(0.5 + step);
  }

  double _defaultInsertY() {
    final step = (_document.nodes.length % 5) * 0.035;
    return _clamp01(0.5 + step);
  }

  MBDesignTransformV4 _snapTransformToCanvas(MBDesignTransformV4 transform) {
    final canvasWidth = _safeDimension(_document.canvas.width);
    final canvasHeight = _safeDimension(_document.canvas.height);
    const snapPx = 6.0;

    var nextX = transform.x;
    var nextY = transform.y;

    final centerX = transform.x * canvasWidth;
    final centerY = transform.y * canvasHeight;
    final halfWidth = transform.width / 2;
    final halfHeight = transform.height / 2;

    final left = centerX - halfWidth;
    final right = centerX + halfWidth;
    final top = centerY - halfHeight;
    final bottom = centerY + halfHeight;

    if ((centerX - (canvasWidth / 2)).abs() <= snapPx) {
      nextX = 0.5;
    } else if (left.abs() <= snapPx) {
      nextX = halfWidth / canvasWidth;
    } else if ((right - canvasWidth).abs() <= snapPx) {
      nextX = (canvasWidth - halfWidth) / canvasWidth;
    }

    if ((centerY - (canvasHeight / 2)).abs() <= snapPx) {
      nextY = 0.5;
    } else if (top.abs() <= snapPx) {
      nextY = halfHeight / canvasHeight;
    } else if ((bottom - canvasHeight).abs() <= snapPx) {
      nextY = (canvasHeight - halfHeight) / canvasHeight;
    }

    return transform.copyWith(
      x: _clamp01(nextX),
      y: _clamp01(nextY),
    );
  }


  void copySelectedNodes() {
    final nodes = selectedNodes
        .where((node) => !node.locked)
        .toList()
      ..sort(MBDesignNodeV4.compareByLayer);

    if (nodes.isEmpty) return;

    _clipboardNodes = List<MBDesignNodeV4>.unmodifiable(nodes);
    notifyListeners();
  }

  void pasteClipboardNodes() {
    if (_clipboardNodes.isEmpty) return;
    _pasteNodes(
      _clipboardNodes,
      description: _clipboardNodes.length == 1 ? 'Paste layer' : 'Paste layers',
      copyNameSuffix: 'copy',
    );
  }

  void duplicateSelectedNodes() {
    final nodes = selectedNodes
        .where((node) => !node.locked)
        .toList()
      ..sort(MBDesignNodeV4.compareByLayer);

    if (nodes.isEmpty) return;

    _pasteNodes(
      nodes,
      description: nodes.length == 1 ? 'Duplicate layer' : 'Duplicate layers',
      copyNameSuffix: 'copy',
    );
  }

  void deleteSelectedNodes() {
    final nodes = selectedNodes.where((node) => !node.locked).toList();
    if (nodes.isEmpty) return;

    var next = _document;
    for (final node in nodes) {
      next = next.removeNode(node.id);
    }

    commitDocument(
      next,
      description: nodes.length == 1 ? 'Delete layer' : 'Delete layers',
    );

    _editorState = _editorState.clearSelection().copyWith(dirty: true);
    notifyListeners();
  }

  void _pasteNodes(
    List<MBDesignNodeV4> nodes, {
    required String description,
    required String copyNameSuffix,
  }) {
    final sourceNodes = nodes
        .where((node) => !node.id.trim().isEmpty)
        .toList()
      ..sort(MBDesignNodeV4.compareByLayer);

    if (sourceNodes.isEmpty) return;

    final now = DateTime.now().microsecondsSinceEpoch;
    final idMap = <String, String>{};
    for (var index = 0; index < sourceNodes.length; index++) {
      final node = sourceNodes[index];
      idMap[node.id] = '${node.id}_${copyNameSuffix}_${now}_$index';
    }

    var next = _document;
    final selectedIds = <String>[];
    final baseZ = _nextZIndex();

    for (var index = 0; index < sourceNodes.length; index++) {
      final node = sourceNodes[index];
      final nextId = idMap[node.id]!;
      final mappedParentId = node.parentId == null ? null : idMap[node.parentId!];
      final nextTransform = node.transform.copyWith(
        x: _clamp01(node.transform.x + 0.04),
        y: _clamp01(node.transform.y + 0.04),
        zIndex: baseZ + index,
      );

      var pastedNode = node.copyWith(
        id: nextId,
        name: _copyLayerName(node.name),
        locked: false,
        transform: nextTransform,
      );

      pastedNode = mappedParentId == null
          ? pastedNode.copyWith(clearParentId: true)
          : pastedNode.copyWith(parentId: mappedParentId);

      next = next.upsertNode(pastedNode);
      selectedIds.add(pastedNode.id);
    }

    commitDocument(next, description: description);
    selectNodes(selectedIds);
  }


  void groupSelectedNodes() {
    final nodes = selectedNodes
        .where((node) => !node.locked && node.type != MBDesignNodeTypeV4.group)
        .toList();

    if (nodes.length < 2) return;

    final canvasWidth = _safeDimension(_document.canvas.width);
    final canvasHeight = _safeDimension(_document.canvas.height);

    var left = double.infinity;
    var top = double.infinity;
    var right = double.negativeInfinity;
    var bottom = double.negativeInfinity;

    for (final node in nodes) {
      final centerX = node.transform.x * canvasWidth;
      final centerY = node.transform.y * canvasHeight;
      final nodeLeft = centerX - (node.transform.width / 2);
      final nodeTop = centerY - (node.transform.height / 2);
      final nodeRight = centerX + (node.transform.width / 2);
      final nodeBottom = centerY + (node.transform.height / 2);

      if (nodeLeft < left) left = nodeLeft;
      if (nodeTop < top) top = nodeTop;
      if (nodeRight > right) right = nodeRight;
      if (nodeBottom > bottom) bottom = nodeBottom;
    }

    final groupId = _newNodeId('group');
    final groupWidth = _clampDimension(right - left);
    final groupHeight = _clampDimension(bottom - top);
    final groupX = _clamp01((left + (groupWidth / 2)) / canvasWidth);
    final groupY = _clamp01((top + (groupHeight / 2)) / canvasHeight);
    final lowest = nodes
        .map((node) => node.transform.zIndex)
        .reduce((a, b) => a < b ? a : b);

    final groupNode = MBDesignNodeV4(
      id: groupId,
      name: 'Group ${nodes.length} layers',
      type: MBDesignNodeTypeV4.group,
      visible: true,
      locked: false,
      transform: MBDesignTransformV4(
        x: groupX,
        y: groupY,
        width: groupWidth,
        height: groupHeight,
        zIndex: lowest - 1,
      ),
      style: const MBDesignStyleV4(
        fill: '#00000000',
        border: MBBorderStyleV4(
          color: '#77FFFFFF',
          width: 1,
        ),
        radius: 12,
      ),
      content: <String, dynamic>{'text': '${nodes.length} layers'},
      props: <String, dynamic>{
        'label': 'Group',
        'groupKind': 'manual',
        'childCount': nodes.length,
      },
    );

    var next = _document.upsertNode(groupNode);
    for (final node in nodes) {
      next = next.upsertNode(node.copyWith(parentId: groupId));
    }

    commitDocument(next, description: 'Group layers');
    selectNode(groupId);
  }

  void ungroupSelectedGroup() {
    final group = selectedNode;
    if (group == null || group.type != MBDesignNodeTypeV4.group || group.locked) {
      return;
    }

    final releasedChildIds = <String>[];
    final nextNodes = <MBDesignNodeV4>[];

    for (final node in _document.nodes) {
      if (node.id == group.id) continue;
      if (node.parentId == group.id) {
        releasedChildIds.add(node.id);
        nextNodes.add(node.copyWith(clearParentId: true));
      } else {
        nextNodes.add(node);
      }
    }

    if (releasedChildIds.isEmpty) {
      commitDocument(
        _document.copyWith(
          nodes: <MBDesignNodeV4>[
            for (final node in _document.nodes)
              if (node.id != group.id) node,
          ],
        ),
        description: 'Remove empty group',
      );
      selectCard();
      return;
    }

    commitDocument(
      _document.copyWith(nodes: nextNodes..sort(MBDesignNodeV4.compareByLayer)),
      description: 'Ungroup layers',
    );
    selectNodes(releasedChildIds);
  }

  void toggleGroupSelected() {
    if (hasMultiSelection) {
      groupSelectedNodes();
    } else if (canUngroupSelected) {
      ungroupSelectedGroup();
    }
  }

  void applyCleanGroceryTemplate() {
    final templateId = _newNodeId('tpl_clean_grocery');
    final baseZ = 10;
    final heroId = '${templateId}_hero_image';

    _applyTemplate(
      templateName: 'Clean Grocery Card',
      description: 'Apply Clean Grocery template',
      primaryNodeId: heroId,
      canvas: const MBDesignCanvasSpecV4(
        width: 200,
        height: 342,
        layoutType: 'v4_clean_grocery_card',
        backgroundMode: 'color',
        backgroundColor: '#FFFFF7ED',
        backgroundGradientId: null,
        borderRadius: 28,
      ),
      nodes: <MBDesignNodeV4>[
        MBDesignNodeV4(
          id: '${templateId}_soft_blob',
          name: 'Fresh soft background',
          type: MBDesignNodeTypeV4.shape,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.35,
            width: 176,
            height: 176,
            zIndex: baseZ,
          ),
          style: const MBDesignStyleV4(
            fill: '#33FDBA74',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#22F97316', blur: 28),
            ],
          ),
          content: const <String, dynamic>{'text': ''},
          props: _templateProps(templateId, 'background', label: 'Fresh glow'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_delivery',
          name: 'Delivery chip',
          type: MBDesignNodeTypeV4.delivery,
          transform: MBDesignTransformV4(
            x: 0.35,
            y: 0.09,
            width: 116,
            height: 28,
            zIndex: baseZ + 1,
          ),
          style: const MBDesignStyleV4(
            fill: '#0F766E',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#330F766E', blur: 10, offsetY: 5),
            ],
          ),
          content: const <String, dynamic>{'text': 'Fresh delivery'},
          props: _templateProps(templateId, 'delivery', label: 'Delivery'),
        ),
        MBDesignNodeV4(
          id: heroId,
          name: 'Hero product cutout',
          type: MBDesignNodeTypeV4.media,
          transform: MBDesignTransformV4(
            x: 0.52,
            y: 0.38,
            width: 150,
            height: 150,
            zIndex: baseZ + 2,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            radius: 0,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#33000000', blur: 20, offsetY: 12),
            ],
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'resolvedCardTransparentImageUrl',
            fallbackMode: 'placeholder',
          ),
          content: const <String, dynamic>{'text': 'Cutout'},
          props: _templateProps(
            templateId,
            'heroImage',
            label: 'Hero image',
            extra: const <String, dynamic>{
              'imageSource': 'cardTransparent',
              'fit': 'contain',
              'transparentCutout': true,
            },
          ),
        ),
        MBDesignNodeV4(
          id: '${templateId}_title',
          name: 'Product title',
          type: MBDesignNodeTypeV4.text,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.64,
            width: 166,
            height: 44,
            zIndex: baseZ + 3,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            textStyleId: 'card_title_bold',
            extra: <String, dynamic>{'textColor': '#FF14532D'},
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'titleEn',
            fallbackMode: 'value',
            fallbackValue: 'Fresh Grocery Item',
          ),
          content: const <String, dynamic>{'text': 'Fresh Grocery Item'},
          props: _templateProps(templateId, 'title', label: 'Title'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_price',
          name: 'Price pill',
          type: MBDesignNodeTypeV4.price,
          transform: MBDesignTransformV4(
            x: 0.34,
            y: 0.79,
            width: 84,
            height: 36,
            zIndex: baseZ + 4,
          ),
          style: const MBDesignStyleV4(
            fill: '#FF14532D',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#3314532D', blur: 14, offsetY: 6),
            ],
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'effectivePrice',
            fallbackMode: 'value',
            fallbackValue: '৳120',
            formatter: 'bdt',
          ),
          content: const <String, dynamic>{'text': '৳120'},
          props: _templateProps(templateId, 'price', label: 'Price'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_cta',
          name: 'Add to cart button',
          type: MBDesignNodeTypeV4.button,
          transform: MBDesignTransformV4(
            x: 0.68,
            y: 0.79,
            width: 92,
            height: 36,
            zIndex: baseZ + 5,
          ),
          style: const MBDesignStyleV4(
            fill: '#FFFF6500',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#33FF6500', blur: 14, offsetY: 6),
            ],
          ),
          content: const <String, dynamic>{'text': 'Add'},
          props: _templateProps(templateId, 'cta', label: 'CTA'),
        ),
      ],
    );
  }

  void applyOfferPosterTemplate() {
    final templateId = _newNodeId('tpl_offer_poster');
    final baseZ = 10;
    final badgeId = '${templateId}_badge';

    _applyTemplate(
      templateName: 'Offer Poster Card',
      description: 'Apply Offer Poster template',
      primaryNodeId: badgeId,
      canvas: const MBDesignCanvasSpecV4(
        width: 200,
        height: 342,
        layoutType: 'v4_offer_poster_card',
        backgroundMode: 'gradient',
        backgroundColor: '#FFFF6500',
        backgroundGradientId: 'orangeGradient',
        borderRadius: 28,
      ),
      nodes: <MBDesignNodeV4>[
        MBDesignNodeV4(
          id: '${templateId}_top_flash',
          name: 'Poster flash shape',
          type: MBDesignNodeTypeV4.shape,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.21,
            width: 190,
            height: 116,
            rotation: -8,
            zIndex: baseZ,
          ),
          style: const MBDesignStyleV4(fill: '#33FFFFFF', radius: 32),
          content: const <String, dynamic>{'text': ''},
          props: _templateProps(templateId, 'flashShape', label: 'Flash shape'),
        ),
        MBDesignNodeV4(
          id: badgeId,
          name: 'Mega offer sticker',
          type: MBDesignNodeTypeV4.badge,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.16,
            width: 126,
            height: 42,
            rotation: -5,
            zIndex: baseZ + 1,
          ),
          style: const MBDesignStyleV4(
            fill: '#FFEF4444',
            radius: 18,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#55EF4444', blur: 18, offsetY: 8),
            ],
          ),
          content: const <String, dynamic>{'text': 'MEGA OFFER'},
          props: _templateProps(templateId, 'badge', label: 'Offer badge'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_hero',
          name: 'Poster product image',
          type: MBDesignNodeTypeV4.media,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.43,
            width: 156,
            height: 156,
            zIndex: baseZ + 2,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#44000000', blur: 24, offsetY: 12),
            ],
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'resolvedCardTransparentImageUrl',
            fallbackMode: 'placeholder',
          ),
          content: const <String, dynamic>{'text': 'Cutout'},
          props: _templateProps(
            templateId,
            'heroImage',
            label: 'Hero image',
            extra: const <String, dynamic>{
              'imageSource': 'cardTransparent',
              'fit': 'contain',
              'transparentCutout': true,
            },
          ),
        ),
        MBDesignNodeV4(
          id: '${templateId}_discount',
          name: 'Discount bubble',
          type: MBDesignNodeTypeV4.badge,
          transform: MBDesignTransformV4(
            x: 0.76,
            y: 0.53,
            width: 72,
            height: 72,
            rotation: 8,
            zIndex: baseZ + 3,
          ),
          style: const MBDesignStyleV4(
            fill: '#FFFFFFFF',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#33000000', blur: 16, offsetY: 8),
            ],
            extra: <String, dynamic>{'textColor': '#FFEF4444'},
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'discountPercent',
            fallbackMode: 'value',
            fallbackValue: '20% OFF',
          ),
          content: const <String, dynamic>{'text': '20% OFF'},
          props: _templateProps(templateId, 'discount', label: 'Discount'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_title',
          name: 'Poster title',
          type: MBDesignNodeTypeV4.text,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.70,
            width: 168,
            height: 42,
            zIndex: baseZ + 4,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            textStyleId: 'card_title_bold',
            extra: <String, dynamic>{'textColor': '#FFFFFFFF'},
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'titleEn',
            fallbackMode: 'value',
            fallbackValue: 'Best Deal Today',
          ),
          content: const <String, dynamic>{'text': 'Best Deal Today'},
          props: _templateProps(templateId, 'title', label: 'Title'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_price',
          name: 'Poster price',
          type: MBDesignNodeTypeV4.price,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.84,
            width: 112,
            height: 42,
            zIndex: baseZ + 5,
          ),
          style: const MBDesignStyleV4(
            fill: '#FF111827',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#33000000', blur: 18, offsetY: 8),
            ],
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'effectivePrice',
            fallbackMode: 'value',
            fallbackValue: '৳120',
            formatter: 'bdt',
          ),
          content: const <String, dynamic>{'text': '৳120'},
          props: _templateProps(templateId, 'price', label: 'Price'),
        ),
      ],
    );
  }

  void applyPremiumDarkTemplate() {
    final templateId = _newNodeId('tpl_premium_dark');
    final baseZ = 10;
    final titleId = '${templateId}_title';

    _applyTemplate(
      templateName: 'Premium Dark Card',
      description: 'Apply Premium Dark template',
      primaryNodeId: titleId,
      canvas: const MBDesignCanvasSpecV4(
        width: 200,
        height: 342,
        layoutType: 'v4_premium_dark_card',
        backgroundMode: 'color',
        backgroundColor: '#FF0F172A',
        backgroundGradientId: null,
        borderRadius: 30,
      ),
      nodes: <MBDesignNodeV4>[
        MBDesignNodeV4(
          id: '${templateId}_gold_ring',
          name: 'Gold ring glow',
          type: MBDesignNodeTypeV4.shape,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.35,
            width: 166,
            height: 166,
            zIndex: baseZ,
          ),
          style: const MBDesignStyleV4(
            fill: '#22F59E0B',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#33F59E0B', blur: 30),
            ],
          ),
          content: const <String, dynamic>{'text': ''},
          props: _templateProps(templateId, 'goldGlow', label: 'Gold glow'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_hero',
          name: 'Premium product image',
          type: MBDesignNodeTypeV4.media,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.36,
            width: 150,
            height: 150,
            zIndex: baseZ + 1,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#77000000', blur: 22, offsetY: 12),
            ],
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'resolvedCardTransparentImageUrl',
            fallbackMode: 'placeholder',
          ),
          content: const <String, dynamic>{'text': 'Cutout'},
          props: _templateProps(
            templateId,
            'heroImage',
            label: 'Hero image',
            extra: const <String, dynamic>{
              'imageSource': 'cardTransparent',
              'fit': 'contain',
              'transparentCutout': true,
            },
          ),
        ),
        MBDesignNodeV4(
          id: titleId,
          name: 'Premium title',
          type: MBDesignNodeTypeV4.text,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.63,
            width: 166,
            height: 44,
            zIndex: baseZ + 2,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            textStyleId: 'card_title_bold',
            extra: <String, dynamic>{'textColor': '#FFFFFFFF'},
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'titleEn',
            fallbackMode: 'value',
            fallbackValue: 'Premium Choice',
          ),
          content: const <String, dynamic>{'text': 'Premium Choice'},
          props: _templateProps(templateId, 'title', label: 'Title'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_subtitle',
          name: 'Premium subtitle',
          type: MBDesignNodeTypeV4.text,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.72,
            width: 150,
            height: 26,
            zIndex: baseZ + 3,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            textStyleId: 'card_subtitle_medium',
            extra: <String, dynamic>{'textColor': '#FFE2E8F0'},
          ),
          content: const <String, dynamic>{'text': 'Selected quality · trusted stock'},
          props: _templateProps(templateId, 'subtitle', label: 'Subtitle'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_price',
          name: 'Premium price',
          type: MBDesignNodeTypeV4.price,
          transform: MBDesignTransformV4(
            x: 0.36,
            y: 0.86,
            width: 86,
            height: 38,
            zIndex: baseZ + 4,
          ),
          style: const MBDesignStyleV4(
            fill: '#FFF59E0B',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#33F59E0B', blur: 14, offsetY: 6),
            ],
            extra: <String, dynamic>{'textColor': '#FF111827'},
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'effectivePrice',
            fallbackMode: 'value',
            fallbackValue: '৳120',
            formatter: 'bdt',
          ),
          content: const <String, dynamic>{'text': '৳120'},
          props: _templateProps(templateId, 'price', label: 'Price'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_badge',
          name: 'Premium badge',
          type: MBDesignNodeTypeV4.badge,
          transform: MBDesignTransformV4(
            x: 0.72,
            y: 0.86,
            width: 82,
            height: 34,
            zIndex: baseZ + 5,
          ),
          style: const MBDesignStyleV4(
            fill: '#22FFFFFF',
            radius: 999,
            border: MBBorderStyleV4(color: '#55FFFFFF', width: 1),
            extra: <String, dynamic>{'textColor': '#FFFFFFFF'},
          ),
          content: const <String, dynamic>{'text': 'Premium'},
          props: _templateProps(templateId, 'badge', label: 'Badge'),
        ),
      ],
    );
  }

  void applyProductHeroTemplate() {
    final templateId = _newNodeId('tpl_product_hero');
    final baseZ = 10;
    final heroId = '${templateId}_hero';

    _applyTemplate(
      templateName: 'Product Hero Card',
      description: 'Apply Product Hero template',
      primaryNodeId: heroId,
      canvas: const MBDesignCanvasSpecV4(
        width: 200,
        height: 342,
        layoutType: 'v4_product_hero_card',
        backgroundMode: 'gradient',
        backgroundColor: '#FFFF6500',
        backgroundGradientId: 'orangeGradient',
        borderRadius: 30,
      ),
      nodes: <MBDesignNodeV4>[
        MBDesignNodeV4(
          id: '${templateId}_light',
          name: 'Hero spotlight',
          type: MBDesignNodeTypeV4.shape,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.39,
            width: 190,
            height: 190,
            zIndex: baseZ,
          ),
          style: const MBDesignStyleV4(
            fill: '#30FFFFFF',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#33FFFFFF', blur: 34),
            ],
          ),
          content: const <String, dynamic>{'text': ''},
          props: _templateProps(templateId, 'spotlight', label: 'Spotlight'),
        ),
        MBDesignNodeV4(
          id: heroId,
          name: 'Large hero product',
          type: MBDesignNodeTypeV4.media,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.39,
            width: 172,
            height: 172,
            zIndex: baseZ + 1,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#55000000', blur: 24, offsetY: 14),
            ],
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'resolvedCardTransparentImageUrl',
            fallbackMode: 'placeholder',
          ),
          content: const <String, dynamic>{'text': 'Cutout'},
          props: _templateProps(
            templateId,
            'heroImage',
            label: 'Hero image',
            extra: const <String, dynamic>{
              'imageSource': 'cardTransparent',
              'fit': 'contain',
              'transparentCutout': true,
            },
          ),
        ),
        MBDesignNodeV4(
          id: '${templateId}_title_surface',
          name: 'Title glass surface',
          type: MBDesignNodeTypeV4.shape,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.73,
            width: 172,
            height: 82,
            zIndex: baseZ + 2,
          ),
          style: const MBDesignStyleV4(
            fill: '#36FFFFFF',
            radius: 26,
            border: MBBorderStyleV4(color: '#55FFFFFF', width: 1),
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#22000000', blur: 16, offsetY: 8),
            ],
          ),
          content: const <String, dynamic>{'text': ''},
          props: _templateProps(templateId, 'surface', label: 'Title surface'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_title',
          name: 'Hero title',
          type: MBDesignNodeTypeV4.text,
          transform: MBDesignTransformV4(
            x: 0.5,
            y: 0.68,
            width: 150,
            height: 40,
            zIndex: baseZ + 3,
          ),
          style: const MBDesignStyleV4(
            fill: '#00000000',
            textStyleId: 'card_title_bold',
            extra: <String, dynamic>{'textColor': '#FFFFFFFF'},
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'titleEn',
            fallbackMode: 'value',
            fallbackValue: 'Hero Product',
          ),
          content: const <String, dynamic>{'text': 'Hero Product'},
          props: _templateProps(templateId, 'title', label: 'Title'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_price',
          name: 'Hero price',
          type: MBDesignNodeTypeV4.price,
          transform: MBDesignTransformV4(
            x: 0.35,
            y: 0.86,
            width: 82,
            height: 36,
            zIndex: baseZ + 4,
          ),
          style: const MBDesignStyleV4(
            fill: '#FFFFFFFF',
            radius: 999,
            extra: <String, dynamic>{'textColor': '#FFFF6500'},
          ),
          binding: const MBDesignBindingV4(
            source: 'product',
            path: 'effectivePrice',
            fallbackMode: 'value',
            fallbackValue: '৳120',
            formatter: 'bdt',
          ),
          content: const <String, dynamic>{'text': '৳120'},
          props: _templateProps(templateId, 'price', label: 'Price'),
        ),
        MBDesignNodeV4(
          id: '${templateId}_button',
          name: 'Hero CTA',
          type: MBDesignNodeTypeV4.button,
          transform: MBDesignTransformV4(
            x: 0.70,
            y: 0.86,
            width: 86,
            height: 34,
            zIndex: baseZ + 5,
          ),
          style: const MBDesignStyleV4(
            fill: '#FF111827',
            radius: 999,
            shadows: <MBShadowStyleV4>[
              MBShadowStyleV4(color: '#33000000', blur: 14, offsetY: 6),
            ],
          ),
          content: const <String, dynamic>{'text': 'Buy'},
          props: _templateProps(templateId, 'cta', label: 'CTA'),
        ),
      ],
    );
  }

  void _applyTemplate({
    required String templateName,
    required String description,
    required MBDesignCanvasSpecV4 canvas,
    required List<MBDesignNodeV4> nodes,
    String? primaryNodeId,
  }) {
    final before = _document;
    final next = _document.copyWith(
      name: templateName,
      canvas: canvas,
      nodes: nodes..sort(MBDesignNodeV4.compareByLayer),
      metadata: <String, dynamic>{
        ..._document.metadata,
        'studioV4Template': templateName,
        'studioV4TemplateAppliedAt': DateTime.now().toIso8601String(),
      },
    );

    if (before.toJson() == next.toJson()) return;

    commitDocument(next, description: description);

    final selectedId = primaryNodeId ?? (nodes.isEmpty ? null : nodes.first.id);
    if (selectedId != null && next.nodeById(selectedId) != null) {
      selectNode(selectedId);
    } else {
      selectCard();
    }
  }

  Map<String, dynamic> _templateProps(
    String templateId,
    String role, {
    String? label,
    Map<String, dynamic> extra = const <String, dynamic>{},
  }) {
    return <String, dynamic>{
      'templateId': templateId,
      'templateRole': role,
      if (label != null) 'label': label,
      ...extra,
    };
  }


  String get exportPrettyJson => _document.toPrettyJson();
  String get exportCompactJson => _document.toJson();

  int get exportNodeCount => _document.nodes.length;
  int get exportSelectedCount => _editorState.selectedNodeIds.length;
  int get exportSchemaVersion => _document.schemaVersion;
  double get exportCanvasWidth => _document.canvas.width;
  double get exportCanvasHeight => _document.canvas.height;
  String get exportLayoutType => _document.canvas.layoutType;

  List<String> get exportValidationMessages {
    return _validateDocument(
      _document,
      successMessage: 'V4 document looks export-ready for lab/testing.',
    );
  }

  List<String> validateImportedJsonText(String rawJson) {
    final trimmed = rawJson.trim();
    if (trimmed.isEmpty) {
      return <String>['Error: Paste V4 JSON before loading.'];
    }

    final decoded = _decodeJsonForImport(trimmed);
    final error = decoded.error;
    if (error != null) return <String>[error];

    final map = decoded.map;
    if (map == null) {
      return <String>['Error: V4 JSON root must be an object.'];
    }

    final document = MBCardDesignDocumentV4.fromMap(map);
    return _validateDocument(
      document,
      successMessage: 'V4 JSON is valid and ready to load.',
      strictImport: true,
    );
  }

  List<String> loadDocumentFromJsonText(String rawJson) {
    final trimmed = rawJson.trim();
    final validationMessages = validateImportedJsonText(trimmed);
    final hasBlockingError = validationMessages.any(
      (message) => message.trim().toLowerCase().startsWith('error:'),
    );

    if (hasBlockingError) return validationMessages;

    final decoded = _decodeJsonForImport(trimmed);
    final map = decoded.map;
    if (map == null) {
      return <String>['Error: V4 JSON root must be an object.'];
    }

    final nextDocument = MBCardDesignDocumentV4.fromMap(map);
    if (nextDocument.toJson() == _document.toJson()) {
      return <String>['V4 JSON matches the current document. Nothing changed.'];
    }

    commitDocument(nextDocument, description: 'Load V4 JSON');
    _editorState = _editorState.clearSelection().copyWith(dirty: true);
    notifyListeners();

    return <String>[
      'V4 JSON loaded successfully.',
      for (final message in validationMessages)
        if (message.trim().toLowerCase().startsWith('warning:')) message,
    ];
  }

  List<String> _validateDocument(
    MBCardDesignDocumentV4 document, {
    required String successMessage,
    bool strictImport = false,
  }) {
    final messages = <String>[];
    final seenIds = <String>{};
    final zIndexUsage = <int, int>{};

    if (strictImport && document.schemaVersion != 4) {
      messages.add('Error: Expected schemaVersion 4, found ${document.schemaVersion}.');
    }

    if (strictImport && document.type.trim() != 'muthobazar_card_design_v4') {
      messages.add('Error: JSON type must be muthobazar_card_design_v4.');
    }

    if (document.id.trim().isEmpty) {
      messages.add('Error: Document id is missing.');
    }

    if (document.canvas.width <= 0 || document.canvas.height <= 0) {
      messages.add('Error: Canvas size must be greater than zero.');
    }

    if (document.nodes.isEmpty) {
      messages.add('Warning: Document has no layers.');
    }

    for (final node in document.nodes) {
      if (node.id.trim().isEmpty) {
        messages.add('Error: A node has a missing id.');
        continue;
      }

      if (!seenIds.add(node.id)) {
        messages.add('Error: Duplicate node id: ${node.id}.');
      }

      if (node.transform.width <= 0 || node.transform.height <= 0) {
        messages.add('Error: ${node.name}: width and height must be greater than zero.');
      }

      if (node.transform.opacity < 0 || node.transform.opacity > 1) {
        messages.add('Error: ${node.name}: opacity should be between 0 and 1.');
      }

      final parentId = node.parentId;
      if (parentId != null && document.nodeById(parentId) == null) {
        messages.add('Error: ${node.name}: missing parent layer $parentId.');
      }

      zIndexUsage[node.transform.zIndex] =
          (zIndexUsage[node.transform.zIndex] ?? 0) + 1;
    }

    for (final entry in zIndexUsage.entries) {
      if (entry.value > 1) {
        messages.add('Warning: ${entry.value} layers share zIndex ${entry.key}.');
      }
    }

    if (messages.isEmpty) {
      messages.add(successMessage);
    }

    return messages;
  }

  _MBStudioV4JsonDecodeResult _decodeJsonForImport(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) {
        return const _MBStudioV4JsonDecodeResult(
          error: 'Error: V4 JSON root must be an object.',
        );
      }

      return _MBStudioV4JsonDecodeResult(
        map: <String, dynamic>{
          for (final entry in decoded.entries) entry.key.toString(): entry.value,
        },
      );
    } catch (error) {
      return _MBStudioV4JsonDecodeResult(
        error: 'Error: Invalid JSON. $error',
      );
    }
  }

  Map<String, dynamic> get exportSummary => exportSummaryMap;

  Map<String, dynamic> get exportSummaryMap {
    return <String, dynamic>{
      'schemaVersion': exportSchemaVersion,
      'documentId': _document.id,
      'documentName': _document.name,
      'canvasWidth': exportCanvasWidth,
      'canvasHeight': exportCanvasHeight,
      'layoutType': exportLayoutType,
      'nodeCount': exportNodeCount,
      'selectedCount': exportSelectedCount,
      'dirty': _editorState.dirty,
      'validationCount': exportValidationMessages.length,
    };
  }

  void resetDocumentToBlank() {
    final before = _document;
    final next = MBCardDesignDocumentV4.blank();

    if (before.toJson() == next.toJson()) return;

    _document = next;
    _editorState = _editorState.clearSelection().copyWith(dirty: true);
    history.record(
      MBStudioV4DocumentCommand(
        description: 'Reset document',
        before: before,
        after: next,
      ),
    );
    notifyListeners();
  }

  void markSaved() {
    _editorState = _editorState.copyWith(dirty: false);
    notifyListeners();
  }

  void undo() {
    final previous = history.undo(_document);
    if (previous == null) return;
    _document = previous;
    _editorState = _editorState.clearSelection().copyWith(dirty: true);
    notifyListeners();
  }

  void redo() {
    final next = history.redo(_document);
    if (next == null) return;
    _document = next;
    _editorState = _editorState.clearSelection().copyWith(dirty: true);
    notifyListeners();
  }


  static double _safeDimension(double value) {
    if (value <= 0) return 1;
    return value;
  }

  static double _clamp01(double value) {
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }



  static double _clampDimension(double value) {
    if (value < 1) return 1;
    if (value > 3000) return 3000;
    return value;
  }

  static String? _normalizeColorHex(String value) {
    var raw = value.trim();
    if (raw.isEmpty) return null;
    if (raw.toLowerCase() == 'transparent') return '#00000000';
    if (raw.startsWith('#')) raw = raw.substring(1);
    if (raw.length == 3) {
      raw = raw.split('').map((char) => '$char$char').join();
    }
    if (raw.length == 6) raw = 'FF$raw';
    if (raw.length != 8) return null;
    final parsed = int.tryParse(raw, radix: 16);
    if (parsed == null) return null;
    return '#${raw.toUpperCase()}';
  }


  @override
  void dispose() {
    history.dispose();
    super.dispose();
  }
}

class _MBStudioV4JsonDecodeResult {
  const _MBStudioV4JsonDecodeResult({
    this.map,
    this.error,
  });

  final Map<String, dynamic>? map;
  final String? error;
}
