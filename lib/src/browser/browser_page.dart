import 'package:flutter/material.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:plaid_universal/src/services/server.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BrowserPage extends StatefulWidget {
  final LinkTokenConfiguration config;
  final EnrollmentFn? onEnrollment;
  final ValueChanged<LinkExit>? onExit;
  final ValueChanged<LinkEvent>? onEvent;

  const BrowserPage({
    super.key,
    required this.config,
    this.onExit,
    this.onEnrollment,
    this.onEvent,
  });

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  String? endpoint;

  @override
  void initState() {
    super.initState();
    _asyncInitState();
  }

  Future<void> _asyncInitState() async {
    await PlaidServerHandler.setup(
      config: widget.config,
      onToken: widget.onEnrollment,
      onExit: widget.onExit,
      onEvent: widget.onEvent,
    );
    endpoint = await PlaidServerHandler.endpointFuture;
    if (context.mounted) {
      setState(() {});
    }

    await launchUrlString(endpoint!);
  }

  @override
  void dispose() {
    PlaidServerHandler.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("You'll be redirected to your default browser."),
          if (endpoint != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.grey[850] : Colors.grey[200],
              ),
              child: Text(
                endpoint!,
                style: const TextStyle(color: Colors.blue),
              ),
            )
          else
            const CircularProgressIndicator.adaptive(),
        ],
      ),
    );
  }
}
