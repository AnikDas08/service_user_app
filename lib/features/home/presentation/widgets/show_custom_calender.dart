import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';

import '../../../../utils/constants/app_colors.dart';

// GlobalKey used to access context for showDialog when Get.context might not be ready.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Displays a custom calendar view dialog.
void showCustomCalendarView({
  required DateTime initialDate,
  required Function(DateTime value) onDateSelected,
  bool isSecond = false,
  List<DateTime>? availableDates,
}) {
  var context = rootNavigatorKey.currentContext ?? Get.context;
  if (context == null) return;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CalendarView(
        initialDate: initialDate,
        onDateSelected: onDateSelected,
        isSecond: isSecond,
        availableDates: availableDates,
      );
    },
  );
}

class CalendarView extends StatefulWidget {
  final DateTime initialDate;
  final bool isSecond;
  final Function(DateTime) onDateSelected;
  final List<DateTime>? availableDates;

  const CalendarView({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.isSecond,
    this.availableDates,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _displayedMonth;
  late DateTime _selectedAppointmentDate;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
    _selectedAppointmentDate = widget.initialDate;
  }

  // --- Localization Helpers for Months and Weekdays ---

  /// Helper to get localized month names (0-indexed).
  String _getLocalizedMonthName(int monthIndex) {
    String locale = Get.locale?.languageCode ?? 'en';

    const Map<String, List<String>> monthNames = {
      'en': ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
      'ru': ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"],
      'sr': ["Јануар", "Фебруар", "Март", "Април", "Мај", "Јун", "Јул", "Август", "Септембар", "Октобар", "Новембар", "Децембар"],
    };

    List<String> names = monthNames[locale] ?? monthNames['en']!;
    return names[monthIndex];
  }

  /// Helper to get localized weekday names (starting Sunday).
  List<String> get _localizedWeekdays {
    String locale = Get.locale?.languageCode ?? 'en';

    const Map<String, List<String>> weekdayNames = {
      'en': ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"],
      'ru': ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"],
      'sr': ["Не", "По", "Ут", "Ср", "Чт", "Пе", "Су"],
    };

    return weekdayNames[locale] ?? weekdayNames['en']!;
  }

  // --- Navigation Methods ---

  void _changeYear(int year) {
    setState(() {
      _displayedMonth = DateTime(year, _displayedMonth.month, 1);
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + delta, 1);
    });
  }

  // --- Availability and Selection Logic ---

  /// Checks if a date is present in the list of available dates from the API.
  bool _isDateAvailable(DateTime dateTime) {
    if (widget.availableDates == null || widget.availableDates!.isEmpty) {
      return true;
    }

    final normalized = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return widget.availableDates!.any((availableDate) {
      final normalizedAvailable = DateTime(availableDate.year, availableDate.month, availableDate.day);
      return normalizedAvailable.isAtSameMomentAs(normalized);
    });
  }

  /// Determines if a date is selectable (active).
  bool _isActive({required DateTime dateTime}) {
    final normalizedDateTime = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final normalizedInitialDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    // 1. Check if the date is available (API constraint)
    if (!_isDateAvailable(dateTime)) {
      return false;
    }

    // 2. Check time constraints
    if (widget.isSecond) {
      // Must be strictly AFTER the initial date.
      return normalizedDateTime.isAfter(normalizedInitialDate);
    } else {
      // Must be TODAY or later.
      return normalizedDateTime.isAfter(normalizedToday.subtract(const Duration(days: 1)));
    }
  }

  void _onDaySelected(DateTime day) {
    if (!_isActive(dateTime: day)) {
      return;
    }

    setState(() {
      _selectedAppointmentDate = day;
    });

    widget.onDateSelected(_selectedAppointmentDate);
    Navigator.pop(context);
  }

  // --- Build Methods ---

  List<Widget> _buildDays() {
    int daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    // Determine the weekday of the 1st of the month (1=Mon, 7=Sun).
    int firstWeekdayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday;
    // Convert to 0-6 index where Sunday=0 (Dart's weekday is 7 for Sunday, so % 7 works for conversion).
    int startIndex = firstWeekdayOfMonth % 7;

    List<Widget> dayWidgets = [];

    // Add empty containers for padding
    for (int i = 0; i < startIndex; i++) {
      dayWidgets.add(Container());
    }

    // Actual days of the current month
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDay = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      bool isSelectedDay = currentDay.day == _selectedAppointmentDate.day &&
          currentDay.month == _selectedAppointmentDate.month &&
          currentDay.year == _selectedAppointmentDate.year;

      bool isActive = _isActive(dateTime: currentDay);

      dayWidgets.add(
        GestureDetector(
          onTap: isActive ? () => _onDaySelected(currentDay) : null,
          child: Container(
            margin: EdgeInsets.all(4.r),
            decoration: const BoxDecoration(
              color: AppColors.transparent,
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelectedDay ? AppColors.primaryColor : AppColors.transparent,
                border: Border.all(
                  width: 2,
                  color: isSelectedDay ? AppColors.primaryColor : AppColors.transparent,
                ),
              ),
              child: Center(
                child: CommonText(
                  text: day.toString(),
                  color: isSelectedDay
                      ? AppColors.white
                      : isActive
                      ? AppColors.black // Black for available and active dates
                      : AppColors.black200, // Gray for inactive/unavailable dates
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Add empty containers to complete the week rows
    while (dayWidgets.length % 7 != 0) {
      dayWidgets.add(Container());
    }

    return dayWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      backgroundColor: AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(15.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top bar: Year and Month with change buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Year and Month Display/Picker (Multilingual Months)
                  Row(
                    children: [
                      // Year Popup (Numbers do not need translation)
                      PopupMenuButton<int>(
                        color: AppColors.white,
                        position: PopupMenuPosition.under,
                        child: CommonText(
                          text: _displayedMonth.year.toString(),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        onSelected: _changeYear,
                        itemBuilder: (context) {
                          // Generate next 5 years
                          return List.generate(5, (index) {
                            int year = DateTime.now().year + index;
                            return PopupMenuItem(
                              value: year,
                              child: CommonText(text: year.toString(), color: AppColors.black),
                            );
                          });
                        },
                      ),
                      CommonText(text: "  -  ", fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.black),
                      // Month Popup (Localized Month Names)
                      PopupMenuButton<int>(
                        color: AppColors.white,
                        position: PopupMenuPosition.under,
                        child: CommonText(
                          text: _getLocalizedMonthName(_displayedMonth.month - 1),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        onSelected: (value) {
                          setState(() {
                            // value is the month index (0-11). Month is 1-12.
                            _displayedMonth = DateTime(_displayedMonth.year, value + 1, 1);
                          });
                        },
                        itemBuilder: (context) {
                          // Use localized month names for the dropdown items
                          return List.generate(12, (index) {
                            return PopupMenuItem(
                              value: index,
                              child: CommonText(text: _getLocalizedMonthName(index), color: AppColors.black),
                            );
                          });
                        },
                      ),
                    ],
                  ),

                  // Month Navigation Arrows
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _changeMonth(-1),
                        icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.r),
                      ),
                      IconButton(
                        onPressed: () => _changeMonth(1),
                        icon: Icon(Icons.arrow_forward_ios, color: AppColors.black, size: 20.r),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h),

            // Weekday labels row (Multilingual Weekdays)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _localizedWeekdays // Use localized list
                  .map(
                    (day) => Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: CommonText(
                      text: day,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
            SizedBox(height: 8.h),

            // Day Grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 7,
              padding: EdgeInsets.zero,
              children: _buildDays(),
            ),
          ],
        ),
      ),
    );
  }
}