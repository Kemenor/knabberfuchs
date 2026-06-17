import 'dart:async';

import 'package:flutter/material.dart';

extension AutoDismissSnackBar on ScaffoldMessengerState {
  /// Like [showSnackBar], but reliably auto-dismisses after the SnackBar's
  /// [SnackBar.duration]. Flutter keeps SnackBars open indefinitely whenever an
  /// accessibility service is active (`MediaQuery.accessibleNavigation`, set by
  /// e.g. password-autofill services); this restores the expected auto-close.
  void showAutoSnackBar(SnackBar snackBar) {
    final controller = showSnackBar(snackBar);
    var closed = false;
    controller.closed.then((_) => closed = true);
    Timer(snackBar.duration, () {
      if (!closed) controller.close();
    });
  }
}
