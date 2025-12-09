import 'package:public_apis_desktop_client/app/data/models/category_box_option.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/category_box_controller/extensions/copyCategoryTitle.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/category_box_controller/extensions/share_category.dart';

import '../category_box_controller.dart';

extension CategoryBoxOptionsMixin on CategoryBoxController {
  List<CategoryBoxOption> get options {
    return <CategoryBoxOption>[
      CategoryBoxOption.copy(onTap: copyCategoryTitle),
      CategoryBoxOption.share(onTap: shareCategory),
    ];
  }
}
