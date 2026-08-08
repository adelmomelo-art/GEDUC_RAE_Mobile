import 'package:flutter/material.dart';

import '../../../core/theme/fenix_visual_tokens.dart';

/// Sistema visual local da Home Operacional.
///
/// Os tokens ficam restritos ao módulo para que a PV-007B não altere a
/// aparência das demais telas da Plataforma Fênix.
abstract final class HomeVisualTokens {
  /// Paleta cromática aprovada para a Home Operacional.
  static const Color teal = FenixVisualTokens.teal;
  static const Color tealDark = FenixVisualTokens.tealDark;
  static const Color tealLight = FenixVisualTokens.tealLight;

  static const Color orange = FenixVisualTokens.orange;
  static const Color orangeLight = FenixVisualTokens.orangeLight;
  static const Color headerOrangeStart = FenixVisualTokens.headerOrangeStart;
  static const Color headerOrangeEnd = FenixVisualTokens.headerOrangeEnd;

  static const Color blue = FenixVisualTokens.blue;
  static const Color blueLight = FenixVisualTokens.blueLight;
  static const Color navy = FenixVisualTokens.navy;
  static const Color navyLight = FenixVisualTokens.navyLight;
  static const Color charcoal = FenixVisualTokens.charcoal;

  /// Compatibilidade com componentes anteriores à R3.
  static const Color purple = navy;

  static const Color success = FenixVisualTokens.success;
  static const Color warning = FenixVisualTokens.warning;
  static const Color faixitaSurface = FenixVisualTokens.faixitaSurface;
  static const Color canvas = FenixVisualTokens.canvas;
  static const Color surface = FenixVisualTokens.surface;
  static const Color border = FenixVisualTokens.border;
  static const Color text = FenixVisualTokens.text;
  static const Color mutedText = FenixVisualTokens.mutedText;

  static const double space4 = FenixVisualTokens.space4;
  static const double space8 = FenixVisualTokens.space8;
  static const double space12 = FenixVisualTokens.space12;
  static const double space16 = FenixVisualTokens.space16;
  static const double space20 = FenixVisualTokens.space20;
  static const double space24 = FenixVisualTokens.space24;

  static const double radiusSmall = FenixVisualTokens.radiusSmall;
  static const double radiusMedium = FenixVisualTokens.radiusMedium;
  static const double radiusLarge = FenixVisualTokens.radiusLarge;
  static const double minTouchTarget = FenixVisualTokens.minTouchTarget;
  static const double primaryActionMinHeight =
      FenixVisualTokens.primaryActionMinHeight;
  static const double secondaryActionMinHeight =
      FenixVisualTokens.secondaryActionMinHeight;
  static const double kpiMinHeight = FenixVisualTokens.kpiMinHeight;
  static const double recentRaeMinHeight = FenixVisualTokens.recentRaeMinHeight;

  /// Largura útil mínima para manter identidade e ações na mesma linha.
  ///
  /// Abaixo deste limite, o cabeçalho reposiciona a identidade institucional
  /// para uma linha própria, preservando leitura e alvos de toque.
  static const double headerCompactBreakpoint =
      FenixVisualTokens.headerCompactBreakpoint;
  static const double compactBreakpoint = FenixVisualTokens.compactBreakpoint;
  static const double tabletBreakpoint = FenixVisualTokens.tabletBreakpoint;
  static const double wideBreakpoint = FenixVisualTokens.wideBreakpoint;
  static const double contentMaxWidth = FenixVisualTokens.contentMaxWidth;

  static const Duration animationDuration = FenixVisualTokens.animationDuration;

  static List<BoxShadow> get softShadow => FenixVisualTokens.softShadow;
}
