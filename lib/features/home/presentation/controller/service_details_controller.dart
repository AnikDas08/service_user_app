import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../widgets/booking_dialog.dart';

class TimeSlot {
  final String startTime;
  final String endTime;
  final String day;
  bool isSelected;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.day,
    this.isSelected = false,
  });

  String get displayTime => '$startTime-$endTime';
  String get fullDisplayTime => '$day: $startTime-$endTime';
}

class ServiceDetailsController extends GetxController {
  Map<String, dynamic> serviceProvider = {};

  final RxBool isFavorite = false.obs;
  final RxList<Map<String, dynamic>> workPhotos = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> reviews = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> availability = <Map<String, dynamic>>[].obs;
  final RxList<String> selectedServiceIds = <String>[].obs;

  // Simplified Time Slot System
  final RxList<TimeSlot> availableTimeSlots = <TimeSlot>[].obs;
  final selectedTimeSlots = <TimeSlot>[].obs;

  @override
  void onInit() {
    super.onInit();
    serviceProvider = Get.arguments ?? {};
    _loadData();
    _generateTimeSlots();
  }

  void _loadData() {
    // Load work photos
    workPhotos.value = [
      {"image": "assets/images/work1.png"},
      {"image": "assets/images/work2.png"},
      {"image": "assets/images/work3.png"},
      {"image": "assets/images/work4.png"},
    ];

    // Load reviews
    reviews.value = [
      {
        "name": "Rahad Ullah",
        "rating": 5.0,
        "comment": "He Does A Great Job. I Had His Hair Cut A Few Days Ago. Always Tells All My Expectations | Always Provide Top Service.",
        "avatar": "assets/images/reviewer1.png",
        "timeAgo": "2 days ago"
      },
      {
        "name": "Rahad Ullah",
        "rating": 5.0,
        "comment": "He Does A Great Job. I Had His Hair Cut A Few Days Ago. Always Tells All My Expectations | Always Provide Top Service.",
        "avatar": "assets/images/reviewer2.png",
        "timeAgo": "5 days ago"
      },
    ];

    // Load services with proper structure
    services.value = [
      {
        "id": "1",
        "name": "Hair Cut",
        "type": "Color Cut",
        "price": "RSD 2500",
        "duration": "1 hour",
        "selected": false
      },
      {
        "id": "2",
        "name": "hair cut",
        "type": "Hair Wash",
        "price": "RSD 1500",
        "duration": "1 hour",
        "selected": false
      },
    ];

    // Load availability data
    availability.value = [
      {
        "day": AppString.monday_text,
        "isAvailable": true,
        "timeSlots": ["9:00 AM - 12:00 PM", "2:00 PM - 6:00 PM"]
      },
      {
        "day": AppString.tuesday_text,
        "isAvailable": true,
        "timeSlots": ["9:00 AM - 12:00 PM", "2:00 PM - 6:00 PM"]
      },
      {
        "day": AppString.wednesday_text,
        "isAvailable": true,
        "timeSlots": ["9:00 AM - 12:00 PM", "2:00 PM - 6:00 PM"]
      },
      {
        "day": AppString.thursday_text,
        "isAvailable": true,
        "timeSlots": ["9:00 AM - 12:00 PM", "2:00 PM - 6:00 PM"]
      },
      {
        "day": AppString.friday_text,
        "isAvailable": true,
        "timeSlots": ["9:00 AM - 12:00 PM", "2:00 PM - 6:00 PM"]
      },
      {
        "day": AppString.saturday_text,
        "isAvailable": true,
        "timeSlots": ["10:00 AM - 4:00 PM"]
      },
      {
        "day": AppString.sunday_text,
        "isAvailable": false,
        "timeSlots": []
      },
    ];
  }

  // Toggle service selection
  void toggleServiceSelection(String serviceId) {
    print("Toggling service: $serviceId");

    int index = services.indexWhere((service) => service['id'] == serviceId);
    if (index != -1) {
      bool currentSelection = services[index]['selected'] ?? false;
      services[index]['selected'] = !currentSelection;

      if (services[index]['selected']) {
        if (!selectedServiceIds.contains(serviceId)) {
          selectedServiceIds.add(serviceId);
        }
      } else {
        selectedServiceIds.remove(serviceId);
      }

      print("Service ${services[index]['name']} is now ${services[index]['selected'] ? 'selected' : 'unselected'}");
      print("Selected IDs: $selectedServiceIds");

      // Force update the UI
      services.refresh();
      selectedServiceIds.refresh();
      update();
    }
  }

