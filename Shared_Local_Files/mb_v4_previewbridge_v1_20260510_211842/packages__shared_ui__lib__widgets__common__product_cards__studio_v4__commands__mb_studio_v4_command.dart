// MuthoBazar Studio V4 Command Base
//
// Purpose:
// - Provides a command pattern for future undo/redo support.
// - Commands are intentionally document-focused and UI-independent.

import 'package:shared_models/shared_models.dart';

abstract class MBStudioV4Command {
  const MBStudioV4Command({required this.description});

  final String description;

  MBCardDesignDocumentV4 apply(MBCardDesignDocumentV4 document);

  MBCardDesignDocumentV4 undo(MBCardDesignDocumentV4 document);
}

class MBStudioV4DocumentCommand extends MBStudioV4Command {
  const MBStudioV4DocumentCommand({
    required super.description,
    required this.before,
    required this.after,
  });

  final MBCardDesignDocumentV4 before;
  final MBCardDesignDocumentV4 after;

  @override
  MBCardDesignDocumentV4 apply(MBCardDesignDocumentV4 document) => after;

  @override
  MBCardDesignDocumentV4 undo(MBCardDesignDocumentV4 document) => before;
}
