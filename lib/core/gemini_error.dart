import '../data/ml/gemini_service.dart';
import '../l10n/app_localizations.dart';

/// The user-facing sentence for a [GeminiFailure].
///
/// Single source for every surface that reports one (both capture flows and
/// the Settings key test), so a cause is always described the same way. Every
/// failure used to share one string — "couldn't reach Gemini" — which sent a
/// tester whose key Google was rejecting hunting for a network problem
/// (FEEDBACK.md, 2026-08-27).
String geminiFailureMessage(AppLocalizations l10n, GeminiFailure failure) =>
    switch (failure) {
      GeminiFailure.invalidKey => l10n.geminiErrorInvalidKey,
      GeminiFailure.noAccess => l10n.geminiErrorNoAccess,
      GeminiFailure.modelUnavailable => l10n.geminiErrorModelUnavailable,
      GeminiFailure.quota => l10n.geminiErrorQuota,
      GeminiFailure.busy => l10n.geminiErrorBusy,
      GeminiFailure.network => l10n.geminiErrorNetwork,
      GeminiFailure.notFood => l10n.geminiErrorNotFood,
      GeminiFailure.unknown => l10n.geminiErrorUnknown,
    };
