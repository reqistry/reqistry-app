import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/data/models/project.dart';

class ProjectSelectionTile extends StatelessWidget {
  const ProjectSelectionTile({
    super.key,
    required this.project,
    required this.isSaved,
    required this.onTap,
  });

  final Project project;
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        minTileHeight: 48,
        leading: Icon(
          isSaved ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.circle,
        ),
        title: Text(project.title),
        subtitle: Text(isSaved ? 'Already added' : '${project.apiCount} APIs'),
        onTap: isSaved ? null : onTap,
      );
}
