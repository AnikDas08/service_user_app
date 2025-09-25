import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/message_model.dart';

class ChatController extends GetxController {
  /// Scroll controller for list
  ScrollController scrollController = ScrollController();

  /// Text controller for search
  TextEditingController searchController = TextEditingController();

  /// Full chat list
  List<MessageItem> allMessages = [
    MessageItem(
      name: "John Doe",
      message: "Hi Can I Help You Today?",
      time: "09:02 Am",
      unreadCount: 2,
    ),
    MessageItem(
      name: "John Doe",
      message: "Hey, how are you doing?",
      time: "08:45 Am",
      unreadCount: 1,
    ),
    MessageItem(
      name: "Jane Smith",
      message: "The meeting is scheduled for tomorrow",
      time: "Yesterday",
    ),
    MessageItem(
      name: "Mike Johnson",
      message: "Thanks for your help!",
      time: "Yesterday",
    ),
    MessageItem(
      name: "Sohidul Hasan",
      message: "Hi Can I Help You Today?",
      time: "09:02 Am",
      unreadCount: 2,
    ),
    MessageItem(
      name: "Rafi Islam",
      message: "Hi Can I Help You Today?",
      time: "09:02 Am",
      unreadCount: 2,
    ),
    MessageItem(
      name: "Mizanur Rahman",
      message: "Hi Can I Help You Today?",
      time: "09:02 Am",
      unreadCount: 2,
    ),
    MessageItem(
      name: "Juel Arafat",
      message: "Hi Can I Help You Today?",
      time: "09:02 Am",
      unreadCount: 2,
    ),
    MessageItem(
      name: "Sabir Rahman",
      message: "Hi Can I Help You Today?",
      time: "09:02 Am",
      unreadCount: 2,
    ),
  ];

  /// Filtered messages for search
  List<MessageItem> filteredMessages = [];

  @override
  void onInit() {
    super.onInit();
    filteredMessages = List.from(allMessages);
  }

  /// Search by name
  void searchByName(String query) {
    if (query.isEmpty) {
      filteredMessages = List.from(allMessages);
    } else {
      filteredMessages = allMessages
          .where((msg) =>
          msg.name.toLowerCase().contains(query.trim().toLowerCase()))
          .toList();
    }
    update(); // <-- Update GetBuilder UI
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    filteredMessages = List.from(allMessages);
    update();
  }
}
