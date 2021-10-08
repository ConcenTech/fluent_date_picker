import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'acrylic.dart';
import 'constants.dart';
import 'hover_button.dart';
import 'info_label.dart';
import 'pickers.dart';
import 'popup.dart';

// There is a known issue with clicking in the popup and select the date.
// The current workaround is very hacky and doesn't work very well with the
// current implementation. TODO: Fix clicking on ListWheelScrollView
// https://github.com/flutter/flutter/issues/38803

/// The date picker gives you a standardized way to let users pick a localized
/// date value using touch, mouse, or keyboard input. Use a date picker to let
/// a user pick a known date, such as a date of birth, where the context of the
/// calendar is not important.
///
/// ![DatePicker Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls_datepicker_expand.png)
///
/// See also:
///
/// - [DatePicker Documentation](https://pub.dev/packages/fluent_ui#date-picker)
/// - [TimePicker](https://pub.dev/packages/fluent_ui#time-picker)
class FluidDatePicker extends StatefulWidget {
  const FluidDatePicker({
    Key? key,
    required this.selected,
    this.onChanged,
    this.onCancel,
    this.header,
    this.headerStyle,
    this.showDay = true,
    this.showMonth = true,
    this.showYear = true,
    this.startYear,
    this.endYear,
    this.contentPadding = kPickerContentPadding,
    this.itemPadding = kPickerItemPadding,
    this.popupHeight = kPopupHeight,
    this.cursor = SystemMouseCursors.click,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  /// The current date.
  final DateTime selected;

  /// Whenever the current date is changed. If this is null, the picker is considered disabled
  final ValueChanged<DateTime>? onChanged;

  /// Whenever the user cancels when changing the date.
  final VoidCallback? onCancel;

  /// The header of the picker
  final String? header;

  /// The style of the [header]
  final TextStyle? headerStyle;

  /// Whenever to show the month property
  final bool showMonth;

  /// Whenever to show the day property
  final bool showDay;

  /// Whenever to show the year property
  final bool showYear;

  /// The year to start counting from. If `null`, defaults to [date]'s year `- 100`
  final int? startYear;

  /// The year to end the counting. If `null`, defaults to [date]'s year `+ 25`
  final int? endYear;

  /// The padding of the picker. Defaults to [kPickerContentPadding]
  final EdgeInsetsGeometry contentPadding;

  /// The padding of items inside the dropdown. Defaults to [kPickerItemPadding]
  final EdgeInsetsGeometry itemPadding;

  /// The cursor of the picker. Defaults to [SystemMouseCursors.click]
  final MouseCursor cursor;

  /// The focus node of the picker.
  final FocusNode? focusNode;

  /// Whenever `autofocus` is enabled or not
  final bool autofocus;

  /// The height of the popup. Defaults to [kPopupHeight]
  final double popupHeight;

  @override
  _FluidDatePickerState createState() => _FluidDatePickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('selected', selected,
          ifNull: '${DateTime.now()}'))
      ..add(FlagProperty('showMonth',
          value: showMonth, ifFalse: 'not displaying month'))
      ..add(FlagProperty('showDay',
          value: showDay, ifFalse: 'not displaying day'))
      ..add(FlagProperty('showYear',
          value: showYear, ifFalse: 'not displaying year'))
      ..add(IntProperty('startYear', startYear ?? selected.year - 100))
      ..add(IntProperty('endYear', endYear ?? selected.year + 25))
      ..add(DiagnosticsProperty('contentPadding', contentPadding))
      ..add(DiagnosticsProperty('cursor', cursor))
      ..add(ObjectFlagProperty.has('focusNode', focusNode))
      ..add(
          FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'))
      ..add(DoubleProperty('popupHeight', popupHeight));
  }
}

class _FluidDatePickerState extends State<FluidDatePicker> {
  late DateTime date;
  final popupKey = GlobalKey<PopUpState>();

  FixedExtentScrollController? _monthController;
  FixedExtentScrollController? _dayController;
  FixedExtentScrollController? _yearController;

