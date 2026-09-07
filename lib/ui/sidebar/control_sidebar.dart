import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';
import '../../models/cell_shape.dart';
import '../../theme/app_theme.dart';

class ControlSidebar extends StatefulWidget {
  final SimulationController controller;
  final VoidCallback onOpenRuleEditor;

  const ControlSidebar({
    super.key,
    required this.controller,
    required this.onOpenRuleEditor,
  });

  @override
  State<ControlSidebar> createState() => _ControlSidebarState();
}

class _ControlSidebarState extends State<ControlSidebar> {
  late TextEditingController _heightController;
  late TextEditingController _widthController;
  late TextEditingController _maxGenController;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(
      text: widget.controller.height.toString(),
    );
    _widthController = TextEditingController(
      text: widget.controller.width.toString(),
    );
    _maxGenController = TextEditingController(
      text: widget.controller.maxGenerations == 0
          ? '∞'
          : widget.controller.maxGenerations.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant ControlSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.height.toString() != _heightController.text) {
      _heightController.text = widget.controller.height.toString();
    }
    if (widget.controller.width.toString() != _widthController.text) {
      _widthController.text = widget.controller.width.toString();
    }
    final expectedMaxGen = widget.controller.maxGenerations == 0
        ? '∞'
        : widget.controller.maxGenerations.toString();
    if (expectedMaxGen != _maxGenController.text &&
        widget.controller.maxGenerations != oldWidget.controller.maxGenerations) {
      _maxGenController.text = expectedMaxGen;
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _widthController.dispose();
    _maxGenController.dispose();
    super.dispose();
  }

  void _applyGridSize() {
    final w = int.tryParse(_widthController.text);
    final h = int.tryParse(_heightController.text);
    if (h != null && w != null) {
      widget.controller.resizeGrid(w, h);
    }
  }

