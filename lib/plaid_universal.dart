import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:plaid_universal/src/browser/browser_page.dart';
import 'package:plaid_universal/src/plugin/plugin_page.dart';
import 'package:plaid_universal/src/services/server.dart';
import 'package:plaid_universal/src/utils/platform.dart';
// import 'package:plaid_universal/src/webview/webview_page.dart';

export 'package:plaid_flutter/plaid_flutter.dart';

class PlaidUniversal extends StatelessWidget {
  final LinkTokenConfiguration config;
  final EnrollmentFn? onEnrollment;
  final ValueChanged<LinkExit>? onExit;
  final ValueChanged<LinkEvent>? onEvent;

  const PlaidUniversal({
    super.key,
    required this.config,
    this.onEnrollment,
    this.onExit,
    this.onEvent,
  });

  @override
  Widget build(context) {
    if (kIsWeb || kIsMobile) {
      return PluginPage(
        config: config,
        onExit: onExit,
        onEnrollment: onEnrollment,
        onEvent: onEvent,
      );
    }

    return BrowserPage(
      config: config,
      onExit: onExit,
      onEnrollment: onEnrollment,
      onEvent: onEvent,
    );

    // return WebviewPage(
    //   config: config,
    //   onExit: onExit,
    //   onEnrollment: onEnrollment,
    //   onEvent: onEvent,
    // );
  }
}
