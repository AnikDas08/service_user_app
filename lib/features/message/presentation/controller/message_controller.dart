import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/message_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/socket/socket_service.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../utils/app_utils.dart';

class MessageController extends GetxController {
  bool isLoading = false;
  bool isMoreLoading = false;
  List<MessageModel> messages = [];
  String chatId = "";
  String image = "";
  String name = "";
  int page = 1;
  Sender? senderdata;


  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();

  static MessageController get instance => Get.put(MessageController());


  Future<void> getMessageRepo() async {
    if (page == 1) {
      isLoading = true;
      update();
    }

    var response = await ApiService.get(
      "${ApiEndPoint.messages}/$chatId?page=$page&limit=15",
    );

    if (response.statusCode == 200) {
      var data = response.data['data'] ?? {};
      if (page == 1) {
        messages.clear();
      }
      for (var messageData in data) {
        MessageModel messageModel = MessageModel.fromJson(messageData);
        senderdata = Sender.fromJson(messageData);
       image=messageModel.sender.image;
       name=messageModel.sender.name;
       messages.add(messageModel!);
      }
      print("kldjksdjdjj 😂😂 $image");

      page++;
      update();
    } else {
      Utils.errorSnackBar(response.statusCode.toString(), response.message);
    }
    isLoading = false;
    update();
  }

  addNewMessage() async {
    var body = {"chat": chatId, "text": messageController.text, "type": "text"};
    messageController.clear();
    await ApiService.post(ApiEndPoint.sendMessage, body: body);
  }

  listenMessage(String chatId) async {
    SocketServices.on('getMessage::$chatId', (data) {
      print("socket data : $data");

      isLoading = true;
      update();

      messages.insert(0, MessageModel.fromJson(data ?? {}));

      isLoading = false;
      update();
    });
  }

  init(String id) {
    print("Call data : $id");
    chatId = id;
    page = 1;
    getMessageRepo();
    listenMessage(chatId);
  }

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      name = Get.arguments['name'] ?? '';
      image = Get.arguments['image'] ?? '';
    }
  }


}
