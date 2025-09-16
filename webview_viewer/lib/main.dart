import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const WebViewViewerApp());
}

class WebViewViewerApp extends StatelessWidget {
  const WebViewViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const WebViewHomePage(),
    );
  }
}

class WebViewHomePage extends StatefulWidget {
  const WebViewHomePage({super.key});

  @override
  State<WebViewHomePage> createState() => _WebViewHomePageState();
}

class _WebViewHomePageState extends State<WebViewHomePage> {
  static const String _defaultUrl = 'https://flutter.dev';

  late final WebViewController _webViewController;
  final TextEditingController _urlController =
      TextEditingController(text: _defaultUrl);
  double _loadingProgress = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _loadingProgress = 0;
          }),
          onProgress: (progress) => setState(() {
            _loadingProgress = progress / 100;
          }),
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
              _loadingProgress = 1;
            });
            if (url.isNotEmpty) {
              _urlController.text = url;
            }
          },
          onUrlChange: (change) {
            final newUrl = change.url;
            if (newUrl != null && newUrl.isNotEmpty) {
              _urlController.text = newUrl;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_defaultUrl));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView Viewer'),
        actions: [
          IconButton(
            tooltip: 'Go back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _webViewController.canGoBack()) {
                await _webViewController.goBack();
              } else {
                _showSnackBar(context, 'Буцах боломжгүй.');
              }
            },
          ),
          IconButton(
            tooltip: 'Go forward',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await _webViewController.canGoForward()) {
                await _webViewController.goForward();
              } else {
                _showSnackBar(context, 'Дараагийн хуудас алга байна.');
              }
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _webViewController.reload(),
          ),
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_new),
            onPressed: () async {
              final url = _normalizeUrl(_urlController.text);
              if (url == null) {
                _showSnackBar(context, 'URL буруу байна.');
                return;
              }
              final uri = Uri.parse(url);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                _showSnackBar(context, 'Гадаад браузер нээгдсэнгүй.');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL оруулна уу',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _loadCurrentUrl(context),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Ачааллах'),
                  onPressed: () => _loadCurrentUrl(context),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.paste),
                  label: const Text('Clipboard'),
                  onPressed: () => _loadFromClipboard(context),
                ),
              ],
            ),
          ),
          if (_isLoading)
            LinearProgressIndicator(value: _loadingProgress == 1 ? null : _loadingProgress),
          Expanded(
            child: WebViewWidget(controller: _webViewController),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCurrentUrl(BuildContext context) async {
    final normalized = _normalizeUrl(_urlController.text);
    if (normalized == null) {
      _showSnackBar(context, 'Та зөв URL оруулна уу.');
      return;
    }
    await _webViewController.loadRequest(Uri.parse(normalized));
  }

  Future<void> _loadFromClipboard(BuildContext context) async {
    final clipboardData = await Clipboard.getData('text/plain');
    final text = clipboardData?.text?.trim();
    if (text == null || text.isEmpty) {
      _showSnackBar(context, 'Clipboard дээр URL алга байна.');
      return;
    }
    _urlController.text = text;
    await _loadCurrentUrl(context);
  }

  String? _normalizeUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final prefixed = trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(prefixed);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return null;
    }
    return uri.toString();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
