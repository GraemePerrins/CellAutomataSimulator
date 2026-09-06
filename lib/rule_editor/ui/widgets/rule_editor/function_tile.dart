import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../models/function_doc.dart';
import 'function_hover_card.dart';

class FunctionTile extends StatefulWidget {
  final FunctionDoc doc;
  final ValueChanged<String> onInsert;

  const FunctionTile({
    super.key,
    required this.doc,
    required this.onInsert,
  });

  @override
  State<FunctionTile> createState() => _FunctionTileState();
}

class _FunctionTileState extends State<FunctionTile> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isHovered = false;

  void _showHoverCard() {
    _removeHoverCard();
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 260,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, -150),
          child: Material(
            color: Colors.transparent,
            child: FunctionHoverCard(doc: widget.doc),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeHoverCard() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeHoverCard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _showHoverCard();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _removeHoverCard();
        },
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () {
            widget.onInsert(widget.doc.token);
          },
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.doc.textColor.withOpacity(0.12)
                  : StudioTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _isHovered
                    ? widget.doc.textColor.withOpacity(0.5)
                    : StudioTheme.outlineVariant.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                widget.doc.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: StudioTheme.monoFont,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _isHovered ? Colors.white : widget.doc.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
