import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'hover_button.dart';

Widget kHighlightTile() {
  return Builder(builder: (context) {
    final theme = Theme.of(context);
    final highlightTileColor = theme.colorScheme.secondary;
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        height: kOneLineTileHeight,
        padding: const EdgeInsets.all(6.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          tileColor: highlightTileColor,
        ),
      ),
    );
  });
}

Color kPickerBackgroundColor(BuildContext context) =>
    Theme.of(context).cardTheme.color ?? Colors.white;

ShapeBorder kPickerShape(BuildContext context) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
      side: BorderSide(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: 0.6,
      ),
    );

TextStyle? kPickerPopupTextStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 16);
}

Decoration kPickerDecorationBuilder(
    BuildContext context, Set<ButtonStates> states) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(4.0),
    color: Theme.of(context).primaryColor,
  );
}

class YesNoPickerControl extends StatelessWidget {
  const YesNoPickerControl({
    Key? key,
    required this.onChanged,
    required this.onCancel,
  }) : super(key: key);

  final VoidCallback onChanged;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    // ButtonStyle style() {
    //   return ButtonStyle(
    //     backgroundColor: ButtonState.resolveWith(
    //       (states) => ButtonThemeData.uncheckedInputColor(
    //         FluentTheme.of(context),
    //         states,
    //       ),
    //     ),
    //     border: ButtonState.all(BorderSide.none),
    //   );
    // }

    return Row(children: [
      Expanded(
        child: Container(
          margin: const EdgeInsets.all(4.0),
          height: kOneLineTileHeight / 1.2,
          child: ElevatedButton(
            child: const Icon(Icons.check),
            onPressed: onChanged,
            // style: ,
          ),
        ),
      ),
      Expanded(
        child: Container(
          margin: const EdgeInsets.all(4.0),
          height: kOneLineTileHeight / 1.2,
          child: ElevatedButton(
            child: const Icon(Icons.close),
            onPressed: onCancel,
            // style: style(),
          ),
        ),
      ),
    ]);
  }
}

class PickerNavigatorIndicator extends StatelessWidget {
  const PickerNavigatorIndicator({
    Key? key,
    required this.child,
    required this.onBackward,
    required this.onForward,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onForward;
  final VoidCallback onBackward;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onPressed: () {},
      builder: (context, state) {
        final show = state.isHovering || state.isPressing || state.isFocused;
        return Stack(children: [
          child,
          if (show)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: kOneLineTileHeight,
              child: TextButton(
                child: const RotatedBox(
                  quarterTurns: 1,
                  child: Icon(Icons.chevron_left, size: 12),
                ),
                onPressed: onBackward,
              ),
            ),
          if (show)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: kOneLineTileHeight,
              child: TextButton(
                child: const RotatedBox(
                  quarterTurns: 1,
                  child: Icon(Icons.chevron_right, size: 12),
                ),
                onPressed: onForward,
              ),
            ),
        ]);
      },
    );
  }
}

void navigateSides(
  BuildContext context,
  FixedExtentScrollController controller,
  bool forward,
  int amount,
) {
  final duration = kThemeAnimationDuration;
  final curve = Curves.linear;
  if (forward) {
    final currentItem = controller.selectedItem;
    int to = currentItem + 1;
    if (currentItem == amount - 1) to = 0;
    controller.animateToItem(
      to,
      duration: duration,
      curve: curve,
    );
  } else {
    final currentItem = controller.selectedItem;
    int to = currentItem - 1;
    if (currentItem == 0) to = amount - 1;
    controller.animateToItem(
      to,
      duration: duration,
      curve: curve,
    );
  }
}
