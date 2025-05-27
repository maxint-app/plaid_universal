import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:plaid_universal/src/services/server.dart';

class WebviewPage extends StatefulWidget {
  final EnrollmentFn? onEnrollment;
  final ValueChanged<LinkExit>? onExit;
  final ValueChanged<LinkEvent>? onEvent;
  final LinkTokenConfiguration config;

  const WebviewPage({
    super.key,
    required this.config,
    this.onEnrollment,
    this.onExit,
    this.onEvent,
  });

  @override
  State<WebviewPage> createState() => WebviewPageState();
}

class WebviewPageState extends State<WebviewPage> {
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    PlaidServerHandler.setup(
      config: widget.config,
      onToken: widget.onEnrollment,
      onExit: widget.onExit,
      onEvent: widget.onEvent,
    );
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    PlaidServerHandler.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PlaidServerHandler.endpointFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        return InAppWebView(
          initialSettings: InAppWebViewSettings(
            isInspectable: false,
          ),
          initialUrlRequest: URLRequest(
            url: WebUri(snapshot.data!),
          ),
        );
      },
    );
  }
}