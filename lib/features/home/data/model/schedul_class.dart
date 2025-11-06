class ScheduleResponse {
  final bool success;
  final List<ScheduleData> data;

  ScheduleResponse({
    required this.success,
    required this.data,
  });

  factory ScheduleResponse.fromJson(Map<dynamic, dynamic> json) {
    return ScheduleResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ScheduleData.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class ScheduleData {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final  num duration;
  final  num count;
  final bool isActive;

  ScheduleData({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.count,
    required this.isActive,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    return ScheduleData(
      id: json['_id'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: json['duration'] ?? 0,
      count: json['count'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String get formattedTimeRange {
    String formatTime(DateTime time) {
       num hour = time.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    }

    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  String get dayOfWeek {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}