# Plaid Universal

Plaid Link for every Flutter platform.

See [Plaid Link documentation](https://plaid.com/docs/link/) to learn how to use it


## Configurations

### Requirements
Fulfill 
- [`flutter_inappwebview` Requirements](https://pub.dev/packages/flutter_inappwebview#requirements)

### Web

Add following to your `web/index.html`'s `<head>` section

```html
<script src="https://cdn.plaid.com/link/v2/stable/link-initialize.js"></script>
```

### macOS

Follow [macOS Setup](https://inappwebview.dev/docs/intro/#setup-macos) to setup `flutter_inappwebview` for macOS.


## Install

Add `plaid_universal` via `pub`:

```bash
$ flutter pub add plaid_universal
```


## Usage

```dart
import 'package:flutter/material.dart';
import 'package:plaid_universal/plaid_universal.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Plaid Universal Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Plaid Universal Demo'),
      );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (context) => const PlaidUniversal(
                    linkToken: "your generated link token",
                    onSuccess: (publicToken, metadata){
                      Navigator.pop(context, publicToken);
                    },
                    onError: (){
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
              print(result);
            },
            child: const Text("Connect"),
          ),
        ),
      );
}
```

## Publisher

[Maxint.com](https://maxint.com)

## License

[MIT](/LICENSE)