  int get startYear => (widget.startYear ?? DateTime.now().year - 100).toInt();
  int get endYear => (widget.endYear ?? DateTime.now().year + 25).toInt();

  int get currentYear {
    return List.generate(endYear - startYear, (index) {
      return startYear + index;
    }).firstWhere((v) => v == date.year, orElse: () => 0);
  }

  @override
  void initState() {
    super.initState();
    date = widget.selected;
    initControllers();
  }

  void initControllers() {
    _monthController = FixedExtentScrollController(
      initialItem: date.month - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: date.day - 1,
    );

    _yearController = FixedExtentScrollController(
      initialItem: currentYear - startYear - 1,
    );
  }

  @override
  void dispose() {
    _monthController?.dispose();
    _dayController?.dispose();
    _yearController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FluidDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != date) {
      date = widget.selected;
      _monthController?.jumpToItem(date.month - 1);
      _dayController?.jumpToItem(date.day - 1);
      _yearController?.jumpToItem(currentYear - startYear - 1);
    }
  }

  void handleDateChanged(DateTime newDate) {
    setState(() => date = newDate);
  }

  Size? size;

  @override
  Widget build(BuildContext context) {
    Widget picker = HoverButton(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      cursor: ButtonState.all(widget.cursor),
      onPressed: () async {
        await popupKey.currentState?.openPopup();
        _monthController?.dispose();
        _monthController = null;
        _dayController?.dispose();
        _dayController = null;
        _yearController?.dispose();
        _yearController = null;
        initControllers();
      },
      builder: (context, state) {
        if (state.isDisabled) state = <ButtonStates>{};
        const divider = _Divider(
          direction: Axis.vertical,
          verticalMargin: EdgeInsets.zero,
          horizontalMargin: EdgeInsets.zero,
          thickness: 0.6,
        );
        return AnimatedContainer(
          duration: kThemeAnimationDuration,
          curve: Curves.linear,
          height: kPickerHeight,
          decoration: kPickerDecorationBuilder(context, state),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (widget.showMonth)
              () {
                // MONTH
                return Padding(
                  padding: widget.contentPadding,
                  child: Text(DateFormat.MMMM().format(widget.selected)),
                );
              }(),
            if (widget.showDay) ...[
              divider,
              () {
                // DAY
                return Padding(
                  padding: widget.contentPadding,
                  child: Text(
                    '${widget.selected.day}',
                    textAlign: TextAlign.center,
                  ),
                );
              }(),
            ],
            if (widget.showYear) ...[
              divider,
              () {
                // YEAR
                return Padding(
                  padding: widget.contentPadding,
                  child: Text(
                    '${widget.selected.year}',
                    textAlign: TextAlign.center,
                  ),
                );
              }(),
            ],
          ]),
        );
      },
    );
    print('popupHeight ${widget.popupHeight}');
    print('date $date');
    print('endYear $endYear');
    print('showDay ${widget.showDay}');
    print('showMonth: ${widget.showMonth}');
    print('showYear ${widget.showYear}');
    print('startYear ${widget.startYear}');
    print('_dayController is null: ${_dayController == null}');
    print('_monthController is null: ${_monthController == null}');
    print('_yearController is null: ${_yearController == null}');
    picker = PopUp(
      contentHeight: widget.popupHeight,
      key: popupKey,
      child: picker,
      content: (context) => _DatePickerContentPopUp(
        height: widget.popupHeight,
        date: date,
        dayController: _dayController!,
        endYear: endYear,
        handleDateChanged: handleDateChanged,
        monthController: _monthController!,
        onCancel: () => widget.onCancel?.call(),
        onChanged: () => widget.onChanged?.call(date),
        showDay: widget.showDay,
        showMonth: widget.showMonth,
        showYear: widget.showYear,
        startYear: startYear,
        yearController: _yearController!,
        itemPadding: widget.itemPadding,
      ),
    );
    if (widget.header != null) {
      return InfoLabel(
        label: widget.header!,
        labelStyle: widget.headerStyle,
        child: picker,
      );
    }
    return picker;
  }
}

