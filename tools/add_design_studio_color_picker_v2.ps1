# MuthoBazar - Add Design Studio Color Picker V2
# ----------------------------------------------
# Safe version.
#
# The first color-picker patch used regex replacement and corrupted the Dart file.
# This V2 uses marker-based substring replacement only.
#
# It patches:
# packages/shared_ui/lib/widgets/common/product_cards/design_studio/mb_card_design_studio.dart
#
# Result:
# - Style color fields become read-only picker fields.
# - Palette HEX fields become read-only picker fields.
# - Tap field / swatch / palette icon to open color picker.
# - Picker has HEX input, RGB sliders, and quick swatches.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\add_design_studio_color_picker_v2.ps1
# flutter analyze

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$TargetRel = "packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart"
$Target = Join-Path $RepoRoot $TargetRel
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\add_design_studio_color_picker_v2_$Timestamp"
$Backup = Join-Path $BackupRoot $TargetRel

Write-Host ""
Write-Host "MuthoBazar - Add Design Studio Color Picker V2" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

if (!(Test-Path -LiteralPath $Target)) {
  throw "Target file not found: $Target"
}

New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
Copy-Item -LiteralPath $Target -Destination $Backup -Force

$Text = [System.IO.File]::ReadAllText($Target)
$Original = $Text

function Replace-BetweenMarkers {
  param(
    [string]$SourceText,
    [string]$StartMarker,
    [string]$EndMarker,
    [string]$Replacement,
    [string]$Label
  )

  $Start = $SourceText.IndexOf($StartMarker)
  if ($Start -lt 0) {
    throw "Start marker not found for $Label : $StartMarker"
  }

  $End = $SourceText.IndexOf($EndMarker, $Start)
  if ($End -lt 0) {
    throw "End marker not found for $Label : $EndMarker"
  }

  return $SourceText.Substring(0, $Start) + $Replacement + $SourceText.Substring($End)
}

$StyleHexFieldReplacement = @'
  Widget _styleHexField({
    required String keyName,
    required String label,
    required String fallbackHex,
  }) {
    final rawCurrent = _activeStyleMap[keyName]?.toString() ?? fallbackHex;
    final current = MBDesignRuntimePalette.normalizeHex(rawCurrent);
    final isValid = MBDesignRuntimePalette.isValidHex(current);
    final swatchColor = MBDesignRuntimePalette.colorFromHex(
      current,
      fallback: Colors.transparent,
    );

    void openPicker() {
      _openHexColorPicker(
        title: '$label · $_activeElementId',
        initialHex: current,
        fallbackHex: fallbackHex,
        onSelected: (hex) => _setActiveStyleValue(keyName, hex),
      );
    }

    return SizedBox(
      width: 190,
      child: TextFormField(
        key: ValueKey(
          'style_picker_${_activeElementId}_${keyName}_$current',
        ),
        initialValue: current,
        readOnly: true,
        onTap: openPicker,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          prefixIcon: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: openPicker,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: swatchColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: swatchColor.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 22,
                  height: 22,
                ),
              ),
            ),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Pick color',
                icon: const Icon(Icons.palette_outlined, size: 18),
                onPressed: openPicker,
              ),
              IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close_rounded, size: 17),
                onPressed: () => _setActiveStyleValue(keyName, null),
              ),
            ],
          ),
          errorText: isValid ? null : 'Use #RRGGBB',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _openHexColorPicker({
    required String title,
    required String initialHex,
    required String fallbackHex,
    required ValueChanged<String> onSelected,
  }) async {
    final startHex = MBDesignRuntimePalette.isValidHex(initialHex)
        ? MBDesignRuntimePalette.normalizeHex(initialHex)
        : MBDesignRuntimePalette.normalizeHex(fallbackHex);

    final picked = await showDialog<String>(
      context: context,
      builder: (context) {
        return _MBHexColorPickerDialog(
          title: title,
          initialHex: startHex,
        );
      },
    );

    if (picked == null) {
      return;
    }

    final normalized = MBDesignRuntimePalette.normalizeHex(picked);

    if (!MBDesignRuntimePalette.isValidHex(normalized)) {
      return;
    }

    onSelected(normalized);
  }

'@

