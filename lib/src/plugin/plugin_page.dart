import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:plaid_universal/src/services/server.dart';

class PluginPage extends StatefulWidget {
  final LinkTokenConfiguration config;

  final EnrollmentFn? onEnrollment;
  final ValueChanged<LinkExit>? onExit;
  final ValueChanged<LinkEvent>? onEvent;

  const PluginPage({
    super.key,
    required this.config,
    this.onEnrollment,
    this.onExit,
    this.onEvent,
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
        widget.onExit?.call(exitMetadata);
      }),
      PlaidLink.onSuccess.listen((successMetadata) {
        widget.onEnrollment?.call(
          successMetadata.publicToken,
          successMetadata.metadata,
        );
      }),
      PlaidLink.onEvent.listen((event) {
        widget.onEvent?.call(event);
      }),
    ];

    _initLink().then((_) {
      PlaidLink.open();
    });
  }

  Future<void> _initLink() async {
    await PlaidLink.create(configuration: widget.config);
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
