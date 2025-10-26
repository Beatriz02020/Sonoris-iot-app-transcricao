import 'package:flutter/material.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

/// DropdownField: widget separado para encapsular o DropdownButtonFormField
/// Mantém a aparência usada em `customTextField.dart` anteriormente.
class CustomSelect extends StatefulWidget {
  final List<String> options;
  final String? value;
  final void Function(String?)? onChanged;
  final String hintText;
  final bool enabled;

  const CustomSelect({
    Key? key,
    required this.options,
    this.value,
    this.onChanged,
    this.hintText = '',
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomSelect> createState() => _CustomSelectState();
}

class _CustomSelectState extends State<CustomSelect> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected =
        widget.value ??
        (widget.options.isNotEmpty ? widget.options.first : null);
  }

  OutlineInputBorder _customBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color ?? AppColors.blue500, width: 1.5),
    );
  }

  void _openMenu() async {
    if (!widget.enabled) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size screenSize = MediaQuery.of(context).size;
    final double fieldWidth = renderBox.size.width;

    final double left = offset.dx;

    // Use an OverlayEntry so we can force the popup width to match the field
    final overlay = Overlay.of(context);

    // calculate menu height
    const double itemHeight = 40.0;
    final double menuHeight = (widget.options.length * itemHeight).clamp(
      0,
      300,
    );

    // choose whether to show below or above depending on available space
    final double availableBelow =
        screenSize.height - (offset.dy + renderBox.size.height);
    double menuTop = offset.dy + renderBox.size.height;
    if (availableBelow < menuHeight) {
      // show above
      menuTop = offset.dy - menuHeight;
      if (menuTop < 0) menuTop = 0; // fallback
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            entry.remove();
          },
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: left,
                  top: menuTop,
                  width: fieldWidth,
                  child: Material(
                    color: AppColors.background,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.blue500, width: 1.5),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: widget.options.length,
                        itemBuilder: (context, index) {
                          final option = widget.options[index];
                          final bool isSelected = option == _selected;
                          return InkWell(
                            onTap: () {
                              entry.remove();
                              if (option != _selected) {
                                setState(() => _selected = option);
                                if (widget.onChanged != null)
                                  widget.onChanged!(option);
                              }
                            },
                            child: Container(
                              height: itemHeight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.gray900,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.check,
                                        size: 18,
                                        color: AppColors.blue500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  void didUpdateWidget(covariant CustomSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selected =
          widget.value ??
          (widget.options.isNotEmpty ? widget.options.first : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? _openMenu : null,
      child: InputDecorator(
        decoration: InputDecoration(
          border: _customBorder(),
          enabledBorder: _customBorder(),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.blue300, width: 1.5),
          ),
          focusedBorder: _customBorder(color: AppColors.blue700),
          hintStyle: AppTextStyles.body,
          hintText: widget.hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 6,
          ),
        ),
        isEmpty: _selected == null || _selected == '',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selected ?? widget.hintText,
                style: AppTextStyles.body.copyWith(
                  color:
                      _selected == null ? AppColors.gray500 : AppColors.gray900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              color: widget.enabled ? AppColors.blue500 : AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }
}
