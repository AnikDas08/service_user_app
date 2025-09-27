import 'package:get/get.dart';
import '../../data/model/html_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/enum/enum.dart';

class ServiceProviderController extends GetxController {
  /// Api status check here
  Status status = Status.completed;

  ///  HTML model initialize here
  HtmlModel data = HtmlModel.fromJson({});

  /// Privacy Policy Controller instance create here
  static ServiceProviderController get instance =>
      Get.put(ServiceProviderController());

  /// Privacy Policy Api call here
  getPrivacyPolicyRepo() async {
    return;
    status = Status.loading;
    update();

    var response = await ApiService.get(ApiEndPoint.privacyPolicies);

    if (response.statusCode == 200) {
      data = HtmlModel.fromJson(response.data['data']['attributes']);

      status = Status.completed;
      update();
    } else {
      Utils.errorSnackBar(response.statusCode, response.message);
      status = Status.error;
      update();
    }
  }

  /// Controller on Init here
  @override
  void onInit() {
    getPrivacyPolicyRepo();
    super.onInit();
  }
}
