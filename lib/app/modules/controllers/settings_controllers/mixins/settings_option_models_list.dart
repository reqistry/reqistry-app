import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:public_apis_desktop_client/app/data/models/setting_option_model.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/privacy_controller/privacy_controller.dart';
import 'package:public_apis_desktop_client/app/routes/app_pages.dart';
import 'package:public_apis_desktop_client/app/utils/text_helper_methods.dart';

import '../../share_app_controller/share_app_controller.dart';

mixin SettingsOptionModelsListExtension {
  PrivacyController get privacyController => Get.find<PrivacyController>();
  ShareAppController get shareAppController => Get.find<ShareAppController>();

  List<SettingOptionModel> settingsOptionModelsList() {
    return [
      SettingOptionModel(
        title: "Account".capitalizeAllWordsFirstLetter(),
        icon: Icons.person_outlined,
        optionFunction: () {
          Get.toNamed(Routes.accountSettings);
        },
      ),
      // SettingOptionModel(
      //   title: "categories view".capitalizeAllWordsFirstLetter(),
      //   icon: Icons.grid_view_outlined,
      //   settingsWidget: const ToggleCategoriesView(),
      // ),

      SettingOptionModel(
        title: "privacy".capitalizeAllWordsFirstLetter(),
        icon: Icons.shield_outlined,
        optionFunction: () {
          privacyController.navigateToPrivacyPage();
        },
      ),
      SettingOptionModel(
        title: "App settings".capitalizeAllWordsFirstLetter(),
        icon: Icons.settings_suggest_outlined,
        optionFunction: () {
          Get.toNamed(Routes.appSettings);
        },
      ),
      SettingOptionModel(
        title: "Submit new API".capitalizeAllWordsFirstLetter(),
        icon: Icons.send_outlined,
        optionFunction: () {
          Get.toNamed(Routes.submitApi);
        },
      ),
      SettingOptionModel(
        title: "Contact".capitalizeAllWordsFirstLetter(),
        icon: Icons.chat_bubble_outline,
        optionFunction: () {
          Get.toNamed(Routes.contact);
        },
      ),
      SettingOptionModel(
        title: "share".capitalizeAllWordsFirstLetter(),
        icon: Icons.share_outlined,
        optionFunction: () async {
          shareAppController.shareApp();
        },
      ),
      SettingOptionModel(
        title: "Sign out",
        icon: Icons.logout,
        optionFunction: () async {
          await FirebaseAuth.instance.signOut();
          Get.offAllNamed(Routes.auth);
        },
      ),
    ];
  }
}