  // Check if service is selected
  bool isServiceSelected(String serviceId) {
    return selectedServiceIds.contains(serviceId);
  }

  // Get selected services
  List<Map<String, dynamic>> getSelectedServices() {
    return services.where((service) => service['selected'] == true).toList();
  }

  // Clear all selections
  void clearAllSelections() {
    for (var service in services) {
      service['selected'] = false;
    }
    selectedServiceIds.clear();
    services.refresh();
    update();
  }

  // Get total price of selected services
  int getTotalPrice() {
    int total = 0;
    for (var service in getSelectedServices()) {
      String priceStr = service['price'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      total += int.tryParse(priceStr) ?? 0;
    }
    return total;
  }

  // Get total duration of selected services
  String getTotalDuration() {
    int totalMinutes = 0;
    for (var service in getSelectedServices()) {
      String duration = service['duration'].toString();
      // Extract numbers from duration string
      RegExp regExp = RegExp(r'\d+');
      String? match = regExp.stringMatch(duration);
      if (match != null) {
        int minutes = int.tryParse(match) ?? 0;
        if (duration.toLowerCase().contains('hr')) {
          totalMinutes += minutes * 60;
        } else {
          totalMinutes += minutes;
        }
      }
    }

    if (totalMinutes >= 60) {
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;
      return minutes > 0 ? '${hours}Hr ${minutes}Min' : '${hours}Hr';
    } else {
      return '${totalMinutes}Min';
    }
  }

  void _generateTimeSlots() {
    List<TimeSlot> slots = [];

    // Convert availability data to time slots for all days
    for (var dayData in availability) {
      if (dayData['isAvailable'] == true) {
        String day = dayData['day'];
        List<String> timeSlots = List<String>.from(dayData['timeSlots']);

        for (String timeSlot in timeSlots) {
          List<String> times = timeSlot.split(' - ');
          if (times.length == 2) {
            List<TimeSlot> hourlySlots = _generateHourlySlots(
                day,
                times[0].trim(),
                times[1].trim()
            );
            slots.addAll(hourlySlots);
          }
        }
      }
    }

    availableTimeSlots.value = slots;
  }

  List<TimeSlot> _generateHourlySlots(String day, String startTime, String endTime) {
    List<TimeSlot> slots = [];
    int startHour = _parseTimeToHour(startTime);
    int endHour = _parseTimeToHour(endTime);

    for (int hour = startHour; hour < endHour; hour++) {
      String slotStart = _formatHour(hour);
      String slotEnd = _formatHour(hour + 1);

      slots.add(TimeSlot(
        startTime: slotStart,
        endTime: slotEnd,
        day: day,
      ));
    }

    return slots;
  }

  int _parseTimeToHour(String time) {
    List<String> parts = time.split(' ');
    String timePart = parts[0];

    int hour = int.parse(timePart.split(':')[0]);

    return hour;
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00';
    if (hour < 12) return '$hour:00';
    if (hour == 12) return '12:00';
    return '${hour - 12}:00';
  }

  // Simplified Time Slot Methods
  void toggleTimeSlot(TimeSlot slot) {
    // Clear all previous selections
    for (var s in availableTimeSlots) {
      s.isSelected = false;
    }
    selectedTimeSlots.clear();

    // Select the clicked slot
    slot.isSelected = true;
    selectedTimeSlots.add(slot);

    update();
  }

  void clearTimeSlotSelections() {
    for (var slot in availableTimeSlots) {
      slot.isSelected = false;
    }
    selectedTimeSlots.clear();
    update();
  }

  String getSelectedTimeSlotsText() {
    if (selectedTimeSlots.isEmpty) {
      return 'Select Time Slots';
    }
    return selectedTimeSlots.map((slot) => slot.fullDisplayTime).join(', ');
  }

  // Existing methods
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void bookNow() {
    Get.dialog(const BookingDialog());
  }

  void showAvailability() {
    // This method can be used to trigger the availability bottom sheet
  }

  Map<String, dynamic> getBookingData() {
    return {
      'serviceProvider': serviceProvider,
      'selectedServices': services.where((service) => service['selected'] == true).toList(),
      'selectedTimeSlots': selectedTimeSlots.map((slot) => {
        'day': slot.day,
        'startTime': slot.startTime,
        'endTime': slot.endTime,
        'displayTime': slot.displayTime,
      }).toList(),
      'totalSelectedSlots': selectedTimeSlots.length,
    };
  }
}