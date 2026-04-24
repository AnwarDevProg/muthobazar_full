# Find old card layout references.
# This scanner intentionally reports all old aliases, including safe migration bridges.
# Run from repo root:
#   powershell -ExecutionPolicy Bypass -File .\tools\find_old_card_layout_refs.ps1

$patterns = @(
  'cardLayoutType',
  'cardVariantId',
  'cardStyle',
  'cardType',
  'standard',
  'deal',
  'card01',
  'card02',
  'card03',
  'normalizeCardLayoutType'
)

Get-ChildItem -Recurse -Include *.dart,*.ts |
  Where-Object { $_.FullName -notmatch '\\build\\|\\.dart_tool\\|\\node_modules\\|\\.git\\' } |
  Select-String -Pattern $patterns |
  Sort-Object Path, LineNumber |
  ForEach-Object {
    "{0}:{1}: {2}" -f $_.Path, $_.LineNumber, $_.Line.Trim()
  }
