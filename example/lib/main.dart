import 'package:flutter/material.dart';
import 'package:plaid_universal/plaid_universal.dart';

void main() {
  runApp(MaterialApp(title: "Plaid Universal Example", home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TextEditingController _linkTokenController;

  @override
  void initState() {
    super.initState();
    _linkTokenController = TextEditingController();
  }

  @override
  void dispose() {
    _linkTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plaid Universal Example')),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Text('Welcome to the Plaid Universal Example!')),
              TextField(
                controller: _linkTokenController,
                decoration: const InputDecoration(
                  labelText: 'Enter Public Token',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final linkToken = _linkTokenController.text;
                  if (linkToken.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PlaidLinkPage(linkToken: linkToken),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid public token'),
                      ),
                    );
                  }
                },
                child: const Text('Open Plaid Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaidLinkPage extends StatelessWidget {
  final String linkToken;
  const PlaidLinkPage({super.key, required this.linkToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plaid Link')),
      body: PlaidUniversal(
        config: LinkTokenConfiguration(token: linkToken),
        onEnrollment: (publicToken, metadata) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Enrollment successful: $publicToken')),
          );
          debugPrint('Enrollment successful: $publicToken');
          debugPrint('Metadata: ${metadata.description()}');
          Navigator.pop(context, publicToken);
        },
        onEvent: (value) {
          debugPrint('Event received: ${value.name}');
          debugPrint('Event Metadata: ${value.metadata.description()}');
        },
        onExit: (exitMetadata) {
          debugPrint('Link exited: ${exitMetadata.error?.description()}');
          debugPrint('Exit Metadata: ${exitMetadata.metadata.description()}');
          Navigator.pop(context);
        },
      ),
    );
  }
}
