# MuthoBazar - Add Color Picker To Design Studio
# ----------------------------------------------
# Converts palette/style HEX text fields into picker-enabled controls.
#
# It patches:
# packages/shared_ui/lib/widgets/common/product_cards/design_studio/mb_card_design_studio.dart
#
# Result:
# - Tap color field / color swatch / palette icon
# - Pick from swatches or RGB sliders
# - HEX updates automatically
# - Preview updates immediately
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\add_design_studio_color_picker.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$TargetRel = "packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart"
$Target = Join-Path $RepoRoot $TargetRel
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\add_design_studio_color_picker_$Timestamp"
$Backup = Join-Path $BackupRoot $TargetRel

Write-Host ""
Write-Host "MuthoBazar - Add Color Picker To Design Studio" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

if (!(Test-Path -LiteralPath $Target)) {
  throw "Target file not found: $Target"
}

New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
Copy-Item -LiteralPath $Target -Destination $Backup -Force

$Text = [System.IO.File]::ReadAllText($Target)
$Original = $Text

$StyleReplacement = @'
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

    return SizedBox(
      width: 190,
      child: TextFormField(
        key: ValueKey('style_hex_${_activeElementId}_${keyName}_$current'),
        initialValue: current,
        readOnly: true,
        onTap: () {
          _openHexColorPicker(
            title: '$label · $_activeElementId',
            initialHex: current,
            fallbackHex: fallbackHex,
            onSelected: (hex) => _applyActiveStyleHex(keyName, hex),
          );
        },
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          prefixIcon: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              _openHexColorPicker(
                title: '$label · $_activeElementId',
                initialHex: current,
                fallbackHex: fallbackHex,
                onSelected: (hex) => _applyActiveStyleHex(keyName, hex),
              );
            },
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: swatchColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
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
          suffixIcon: IconButton(
            tooltip: 'Pick color',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () {
              _openHexColorPicker(
                title: '$label · $_activeElementId',
                initialHex: current,
                fallbackHex: fallbackHex,
                onSelected: (hex) => _applyActiveStyleHex(keyName, hex),
              );
            },
          ),
          errorText: isValid ? null : 'Invalid',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  void _applyActiveStyleHex(String keyName, String rawHex) {
    final normalized = MBDesignRuntimePalette.normalizeHex(rawHex);

    if (!MBDesignRuntimePalette.isValidHex(normalized)) {
      return;
    }

    setState(() {
      _activePresetId = 'custom';

      final currentStyle = Map<String, Object?>.from(
        _elementStyleOverrides[_activeElementId] ?? const <String, Object?>{},
      );

      currentStyle[keyName] = normalized;

      _elementStyleOverrides[_activeElementId] = currentStyle;
    });
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

  String _colorPickerLabelForPaletteKey(String key) {
    final spaced = key
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .replaceAll('Hex', '')
        .trim();

    if (spaced.isEmpty) {
      return key;
    }

    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  String _styleFallbackTextHex
'@

$StylePattern = [regex]"(?ms)^  Widget _styleHexField\(\{.*?^  String _styleFallbackTextHex"
if ($StylePattern.IsMatch($Text)) {
  $Text = $StylePattern.Replace($Text, $StyleReplacement, 1)
  Write-Host "Patched _styleHexField as color picker." -ForegroundColor Green
} else {
  if ($Text.Contains("_applyActiveStyleHex(")) {
    Write-Host "_styleHexField already appears patched." -ForegroundColor Yellow
  } else {
    throw "Could not locate _styleHexField block."
  }
}

$PaletteReplacement = @'
  Widget _paletteHexField(String key) {
    final value = _paletteValues[key] ??
        MBDesignRuntimePalette.presetHexMap(_activePaletteId)[key] ??
        '#FFFFFF';

    final normalized = MBDesignRuntimePalette.normalizeHex(value);
    final isValid = MBDesignRuntimePalette.isValidHex(normalized);
    final swatchColor = MBDesignRuntimePalette.colorFromHex(
      normalized,
      fallback: Colors.transparent,
    );

    return TextFormField(
      key: ValueKey('palette_${_activePaletteId}_${key}_$normalized'),
      initialValue: normalized,
      readOnly: true,
      onTap: () {
        _openHexColorPicker(
          title: _colorPickerLabelForPaletteKey(key),
          initialHex: normalized,
          fallbackHex: '#FFFFFF',
          onSelected: (hex) => _applyPaletteHex(key, hex),
        );
      },
      decoration: InputDecoration(
        labelText: _colorPickerLabelForPaletteKey(key),
        isDense: true,
        prefixIcon: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            _openHexColorPicker(
              title: _colorPickerLabelForPaletteKey(key),
              initialHex: normalized,
              fallbackHex: '#FFFFFF',
              onSelected: (hex) => _applyPaletteHex(key, hex),
            );
          },
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: swatchColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.08),
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
          icon: const Icon(Icons.palette_outlined),
          onPressed: () {
            _openHexColorPicker(
              title: _colorPickerLabelForPaletteKey(key),
              initialHex: normalized,
              fallbackHex: '#FFFFFF',
              onSelected: (hex) => _applyPaletteHex(key, hex),
            );
          },
        ),
        errorText: isValid ? null : 'Invalid',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
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

  void _applyPalettePreset
'@

$PalettePattern = [regex]"(?ms)^  Widget _paletteHexField\(String key\) \{.*?^  void _applyPalettePreset"
if ($PalettePattern.IsMatch($Text)) {
  $Text = $PalettePattern.Replace($Text, $PaletteReplacement, 1)
  Write-Host "Patched _paletteHexField as color picker." -ForegroundColor Green
} else {
  if ($Text.Contains("_applyPaletteHex(")) {
    Write-Host "_paletteHexField already appears patched." -ForegroundColor Yellow
  } else {
    throw "Could not locate _paletteHexField block."
  }
}

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

    _red = initialColor.r.toInt();
    _green = initialColor.g.toInt();
    _blue = initialColor.b.toInt();
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
      _red = color.r.toInt();
      _green = color.g.toInt();
      _blue = color.b.toInt();
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
      final channelValue = value.round().clamp(0, 255);

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
  Write-Host "Added built-in HEX color picker dialog." -ForegroundColor Green
} else {
  Write-Host "Color picker dialog already exists." -ForegroundColor Yellow
}

if ($Text -eq $Original) {
  Write-Host "No changes were required." -ForegroundColor Yellow
} else {
  [System.IO.File]::WriteAllText($Target, $Text, [System.Text.UTF8Encoding]::new($false))
  Write-Host "File patched successfully." -ForegroundColor Green
}

Write-Host ""
Write-Host "Backup:" -ForegroundColor Yellow
Write-Host "  $Backup"
Write-Host ""
Write-Host "Verify:" -ForegroundColor Cyan
Write-Host 'Select-String -Path .\packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart -Pattern "_MBHexColorPickerDialog|_openHexColorPicker|_applyPaletteHex|_applyActiveStyleHex"'
Write-Host ""
Write-Host "Then run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "flutter run -d web-server --web-hostname localhost --web-port 8080"
