import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/project_card.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

void main() {
  testWidgets('project cards fall back to the folder icon for unknown codes',
      (tester) async {
    final createdAt = DateTime(2026);
    final project = Project(
      id: 'project-1',
      title: 'Project',
      iconCodePoint: 65,
      createdAt: createdAt,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 140,
            height: 180,
            child: ProjectCard(project: project),
          ),
        ),
      ),
    );

    expect(
      tester.widget<Icon>(find.byType(Icon)).icon,
      PhosphorIconsRegular.folder,
    );
  });
}
