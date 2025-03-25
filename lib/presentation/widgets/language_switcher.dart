import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getting_started/core/services/localization_service.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final isVietnamese = localizationService.currentLocale.languageCode == 'vi';

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(context.tr('language')),
      subtitle: Text(
        isVietnamese ? context.tr('vietnamese') : context.tr('english'),
      ),
      trailing: Switch(
        value: !isVietnamese,
        onChanged: (_) {
          localizationService.toggleLocale();
        },
      ),
    );
  }
}
