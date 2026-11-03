import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:get/get.dart';

class SearchResultController extends GetxController {
  String keyword = Get.parameters['keyword'] ?? '';

  final RxMap<SearchType, int> count = {
    for (final type in SearchType.actives) type: -1,
  }.obs;

  RxInt toTopIndex = (-1).obs;

  @override
  void onClose() {
    toTopIndex.close();
    super.onClose();
  }
}