$Text = Replace-BetweenMarkers `
  -SourceText $Text `
  -StartMarker "  Widget _styleHexField({" `
  -EndMarker "  Widget _styleNullableSlider({" `
  -Replacement $StyleHexFieldReplacement `
  -Label "_styleHexField"

Write-Host "Patched _styleHexField safely." -ForegroundColor Green

$PaletteHexFieldReplacement = @'
  Widget _paletteHexField(String key) {
    final rawValue = _paletteValues[key] ??
        MBDesignRuntimePalette.presetHexMap(_activePaletteId)[key] ??
        '#FFFFFF';

    final value = MBDesignRuntimePalette.normalizeHex(rawValue);
    final isValid = MBDesignRuntimePalette.isValidHex(value);
    final swatchColor = MBDesignRuntimePalette.colorFromHex(
      value,
      fallback: Colors.transparent,
    );

    void openPicker() {
      _openHexColorPicker(
        title: MBDesignRuntimePalette.fieldLabel(key),
        initialHex: value,
        fallbackHex: '#FFFFFF',
        onSelected: (hex) => _applyPaletteHex(key, hex),
      );
    }

    return TextFormField(
      key: ValueKey('palette_picker_${_activePaletteId}_${key}_$value'),
      initialValue: value,
      readOnly: true,
      onTap: openPicker,
      decoration: InputDecoration(
        labelText: MBDesignRuntimePalette.fieldLabel(key),
        isDense: true,
        prefixIcon: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: openPicker,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: swatchColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: swatchColor.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const SizedBox(
                width: 22,
                height: 22,
              ),
            ),
          ),
        ),
        suffixIcon: IconButton(
          tooltip: 'Pick color',
          icon: const Icon(Icons.palette_outlined, size: 18),
          onPressed: openPicker,
        ),
        errorText: isValid ? null : 'Use #RRGGBB',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _applyPaletteHex(String key, String rawHex) {
    final normalized = MBDesignRuntimePalette.normalizeHex(rawHex);

    if (!MBDesignRuntimePalette.isValidHex(normalized)) {
      return;
    }

    setState(() {
      _activePresetId = 'custom';
      _paletteValues = <String, String>{
        ..._paletteValues,
        key: normalized,
      };
    });
  }

'@

$Text = Replace-BetweenMarkers `
  -SourceText $Text `
  -StartMarker "  Widget _paletteHexField(String key) {" `
  -EndMarker "  void _applyPalettePreset" `
  -Replacement $PaletteHexFieldReplacement `
  -Label "_paletteHexField"

Write-Host "Patched _paletteHexField safely." -ForegroundColor Green

$DialogClass = @'

class _MBHexColorPickerDialog extends StatefulWidget {
  const _MBHexColorPickerDialog({
    required this.title,
    required this.initialHex,
  });

  final String title;
  final String initialHex;

  @override
  State<_MBHexColorPickerDialog> createState() =>
      _MBHexColorPickerDialogState();
}

class _MBHexColorPickerDialogState extends State<_MBHexColorPickerDialog> {
  late int _red;
  late int _green;
  late int _blue;
  late final TextEditingController _hexController;

  static const List<String> _quickColors = <String>[
    '#FFFFFF',
    '#F8FAFC',
    '#F1F5F9',
    '#E5E7EB',
    '#111827',
    '#000000',
    '#FF7A00',
    '#FF6500',
    '#FFA53A',
    '#FFE1CF',
    '#42C66B',
    '#129A44',
    '#22A652',
    '#EFFFF0',
    '#2196F3',
    '#1565C0',
    '#E7F0FF',
    '#7C3AED',
    '#EC4899',
    '#F43F5E',
    '#FFB300',
    '#075E2D',
    '#0D4C7A',
    '#6C6C6C',
  ];

