import 'package:flutter/material.dart';

/// Contrato visual compartilhado da Plataforma Fênix.
///
/// Os valores foram promovidos do padrão homologado na Home PV-007B. Módulos
/// novos devem consumir estes tokens em vez de declarar cores ou métricas
/// estruturais próprias.
abstract final class FenixVisualTokens {
  static const Color teal = Color(0xFF007C72);
  static const Color tealDark = Color(0xFF005E57);
  static const Color tealLight = Color(0xFFE5F4F2);

  static const Color orange = Color(0xFFC83A0F);
  static const Color orangeLight = Color(0xFFFFEEE6);
  static const Color headerOrangeStart = Color(0xFFF24A0D);
  static const Color headerOrangeEnd = Color(0xFFE33F0D);

  static const Color blue = Color(0xFF0B88C9);
  static const Color blueLight = Color(0xFFE6F3FA);
  static const Color navy = Color(0xFF153E5A);
  static const Color navyLight = Color(0xFFEAF0F4);
  static const Color charcoal = Color(0xFF333333);

  static const Color success = Color(0xFF1E8A32);
  static const Color warning = Color(0xFFB45309);
  static const Color danger = Color(0xFFC62828);
  static const Color faixitaSurface = Color(0xFFFFEEDC);
  static const Color canvas = Color(0xFFFAFAF8);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE3E7E8);
  static const Color text = Color(0xFF202427);
  static const Color mutedText = Color(0xFF5D656A);

  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;

  static const double radiusSmall = 10;
  static const double radiusMedium = 14;
  static const double radiusLarge = 18;
  static const double minTouchTarget = 48;
  static const double primaryActionMinHeight = 96;
  static const double secondaryActionMinHeight = 72;
  static const double kpiMinHeight = 104;
  static const double recentRaeMinHeight = 84;

  static const double compactBreakpoint = 420;
  static const double headerCompactBreakpoint = 520;
  static const double tabletBreakpoint = 720;
  static const double wideBreakpoint = 1100;
  static const double contentMaxWidth = 1240;

  static const Duration animationDuration = Duration(milliseconds: 220);

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.07),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
