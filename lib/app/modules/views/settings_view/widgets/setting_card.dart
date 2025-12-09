import 'package:flutter/material.dart';
import 'package:public_apis_desktop_client/app/utils/text_helper_methods.dart';

import '../../../../data/models/setting_option_model.dart';

class SettingsCard extends StatelessWidget {
  final SettingOptionModel settingOption;

  const SettingsCard({
    Key? key,
    required this.settingOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              color: theme.primaryColor.withOpacity(.2),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Icon(
                    settingOption.icon,
                    size: 27.5,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Text(
            settingOption.title.capitalizeAllWordsFirstLetter(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 18,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
