import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class GuestNewsScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const GuestNewsScreen({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<GuestNewsScreen> createState() => _GuestNewsScreenState();
}

class _GuestNewsScreenState extends State<GuestNewsScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // ✅ Ensure a platform implementation is set (fixes WebViewPlatform.instance null)

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse('https://runningclubtunis.blogspot.com/'));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("RCT News"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
