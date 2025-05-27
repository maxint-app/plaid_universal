import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:alfred/alfred.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as html;
import 'package:plaid_flutter/plaid_flutter.dart';

typedef EnrollmentFn =
    void Function(String publicToken, LinkSuccessMetadata metadata);

abstract class PlaidServerHandler {
  static Completer<String> _endpointCompleter = Completer();
  static HttpServer? _serverHandle;
  static bool _initialized = false;

  static Future<String> get endpointFuture => _endpointCompleter.future;

  static Future<void> setup({
    required String publicToken,
    EnrollmentFn? onToken,
    VoidCallback? onExit,
  }) async {
    if (_initialized) {
      throw Exception("Plaid Server is already set up. Destroy it first");
    }

    final port = Random().nextInt(10000) + 10000;
    final app = Alfred();

    app.all("*", cors(origin: "localhost"));

    app.get("/plaid", (req, res) async {
      res.headers.contentType = ContentType.html;
      final htmlContent = await rootBundle.loadString(
        "packages/plaid_universal/assets/index.html",
      );
      final dom = html.parse(htmlContent);
      dom.head?.append(
        html.Element.html("""
            <script>
              window.ENV = {
                isWebView: true,
                public_token: '$publicToken',
              };
            </script>
            """),
      );
      return dom.outerHtml;
    });

    app.post("/token", (req, res) async {
      final body = jsonDecode(await req.body as String);

      onToken?.call(
        body["public_token"] as String,
        LinkSuccessMetadata.fromJson({
          ...body["metadata"],
          "institution": {
            ...body["metadata"]["institution"],
            "id": body["metadata"]["institution"]["institution_id"],
          },
          "linkSessionId": body["metadata"]["link_session_id"],
          "accounts": (body["metadata"]["accounts"] as List).map(
            (e) => {
              ...e as Map,
              "verificationStatus": e["verification_status"],
            },
          ).toList(),
        }),
      );

      res.send("OK");
    });

    app.delete("/plaid", (req, res) {
      onExit?.call();
      res.send("OK");
    });

    final serverHandle = await app.listen(port);

    _initialized = true;
    _endpointCompleter.complete("http://localhost:$port/plaid");
    _serverHandle = serverHandle;
  }

  static void destroy() {
    if (!_initialized) {
      throw Exception("Plaid Server is not set up");
    }

    _serverHandle?.close(force: true);
    _initialized = false;
    _endpointCompleter = Completer();
  }
}
