import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/home/data/model/provider_response.dart';
import 'package:haircutmen_user_app/services/api/api_service.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../services/storage/storage_services.dart';
import '../../data/model/schedul_class.dart';
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
  ProvidersData? providerData;
  String? id;

  final RxList<dynamic> review = <dynamic>[].obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt totalReviews = 0.obs;
  final RxBool isLoadingReviews = false.obs;

  final RxBool isLoading = true.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isLoadingSchedule = false.obs;
  final RxList<Map<String, dynamic>> workPhotos = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> reviews = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> availability = <Map<String, dynamic>>[].obs;
  final RxList<String> selectedServiceIds = <String>[].obs;
  RxString name="".obs;
  RxString comment="".obs;
  RxDouble rating=0.0.obs;
  RxString image="".obs;

  final RxList<TimeSlot> availableTimeSlots = <TimeSlot>[].obs;
  final selectedTimeSlots = <TimeSlot>[].obs;
  final providerId="";

  // Schedule data from API
  final RxList<ScheduleData> providerSchedule = <ScheduleData>[].obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      id = Get.arguments;
    }

    _loadStaticData();
    _generateTimeSlots();
    _loadProvider();
  }

  void _loadStaticData() {
    // Load work photos (static for now)
    workPhotos.value = [
      {"image": "assets/images/work1.png"},
      {"image": "assets/images/work2.png"},
      {"image": "assets/images/work3.png"},
      {"image": "assets/images/work4.png"},
    ];

    // Load reviews (static for now)
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

    // Load availability data (static for now) - Updated to 24-hour format
    availability.value = [
      {
        "day": AppString.monday_text,
        "isAvailable": true,
        "timeSlots": ["09:00 - 12:00", "14:00 - 18:00"]
      },
      {
        "day": AppString.tuesday_text,
        "isAvailable": true,
        "timeSlots": ["09:00 - 12:00", "14:00 - 18:00"]
      },
      {
        "day": AppString.wednesday_text,
        "isAvailable": true,
        "timeSlots": ["09:00 - 12:00", "14:00 - 18:00"]
      },
      {
        "day": AppString.thursday_text,
        "isAvailable": true,
        "timeSlots": ["09:00 - 12:00", "14:00 - 18:00"]
      },
      {
        "day": AppString.friday_text,
        "isAvailable": true,
        "timeSlots": ["09:00 - 12:00", "14:00 - 18:00"]
      },
      {
        "day": AppString.saturday_text,
        "isAvailable": true,
        "timeSlots": ["10:00 - 16:00"]
      },
      {
        "day": AppString.sunday_text,
        "isAvailable": false,
        "timeSlots": []
      },
    ];
  }

  Future<void> _loadProvider() async {
    try {
      isLoading.value = true;

      final response = await ApiService.get(
        "${ApiEndPoint.provider}/$id",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final dataList = response.data['data'] as List<dynamic>?;
        if (dataList != null && dataList.isNotEmpty) {
          providerData = ProvidersData.fromJson(dataList[0]);

          // Convert API services to local format - only services with category
          _convertServicesToLocalFormat();

          fetchReviews();

          // Update service images if available
          if (providerData!.serviceImages.isNotEmpty) {
            workPhotos.value = providerData!.serviceImages
                .map((img) => {"image": img})
                .toList();
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load provider data',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error loading provider: $e");
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  // NEW METHOD: Load provider schedule from API
  Future<void> loadProviderSchedule() async {
    if (providerData?.user.id == null) {
      Get.snackbar(
        'Error',
        'Provider information not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoadingSchedule.value = true;

      final response = await ApiService.get(
        "schedule/provider-schedule/${providerData!.user.id}",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final scheduleResponse = ScheduleResponse.fromJson(response.data);

        if (scheduleResponse.success) {
          providerSchedule.value = scheduleResponse.data
              .where((schedule) => schedule.isActive)
              .toList();

          // Sort by date
          providerSchedule.sort((a, b) => a.date.compareTo(b.date));

          print("Successfully loaded ${providerSchedule.length} schedule slots");
        } else {
          print("Failed to load Schedule");
        }
      } else {
        print("Failed to load Schedule");
      }
    } catch (e) {
      print("Error loading provider schedule: $e");
    } finally {
      isLoadingSchedule.value = false;
    }
  }

  void _convertServicesToLocalFormat() {
    if (providerData == null || providerData!.services.isEmpty) {
      services.value = [];
      return;
    }

    // Filter services that have category (exclude ones without category like the "New" service)
    services.value = providerData!.services
        .where((service) => service.category != null)
        .map((service) {
      // Calculate duration based on price per hour and service price
      int durationMinutes = 60; // Default 1 hour
      if (providerData!.pricePerHour > 0 && service.price > 0) {
        durationMinutes = ((service.price / providerData!.pricePerHour) * 60).round();
      }

      String duration = durationMinutes >= 60
          ? '${(durationMinutes / 60).round()} hour${durationMinutes >= 120 ? 's' : ''}'
          : '$durationMinutes min';

      return {
        "id": service.id,
        "name": service.category?.name ?? "Service",
        "type": service.subCategory?.name ?? service.status,
        "price": "RSD ${service.price.toInt()}",
        "duration": duration,
        "selected": false,
        "rawPrice": service.price,
      };
    }).toList();

    services.refresh();
  }

  // Toggle service selection
  void toggleServiceSelection(String serviceId) {
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

      services.refresh();
      selectedServiceIds.refresh();
      update();
    }
  }

  bool isServiceSelected(String serviceId) {
    return selectedServiceIds.contains(serviceId);
  }

  List<Map<String, dynamic>> getSelectedServices() {
    return services.where((service) => service['selected'] == true).toList();
  }

  void clearAllSelections() {
    for (var service in services) {
      service['selected'] = false;
    }
    selectedServiceIds.clear();
    services.refresh();
    update();
  }

  int getTotalPrice() {
    int total = 0;
    for (var service in getSelectedServices()) {
      if (service['rawPrice'] != null) {
        total += (service['rawPrice'] as double).toInt();
      } else {
        String priceStr = service['price'].toString().replaceAll(RegExp(r'[^0-9]'), '');
        total += int.tryParse(priceStr) ?? 0;
      }
    }
    return total;
  }

  String getTotalDuration() {
    int totalMinutes = 0;
    for (var service in getSelectedServices()) {
      String duration = service['duration'].toString();
      RegExp regExp = RegExp(r'\d+');
      String? match = regExp.stringMatch(duration);
      if (match != null) {
        int minutes = int.tryParse(match) ?? 0;
        if (duration.toLowerCase().contains('hour')) {
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
      String slotStart = _formatHour24(hour);
      String slotEnd = _formatHour24(hour + 1);

      slots.add(TimeSlot(
        startTime: slotStart,
        endTime: slotEnd,
        day: day,
      ));
    }

    return slots;
  }

  int _parseTimeToHour(String time) {
    // Parse 24-hour format time (e.g., "09:00" or "14:00")
    String timePart = time.split(':')[0];
    int hour = int.parse(timePart);
    return hour;
  }

  String _formatHour24(int hour) {
    // Format hour in 24-hour format with leading zero
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  void toggleTimeSlot(TimeSlot slot) {
    for (var s in availableTimeSlots) {
      s.isSelected = false;
    }
    selectedTimeSlots.clear();

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

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void bookNow() {
    if (selectedServiceIds.isEmpty) {
      Get.snackbar(
        'No Service Selected',
        'Please select at least one service',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(const BookingDialog());
  }

  // Updated method to show availability with API call
  Future<void> showAvailability() async {
    await loadProviderSchedule();
  }

  Map<String, dynamic> getBookingData() {
    return {
      'providerId': providerData?.id,
      'providerData': providerData?.toJson(),
      'selectedServices': getSelectedServices(),
      'selectedTimeSlots': selectedTimeSlots.map((slot) => {
        'day': slot.day,
        'startTime': slot.startTime,
        'endTime': slot.endTime,
        'displayTime': slot.displayTime,
      }).toList(),
      'totalPrice': getTotalPrice(),
      'totalDuration': getTotalDuration(),
    };
  }


// Add this method to fetch reviews
  // Add this method to fetch reviews
  Future<void> fetchReviews() async {
    try {
      isLoadingReviews.value = true;
      // Get provider ID from your existing data
      String providerId = providerData?.user.id ?? '';
      if (providerId.isEmpty) {
        print("❌ Provider ID is empty");
        return;
      }
      print("📡 Fetching reviews for provider: $providerId");
      final response = await ApiService.get(
        "review/$providerId",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );
      print("📡 Reviews Response Status: ${response.statusCode}");
      print("📦 Reviews Response Data: ${response.data}");
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        // Set review data
        review.value = data['reviews'] ?? [];
        averageRating.value = (data['averageRating'] ?? 0.0).toDouble();
        totalReviews.value = data['totalReviews'] ?? 0;

        print("✅ Reviews loaded successfully - Total: ${totalReviews.value}");
        print("✅ Average Rating: ${averageRating.value}");
        print("✅ Reviews List Length: ${review.length}");
      } else {
        print("⚠️ Failed to load reviews");
      }
    } catch (e) {
      print("❌ Error fetching reviews: $e");
    } finally {
      isLoadingReviews.value = false;
    }
  }

  // Getters for UI
  String get providerName => providerData?.user.name ?? "Service Provider";
  String get providerEmail => providerData?.user.email ?? "";
  String get providerContact => providerData?.user.contact ?? "";
  String? get providerImage => providerData?.user.image ?? "assets/images/image_here.png";
  String get providerAbout => providerData?.aboutMe ?? "No information available";
  String get providerLocation => providerData?.primaryLocation ?? "Location not set";
  String get providerDistance => "${providerData?.serviceDistance ?? 0}Km";
  List<String> get spokenLanguages => providerData?.serviceLanguage ?? [];
  String get spokenLanguagesText => spokenLanguages.join(", ");
  bool get isVerified => providerData?.verified ?? false;
  bool get isOnline => providerData?.isOnline ?? false;
  //double get rating => 4.5; // TODO: Get from actual reviews when available
  int get reviewCount => 200; // TODO: Get from actual reviews when available
}