class _DatePickerContentPopUp extends StatefulWidget {
  const _DatePickerContentPopUp({
    Key? key,
    required this.showMonth,
    required this.showDay,
    required this.showYear,
    required this.date,
    required this.handleDateChanged,
    required this.onChanged,
    required this.onCancel,
    required this.monthController,
    required this.dayController,
    required this.yearController,
    required this.startYear,
    required this.endYear,
    required this.height,
    required this.itemPadding,
  }) : super(key: key);

  final bool showMonth;
  final bool showDay;
  final bool showYear;
  final DateTime date;
  final ValueChanged<DateTime> handleDateChanged;
  final VoidCallback onChanged;
  final VoidCallback onCancel;
  final FixedExtentScrollController monthController;
  final FixedExtentScrollController dayController;
  final FixedExtentScrollController yearController;
  final int startYear;
  final int endYear;
  final double height;

  /// The padding of the picker. Defaults to [kPickerContentPadding]
  final EdgeInsetsGeometry itemPadding;

  @override
  __DatePickerContentPopUpState createState() =>
      __DatePickerContentPopUpState();
}

class __DatePickerContentPopUpState extends State<_DatePickerContentPopUp> {
  int _getDaysInMonth([int? month, int? year]) {
    year ??= DateTime.now().year;
    month ??= DateTime.now().month;
    return DateTimeRange(
      start: DateTime(year, month),
      end: DateTime(year, month + 1),
    ).duration.inDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const divider = _Divider(
      direction: Axis.vertical,
      verticalMargin: EdgeInsets.zero,
      horizontalMargin: EdgeInsets.zero,
    );

    final highlightTileColor = theme.colorScheme.secondary;

    return SizedBox(
      height: widget.height,
      child: Acrylic(
        tint: kPickerBackgroundColor(context),
        shape: kPickerShape(context),
        child: Column(children: [
          Expanded(
            child: Stack(children: [
              kHighlightTile(),
              Row(children: [
                if (widget.showMonth)
                  Expanded(
                    flex: 2,
                    child: () {
                      final items = List.generate(
                        12,
                        (month) {
                          month++;
                          final text = DateFormat.MMMM().format(
                            DateTime(1, month),
                          );
                          return ListTile(
                            contentPadding: widget.itemPadding,
                            title: Text(
                              text,
                              style: theme.textTheme.bodyText2?.copyWith(
                                color: month == widget.date.month
                                    ? highlightTileColor
                                    : null,
                              ),
                            ),
                          );
                        },
                      );
                      // MONTH
                      return PickerNavigatorIndicator(
                        onBackward: () {
                          navigateSides(
                            context,
                            widget.monthController,
                            false,
                            12,
                          );
                        },
                        onForward: () {
                          navigateSides(
                            context,
                            widget.monthController,
                            true,
                            12,
                          );
                        },
                        child: ListWheelScrollView.useDelegate(
                          controller: widget.monthController,
                          itemExtent: kOneLineTileHeight,
                          diameterRatio: kPickerDiameterRatio,
                          physics: const FixedExtentScrollPhysics(),
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: items,
                          ),
                          onSelectedItemChanged: (index) {
                            final month = index + 1;
                            final daysInMonth =
                                _getDaysInMonth(month, widget.date.year);
                            int day = widget.date.day;
                            if (day > daysInMonth) day = daysInMonth;
                            widget.handleDateChanged(DateTime(
                              widget.date.year,
                              month,
                              day,
                              widget.date.hour,
                              widget.date.minute,
                              widget.date.second,
                              widget.date.millisecond,
                              widget.date.microsecond,
                            ));
                            setState(() {});
                          },
                        ),
                      );
                    }(),
                  ),
                if (widget.showDay) ...[
                  divider,
                  Expanded(
                    child: () {
                      // DAY
                      final daysInMonth =
                          _getDaysInMonth(widget.date.month, widget.date.year);
                      return PickerNavigatorIndicator(
                        onBackward: () {
                          navigateSides(
                            context,
                            widget.dayController,
                            false,
                            daysInMonth,
                          );
                        },
                        onForward: () {
                          navigateSides(
                            context,
                            widget.dayController,
                            true,
                            daysInMonth,
                          );
                        },
                        child: ListWheelScrollView.useDelegate(
                          controller: widget.dayController,
                          itemExtent: kOneLineTileHeight,
                          diameterRatio: kPickerDiameterRatio,
                          physics: const FixedExtentScrollPhysics(),
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: List<Widget>.generate(
                              daysInMonth,
                              (day) {
                                day++;
                                return ListTile(
                                  contentPadding: widget.itemPadding,
                                  title: Center(
                                    child: Text(
                                      '$day',
                                      style:
                                          theme.textTheme.bodyText2?.copyWith(
                                        color: day == widget.date.day
                                            ? highlightTileColor
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          onSelectedItemChanged: (index) {
                            widget.handleDateChanged(DateTime(
                              widget.date.year,
                              widget.date.month,
                              index + 1,
                              widget.date.hour,
                              widget.date.minute,
                              widget.date.second,
                              widget.date.millisecond,
                              widget.date.microsecond,
                            ));
                            setState(() {});
                          },
                        ),
                      );
                    }(),
                  ),
                ],
                if (widget.showYear) ...[
                  divider,
                  Expanded(
                    child: () {
                      final years = widget.endYear - widget.startYear;
                      // YEAR
                      return PickerNavigatorIndicator(
                        onBackward: () {
                          navigateSides(
                            context,
                            widget.yearController,
                            false,
                            years,
                          );
                        },
                        onForward: () {
                          navigateSides(
                            context,
                            widget.yearController,
                            true,
                            years,
                          );
                        },
                        child: ListWheelScrollView(
                          controller: widget.yearController,
                          children: List.generate(years, (index) {
                            // index++;
                            final realYear = widget.startYear + index + 1;
                            return ListTile(
                              contentPadding: widget.itemPadding,
                              title: Center(
                                child: Text(
                                  '$realYear',
                                  style: theme.textTheme.bodyText2?.copyWith(
                                    color: realYear == widget.date.year
                                        ? highlightTileColor
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }),
                          itemExtent: kOneLineTileHeight,
                          diameterRatio: kPickerDiameterRatio,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            widget.handleDateChanged(DateTime(
                              widget.startYear + index + 1,
                              widget.date.month,
                              widget.date.day,
                              widget.date.hour,
                              widget.date.minute,
                              widget.date.second,
                              widget.date.millisecond,
                              widget.date.microsecond,
                            ));
                            setState(() {});
                          },
                        ),
                      );
                    }(),
                  ),
                ],
              ]),
            ]),
          ),
          const _Divider(
            verticalMargin: EdgeInsets.zero,
            horizontalMargin: EdgeInsets.zero,
          ),
          YesNoPickerControl(
            onChanged: () {
              Navigator.pop(context);
              widget.onChanged();
            },
            onCancel: () {
              Navigator.pop(context);
              widget.onCancel();
            },
          ),
        ]),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider(
      {this.direction = Axis.horizontal,
      this.thickness,
      this.decoration,
      this.horizontalMargin,
      this.verticalMargin,
      this.size,
      Key? key})
      : super(key: key);

  /// The current direction of the slider. Uses [Axis.horizontal] by default
  final Axis direction;

  /// The thickness of the style.
  ///
  /// If it's horizontal, it corresponds to the divider
  /// `height`, otherwise it corresponds to its `width`
  final double? thickness;

  /// The decoration of the style. If null, defaults to a
  /// [BoxDecoration] with a `Color(0xFFB7B7B7)` for light
  /// mode and `Color(0xFF484848)` for dark mode
  final Decoration? decoration;

  /// The vertical margin of the style.
  final EdgeInsetsGeometry? verticalMargin;

  /// The horizontal margin of the style.
  final EdgeInsetsGeometry? horizontalMargin;

  /// The size of the divider. The opposite of the [DividerThemeData.thickness]
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: direction == Axis.horizontal ? thickness : size,
      width: direction == Axis.vertical ? thickness : size,
      margin: direction == Axis.horizontal ? horizontalMargin : verticalMargin,
      decoration: decoration,
    );
  }
}
