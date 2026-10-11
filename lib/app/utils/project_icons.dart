import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

const projectIconChoices = <IconData>[
  PhosphorIconsRegular.folder,
  PhosphorIconsRegular.star,
  PhosphorIconsRegular.code,
  PhosphorIconsRegular.cloud,
  PhosphorIconsRegular.lock,
  PhosphorIconsRegular.database,
  PhosphorIconsRegular.globeHemisphereWest,
  PhosphorIconsRegular.envelope,
  PhosphorIconsRegular.chatCircleText,
  PhosphorIconsRegular.camera,
  PhosphorIconsRegular.musicNote,
  PhosphorIconsRegular.videoCamera,
  PhosphorIconsRegular.shoppingCart,
  PhosphorIconsRegular.creditCard,
  PhosphorIconsRegular.bank,
  PhosphorIconsRegular.truck,
  PhosphorIconsRegular.forkKnife,
  PhosphorIconsRegular.gameController,
  PhosphorIconsRegular.airplaneTilt,
  PhosphorIconsRegular.bed,
  PhosphorIconsRegular.wrench,
  PhosphorIconsRegular.graduationCap,
  PhosphorIconsRegular.hospital,
  PhosphorIconsRegular.pawPrint,
  PhosphorIconsRegular.treeEvergreen,
  PhosphorIconsRegular.sun,
  PhosphorIconsRegular.robot,
  PhosphorIconsRegular.currencyBtc,
  PhosphorIconsRegular.chartBar,
  PhosphorIconsRegular.bell,
];

IconData projectIconForCodePoint(int codePoint) {
  for (final icon in projectIconChoices) {
    if (icon.codePoint == codePoint) return icon;
  }
  return PhosphorIconsRegular.folder;
}
