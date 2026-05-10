// MuthoBazar Studio V4 History Controller
//
// Purpose:
// - Tracks undo/redo stacks for Studio V4 commands.
// - Foundation-only; UI integration comes in later patches.

import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

import '../commands/mb_studio_v4_command.dart';

class MBStudioV4HistoryController extends ChangeNotifier {
  MBStudioV4HistoryController({this.maxDepth = 80});

  final int maxDepth;
  final List<MBStudioV4Command> _undoStack = <MBStudioV4Command>[];
  final List<MBStudioV4Command> _redoStack = <MBStudioV4Command>[];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int get undoCount => _undoStack.length;
  int get redoCount => _redoStack.length;

  String get lastUndoDescription =>
      _undoStack.isEmpty ? 'Nothing to undo' : _undoStack.last.description;

  String get lastRedoDescription =>
      _redoStack.isEmpty ? 'Nothing to redo' : _redoStack.last.description;

  List<String> get undoDescriptions => <String>[
        for (final command in _undoStack) command.description,
      ];

  List<String> get redoDescriptions => <String>[
        for (final command in _redoStack) command.description,
      ];

  void record(MBStudioV4Command command) {
    _undoStack.add(command);
    if (_undoStack.length > maxDepth) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    notifyListeners();
  }

  MBCardDesignDocumentV4? undo(MBCardDesignDocumentV4 current) {
    if (_undoStack.isEmpty) return null;
    final command = _undoStack.removeLast();
    _redoStack.add(command);
    notifyListeners();
    return command.undo(current);
  }

  MBCardDesignDocumentV4? redo(MBCardDesignDocumentV4 current) {
    if (_redoStack.isEmpty) return null;
    final command = _redoStack.removeLast();
    _undoStack.add(command);
    notifyListeners();
    return command.apply(current);
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }
}
