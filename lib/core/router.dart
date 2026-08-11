import 'package:flutter/material.dart';

import '../ui/about/about_view.dart';
import '../ui/backup/backup_view.dart';
import '../ui/cards/cards_view.dart';
import '../ui/dashboard/dashboard_view.dart';
import '../ui/dashboard/subject_detail_view.dart';
import '../ui/debug/time_travel_view.dart';
import '../ui/import/import_view.dart';
import '../ui/mock_interview/mock_interview_view.dart';
import '../ui/session/session_view.dart';

abstract final class AppRoutes {
  static const dashboard = '/';
  static const session = '/sessao';
  static const import = '/importar';
  static const cards = '/cartoes';
  static const backup = '/backup';
  static const mockInterview = '/simulado';
  static const about = '/sobre';
  static const subject = '/assunto';

  /// Hidden on purpose: no link in the navigation points here.
  static const debug = '/debug';
}

/// The route is one of the two places allowed to resolve `get_it` — the
/// ViewModel never does it itself, so tests can inject fakes.
Route<Object?> onGenerateRoute(RouteSettings settings) {
  Widget page() => switch (settings.name) {
        AppRoutes.session => const SessionView(),
        AppRoutes.import => const ImportView(),
        AppRoutes.cards => const CardsView(),
        AppRoutes.backup => const BackupView(),
        AppRoutes.mockInterview => const MockInterviewView(),
        AppRoutes.about => const AboutView(),
        AppRoutes.subject =>
          SubjectDetailView(subject: settings.arguments! as String),
        AppRoutes.debug => const TimeTravelView(),
        _ => const DashboardView(),
      };

  return MaterialPageRoute<Object?>(builder: (_) => page(), settings: settings);
}
