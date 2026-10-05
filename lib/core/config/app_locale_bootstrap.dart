import 'package:intl/date_symbol_data_local.dart';

abstract final class AppLocaleBootstrap {
  static Future<void> initialize() => initializeDateFormatting('pt_BR');
}
