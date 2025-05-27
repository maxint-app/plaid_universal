import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plaid_universal/src/browser/browser_page.dart';
import 'package:plaid_universal/src/plugin/plugin_page.dart';
import 'package:plaid_universal/src/services/server.dart';
import 'package:plaid_universal/src/utils/platform.dart';
import 'package:plaid_universal/src/webview/webview_page.dart';

export 'package:plaid_flutter/plaid_flutter.dart';

class PlaidUniversal extends StatelessWidget {
  final VoidCallback? onExit;
  final EnrollmentFn? onEnrollment;
  final String publicToken;

  const PlaidUniversal({
    super.key,
    required this.publicToken,
    this.onExit,
    this.onEnrollment,
  });

  @override
  Widget build(context) {
    if (kIsWeb || kIsMobile) {
      return PluginPage(
        publicToken: publicToken,
        onExit: onExit,
        onEnrollment: onEnrollment,
      );
    }

    if (kIsLinux) {
      // Windows 10 1809
      return BrowserPage(
        publicToken: publicToken,
        onExit: onExit,
        onEnrollment: onEnrollment,
      );
    }

    return WebviewPage(
      publicToken: publicToken,
      onExit: onExit,
      onEnrollment: onEnrollment,
    );
  }
}