  void _applyMaxGenerations() {
    final text = _maxGenController.text.trim();
    if (text.isEmpty || text == '∞' || text.toLowerCase() == 'unlimited') {
      widget.controller.setMaxGenerations(0);
      _maxGenController.text = '∞';
    } else {
      final val = int.tryParse(text);
      if (val != null && val >= 0) {
        widget.controller.setMaxGenerations(val);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final totalCells = widget.controller.width * widget.controller.height;

        return Container(
          width: 320,
          color: AppTheme.surface900,
          child: Column(
            children: [
              // Scrollable sidebar panels
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    // --- PANEL 1: RULES SECTION ---
                    _buildSectionHeader(
                      icon: Icons.alt_route_rounded,
                      title: 'Rules Engine',
                    ),
                    const SizedBox(height: 10),
                    _buildRulesPanel(),

                    const SizedBox(height: 18),

                    // --- PANEL 2: CELL GRID SECTION ---
                    _buildSectionHeader(
                      icon: Icons.grid_4x4_rounded,
                      title: 'Cell Grid Geometry',
                      badge: '$totalCells cells',
                    ),
                    const SizedBox(height: 10),
                    _buildCellGridPanel(),

                    const SizedBox(height: 18),

                    // --- PANEL 3: SIMULATION SECTION ---
                    _buildSectionHeader(
                      icon: Icons.tune_rounded,
                      title: 'Simulation & Rendering',
                    ),
                    const SizedBox(height: 10),
                    _buildSimulationPanel(),
                  ],
                ),
              ),

              // --- BOTTOM PLAYBACK STRIP ---
              _buildPlaybackStrip(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? badge,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppTheme.cyanAccent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (badge != null && badge.isNotEmpty) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.surface800,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: AppTheme.cyanAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNumericEntryField({
    required TextEditingController controller,
    required VoidCallback onSubmitted,
    String? hintText,
  }) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surface900,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          height: 1.0,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        decoration: InputDecoration(
          isDense: true,
          isCollapsed: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 1),
          hintText: hintText,
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        onSubmitted: (_) => onSubmitted(),
      ),
    );
  }

  Widget _buildRulesPanel() {
    final activePreset = widget.controller.activePreset;
    final isCustom = widget.controller.isCustomRule;
    final availablePresets = widget.controller.availablePresets;
    final hasActivePreset = availablePresets.any((p) => p.id == activePreset.id);
    final selectedValue = isCustom
        ? 'custom'
        : (hasActivePreset
            ? activePreset.id
            : (availablePresets.isNotEmpty ? availablePresets.first.id : null));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preset Selector Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.surface900,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                dropdownColor: AppTheme.surface800,
                value: selectedValue,
                selectedItemBuilder: (context) {
                  return [
                    ...availablePresets.map((p) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                    if (isCustom)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.controller.customRuleName,
                          style: const TextStyle(
                            color: AppTheme.cyanAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ];
                },
                items: [
                  ...availablePresets.map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )),
                  if (isCustom)
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text(
                        widget.controller.customRuleName,
                        style: const TextStyle(
                          color: AppTheme.cyanAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
                onChanged: (val) {
                  if (val != null && val != 'custom') {
                    final found = availablePresets.firstWhere((p) => p.id == val);
                    widget.controller.selectPreset(found);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Primary Rule Editor Button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: AppTheme.surface900,
              foregroundColor: AppTheme.aliveColor,
              side: const BorderSide(color: AppTheme.aliveColor, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: widget.onOpenRuleEditor,
            child: const Text(
              'Rule Editor',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCellGridPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Grid Dimensions (Width × Height in cells)',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Inputs W x H
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'W',
                style: TextStyle(
                  color: AppTheme.cyanAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildNumericEntryField(
                  controller: _widthController,
                  onSubmitted: _applyGridSize,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'H',
                style: TextStyle(
                  color: AppTheme.cyanAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildNumericEntryField(
                  controller: _heightController,
                  onSubmitted: _applyGridSize,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                height: 32,
                child: Material(
                  color: AppTheme.surface700,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: _applyGridSize,
                    child: const Tooltip(
                      message: 'Apply Grid Dimensions',
                      child: Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppTheme.cyanAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quick presets chips: equal width, evenly spaced across two rows
          LayoutBuilder(
            builder: (context, constraints) {
              final chipWidth = (constraints.maxWidth - 12) / 3;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildSizeChip('64×48', 64, 48)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildSizeChip('128×96', 128, 96)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildSizeChip('256×192', 256, 192)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: chipWidth,
                        child: _buildSizeChip('512×384', 512, 384),
                      ),
                      SizedBox(
                        width: chipWidth,
                        child: _buildSizeChip('1200×800', 1200, 800),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Buttons: Reset Grid & Randomise
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surface700,
                    foregroundColor: AppTheme.textSecondary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('Reset Grid', style: TextStyle(fontSize: 11)),
                  onPressed: widget.controller.resetGrid,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surface700,
                    foregroundColor: AppTheme.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.casino_rounded, size: 14),
                  label: const Text('Randomise', style: TextStyle(fontSize: 11)),
                  onPressed: () => widget.controller.randomizeGrid(0.18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeChip(String label, int w, int h) {
    final isCurrent = widget.controller.width == w && widget.controller.height == h;
    return InkWell(
      onTap: () {
        _widthController.text = w.toString();
        _heightController.text = h.toString();
        widget.controller.resizeGrid(w, h);
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isCurrent ? AppTheme.aliveColor.withOpacity(0.15) : AppTheme.surface900,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCurrent ? AppTheme.aliveColor : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isCurrent ? AppTheme.aliveColor : AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildSimulationPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step Interval Speed Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Step Interval',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.controller.stepIntervalMs} ms',
                style: const TextStyle(
                  color: AppTheme.cyanAccent,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.cyanAccent,
              inactiveTrackColor: AppTheme.surface700,
              thumbColor: AppTheme.cyanAccent,
              overlayColor: AppTheme.cyanAccent.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 3,
            ),
            child: Slider(
              value: widget.controller.stepIntervalMs.toDouble(),
              min: 10,
              max: 300,
              divisions: 29,
              onChanged: (val) => widget.controller.setSpeed(val.round()),
            ),
          ),
          const SizedBox(height: 10),

          // Total / Max Generations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Total Generations',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.controller.maxGenerations == 0
                    ? 'Unlimited'
                    : '${widget.controller.maxGenerations} max',
                style: const TextStyle(
                  color: AppTheme.cyanAccent,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 122,
                child: _buildNumericEntryField(
                  controller: _maxGenController,
                  onSubmitted: _applyMaxGenerations,
                  hintText: '1000',
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                height: 32,
                child: Material(
                  color: AppTheme.surface700,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: _applyMaxGenerations,
                    child: const Tooltip(
                      message: 'Set Total Generations',
                      child: Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppTheme.cyanAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildGenChip('500', 500),
              _buildGenChip('1,000', 1000),
              _buildGenChip('5,000', 5000),
              _buildGenChip('Unlimited (∞)', 0),
            ],
          ),
          const SizedBox(height: 12),

          // Cell Geometry (Strict 1:1 Squares vs Circles)
          const Text(
            'Cell Geometry (Strict 1:1 Proportions)',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildShapeButton(
                  shape: CellShape.square,
                  icon: Icons.square_rounded,
                  label: 'Square',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShapeButton(
                  shape: CellShape.circle,
                  icon: Icons.circle,
                  label: 'Circle',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cell Alive Color Selection
          const Text(
            'Cell Alive Color',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...[
                        const Color(0xFF10B981), // Emerald
                        const Color(0xFF8B5CF6), // Violet
                        const Color(0xFF6B21A8), // Deep Purple
                        const Color(0xFFF59E0B), // Amber
                        const Color(0xFFF43F5E), // Rose
                        const Color(0xFF3B82F6), // Blue
                        const Color(0xFFFFFFFF), // White
                      ].map((c) {
                        final isSelected = widget.controller.aliveColor.value == c.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => widget.controller.setAliveColor(c),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : AppTheme.border,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: c.withOpacity(0.6),
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 13,
                                      color: c.computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.palette_outlined, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.surface900,
                  foregroundColor: AppTheme.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: AppTheme.border),
                  ),
                  minimumSize: const Size(28, 28),
                  padding: EdgeInsets.zero,
                ),
                tooltip: 'Choose Custom Color',
                onPressed: () => _openColorPickerDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Inter-cell Gap / Padding Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Cell Padding',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(widget.controller.cellPadding * 100).round()}%',
                style: const TextStyle(
                  color: AppTheme.cyanAccent,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.aliveColor,
              inactiveTrackColor: AppTheme.surface700,
              thumbColor: AppTheme.aliveColor,
              overlayColor: AppTheme.aliveColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 3,
            ),
            child: Slider(
              value: widget.controller.cellPadding,
              min: 0.0,
              max: 0.4,
              onChanged: (val) => widget.controller.setCellPadding(val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenChip(String label, int maxGen) {
    final isCurrent = widget.controller.maxGenerations == maxGen;
    return InkWell(
      onTap: () {
        widget.controller.setMaxGenerations(maxGen);
        _maxGenController.text = maxGen == 0 ? '∞' : maxGen.toString();
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrent ? AppTheme.cyanAccent.withOpacity(0.15) : AppTheme.surface900,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCurrent ? AppTheme.cyanAccent : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isCurrent ? AppTheme.cyanAccent : AppTheme.textSecondary,
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _openColorPickerDialog(BuildContext context) {
    const extendedPalette = [
      Color(0xFF10B981), // Emerald
      Color(0xFF06B6D4), // Cyan
      Color(0xFF0EA5E9), // Sky
      Color(0xFF3B82F6), // Blue
      Color(0xFF6366F1), // Indigo
      Color(0xFF8B5CF6), // Violet
      Color(0xFF6B21A8), // Deep Purple
      Color(0xFFA855F7), // Purple
      Color(0xFFEC4899), // Pink
      Color(0xFFF43F5E), // Rose
      Color(0xFFEF4444), // Red
      Color(0xFFF97316), // Orange
      Color(0xFFF59E0B), // Amber
      Color(0xFFEAB308), // Yellow
      Color(0xFF84CC16), // Lime
      Color(0xFF22C55E), // Green
      Color(0xFF14B8A6), // Teal
      Color(0xFFFFFFFF), // White
      Color(0xFFE2E8F0), // Slate 200
      Color(0xFF94A3B8), // Slate 400
      Color(0xFFF472B6), // Light Pink
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surface800,
          title: const Text(
            'Select Cell Alive Color',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: 280,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: extendedPalette.map((c) {
                final isSelected = widget.controller.aliveColor.value == c.value;
                return InkWell(
                  onTap: () {
                    widget.controller.setAliveColor(c);
                    Navigator.of(dialogContext).pop();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : AppTheme.border,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: c.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShapeButton({
    required CellShape shape,
    required IconData icon,
    required String label,
  }) {
    final isSelected = widget.controller.cellShape == shape;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.aliveColor.withOpacity(0.15) : AppTheme.surface900,
        foregroundColor: isSelected ? AppTheme.aliveColor : AppTheme.textSecondary,
        side: BorderSide(
          color: isSelected ? AppTheme.aliveColor : AppTheme.border,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      icon: Icon(icon, size: 13),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () => widget.controller.setCellShape(shape),
    );
  }

  Widget _buildPlaybackStrip() {
    final isRunning = widget.controller.isRunning;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppTheme.surface800,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rewind to 0
              IconButton(
                icon: const Icon(Icons.fast_rewind_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.surface700,
                  foregroundColor: AppTheme.textSecondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                tooltip: 'Rewind to 0',
                onPressed: widget.controller.resetGrid,
              ),
              const SizedBox(width: 6),

              // Step Back (History)
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.surface700,
                  foregroundColor: widget.controller.canStepBack
                      ? AppTheme.textPrimary
                      : AppTheme.textMuted,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                tooltip: 'Step Back (1 Gen)',
                onPressed: widget.controller.canStepBack
                    ? widget.controller.stepBackward
                    : null,
              ),
              const SizedBox(width: 6),

              // Primary RUN / PAUSE Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRunning ? AppTheme.amberAccent : AppTheme.aliveColor,
                    foregroundColor: AppTheme.background,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: Icon(
                    isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isRunning ? 'PAUSE' : 'RUN SIMULATION',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: widget.controller.togglePlayPause,
                ),
              ),
              const SizedBox(width: 6),

              // Step Forward
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.surface700,
                  foregroundColor: AppTheme.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                tooltip: 'Step Forward (1 Gen)',
                onPressed: widget.controller.stepForward,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