  @override
  void initState() {
    super.initState();

    final initialColor = MBDesignRuntimePalette.colorFromHex(
      widget.initialHex,
      fallback: const Color(0xFFFF7A00),
    );

    _red = (initialColor.r * 255).round().clamp(0, 255).toInt();
    _green = (initialColor.g * 255).round().clamp(0, 255).toInt();
    _blue = (initialColor.b * 255).round().clamp(0, 255).toInt();
    _hexController = TextEditingController(text: _currentHex);
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor {
    return Color.fromARGB(255, _red, _green, _blue);
  }

  String get _currentHex {
    String part(int value) {
      return value.clamp(0, 255).toRadixString(16).padLeft(2, '0');
    }

    return '#${part(_red)}${part(_green)}${part(_blue)}'.toUpperCase();
  }

  void _setColorFromHex(String rawHex) {
    final normalized = MBDesignRuntimePalette.normalizeHex(rawHex);

    if (!MBDesignRuntimePalette.isValidHex(normalized)) {
      return;
    }

    final color = MBDesignRuntimePalette.colorFromHex(
      normalized,
      fallback: _currentColor,
    );

    setState(() {
      _red = (color.r * 255).round().clamp(0, 255).toInt();
      _green = (color.g * 255).round().clamp(0, 255).toInt();
      _blue = (color.b * 255).round().clamp(0, 255).toInt();
      _hexController.text = normalized;
      _hexController.selection = TextSelection.collapsed(
        offset: _hexController.text.length,
      );
    });
  }

  void _setChannel({
    required String channel,
    required double value,
  }) {
    setState(() {
      final channelValue = value.round().clamp(0, 255).toInt();

      switch (channel) {
        case 'r':
          _red = channelValue;
          break;
        case 'g':
          _green = channelValue;
          break;
        case 'b':
          _blue = channelValue;
          break;
      }

      _hexController.text = _currentHex;
      _hexController.selection = TextSelection.collapsed(
        offset: _hexController.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _currentColor;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 82,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        child: Text(
                          _currentHex,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _hexController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'HEX color',
                  hintText: '#FF7A00',
                  prefixIcon: const Icon(Icons.tag_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: _setColorFromHex,
              ),
              const SizedBox(height: 12),
              _buildChannelSlider(
                label: 'Red',
                value: _red,
                onChanged: (value) => _setChannel(
                  channel: 'r',
                  value: value,
                ),
              ),
              _buildChannelSlider(
                label: 'Green',
                value: _green,
                onChanged: (value) => _setChannel(
                  channel: 'g',
                  value: value,
                ),
              ),
              _buildChannelSlider(
                label: 'Blue',
                value: _blue,
                onChanged: (value) => _setChannel(
                  channel: 'b',
                  value: value,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick colors',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final hex in _quickColors)
                    _ColorPickerSwatch(
                      hex: hex,
                      selected: MBDesignRuntimePalette.normalizeHex(hex) ==
                          _currentHex,
                      onTap: () => _setColorFromHex(hex),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(_currentHex),
          icon: const Icon(Icons.check_rounded),
          label: const Text('Apply color'),
        ),
      ],
    );
  }

  Widget _buildChannelSlider({
    required String label,
    required int value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            divisions: 255,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorPickerSwatch extends StatelessWidget {
  const _ColorPickerSwatch({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = MBDesignRuntimePalette.colorFromHex(
      hex,
      fallback: Colors.transparent,
    );

    return Tooltip(
      message: hex,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black.withValues(alpha: 0.10),
              width: selected ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: selected ? 0.34 : 0.16),
                blurRadius: selected ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: selected
              ? const Icon(
                  Icons.check_rounded,
                  size: 17,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
'@

if (!$Text.Contains("class _MBHexColorPickerDialog")) {
  $Text = $Text.TrimEnd() + [Environment]::NewLine + $DialogClass + [Environment]::NewLine
  Write-Host "Added _MBHexColorPickerDialog." -ForegroundColor Green
} else {
  Write-Host "_MBHexColorPickerDialog already exists." -ForegroundColor Yellow
}

[System.IO.File]::WriteAllText($Target, $Text, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "Patch completed successfully." -ForegroundColor Green
Write-Host "Backup:" -ForegroundColor Yellow
Write-Host "  $Backup"
Write-Host ""
Write-Host "Verify:" -ForegroundColor Cyan
Write-Host 'Select-String -Path .\packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart -Pattern "_MBHexColorPickerDialog|_openHexColorPicker|_applyPaletteHex"'
Write-Host ""
Write-Host "Then run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "flutter run -d web-server --web-hostname localhost --web-port 8080"
