import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:plaid_universal/src/services/server.dart';

class PluginPage extends StatefulWidget {
  final VoidCallback? onExit;
  final EnrollmentFn? onEnrollment;
  final String publicToken;

  const PluginPage({
    super.key,
    required this.publicToken,
    this.onExit,
    this.onEnrollment,
  });

  @override
  State<PluginPage> createState() => _PluginPageState();
}

class _PluginPageState extends State<PluginPage> {
  List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();

    _subscriptions = [
      PlaidLink.onExit.listen((exitMetadata) {
        widget.onExit?.call();
      }),
      PlaidLink.onSuccess.listen((successMetadata) {
        widget.onEnrollment?.call(
          successMetadata.publicToken,
          successMetadata.metadata,
        );
      }),
    ];

    _initLink().then((_) {
      PlaidLink.open();
    });
  }

  Future<void> _initLink() async {
    PlaidLink.create(
      configuration: LinkTokenConfiguration(token: widget.publicToken),
    );
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    PlaidLink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
