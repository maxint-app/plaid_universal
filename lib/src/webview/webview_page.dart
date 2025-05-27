import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:plaid_universal/src/services/server.dart';

class WebviewPage extends StatefulWidget {
  final VoidCallback? onExit;
  final EnrollmentFn? onEnrollment;
  final String publicToken;

  const WebviewPage({
    super.key,
    required this.publicToken,
    this.onExit,
    this.onEnrollment,
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
      publicToken: widget.publicToken,
      onToken: widget.onEnrollment,
      onExit: widget.onExit,
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