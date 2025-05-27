import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:alfred/alfred.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as html;
import 'package:humps/humps.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

typedef EnrollmentFn =
    void Function(String publicToken, LinkSuccessMetadata metadata);

abstract class PlaidServerHandler {
  static Completer<String> _endpointCompleter = Completer();
  static HttpServer? _serverHandle;
  static bool _initialized = false;

  static Future<String> get endpointFuture => _endpointCompleter.future;

  static Future<void> setup({
    required LinkTokenConfiguration config,
    EnrollmentFn? onToken,
    ValueChanged<LinkExit>? onExit,
    ValueChanged<LinkEvent>? onEvent,
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
                config: ${jsonEncode(config.toJson())},
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
          ...(body["metadata"] as Map<String, dynamic>).camelizeKeys(),
          "institution": {
            ...body["metadata"]["institution"],
            "id": body["metadata"]["institution"]["institution_id"],
          },
        }),
      );

      res.send("OK");
    });

    app.post("/event", (req, res) async {
      final body = jsonDecode(await req.body as String) as Map<String, dynamic>;

      onEvent?.call(LinkEvent.fromJson(body.camelizeKeys()));

      res.send("OK");
    });

    app.delete("/plaid", (req, res) async {
      final body = jsonDecode(await req.body as String) as Map<String, dynamic>;

      onExit?.call(LinkExit.fromJson(body.camelizeKeys()));
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
