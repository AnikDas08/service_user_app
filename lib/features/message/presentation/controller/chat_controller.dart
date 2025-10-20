import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/chat_list_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/socket/socket_service.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/enum/enum.dart';

class ChatControllers extends GetxController {
  /// Api status check here
  Status status = Status.completed;

  /// Chat more Data Loading Bar
  bool isMoreLoading = false;

  TextEditingController searchController = TextEditingController();

  /// page no here
  int page = 1;

  /// Chat List here
  List chats = [];

  /// Chat Scroll Controller
  ScrollController scrollController = ScrollController();

  /// Chat Controller Instance create here
  static ChatControllers get instance => Get.put(ChatControllers());
  ChatModel? chatModel;
  String name = "";
  String image = "";

  /// Chat More data Loading function
  Future<void> moreChats() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      isMoreLoading = true;
      update();
      await getChatRepo();
      isMoreLoading = false;
      update();
    }
  }

  /// Chat data Loading function
  Future<void> getChatRepo() async {
    if (page == 1) {
      status = Status.loading;
      update();
    }

    var response = await ApiService.get("${ApiEndPoint.chats}?page=$page");

    if (response.statusCode == 200) {
      var data = response.data['data'] ?? [];

      for (var item in data) {
        chats.add(ChatModel.fromJson(item));
        name = item['participant']['name'];
        image = item['participant']['image'];
      }

      page = page + 1;
      status = Status.completed;
      update();
    } else {
      Utils.errorSnackBar(response.statusCode.toString(), response.message);
      status = Status.error;
      update();
    }
  }

  /// Chat data Update  Socket listener
  listenChat() async {
    SocketServices.on("update-chatlist::${LocalStorage.userId}", (data) {
      page = 1;
      chats.clear();

      for (var item in data) {
        chats.add(ChatModel.fromJson(item));
      }

      status = Status.completed;
      update();
    });
  }

  /// Controller on Init¬
  @override
  void onInit() {
    getChatRepo();
    super.onInit();
  }
}
