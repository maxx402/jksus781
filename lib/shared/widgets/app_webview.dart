import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class AppWebView extends StatefulWidget {
  const AppWebView({
    super.key,
    required this.initialUrl,
    this.loadingMessage,
    this.onPageStarted,
    this.onPageFinished,
    this.onLoadError,
    this.backgroundColor,
  });

  final String initialUrl;
  final String? loadingMessage;
  final ValueChanged<String>? onPageStarted;
  final ValueChanged<String>? onPageFinished;
  final VoidCallback? onLoadError;
  final Color? backgroundColor;

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  bool _isLoading = true;
  double _loadingProgress = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(widget.initialUrl),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: true,
            domStorageEnabled: true,

            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            allowsPictureInPictureMediaPlayback: true,

            cacheEnabled: true,
            clearCache: false,

            supportZoom: true,
            builtInZoomControls: true,
            displayZoomControls: false,

            useHybridComposition: true,
            disableHorizontalScroll: false,
            disableVerticalScroll: false,

            allowsBackForwardNavigationGestures: true,
            mixedContentMode:
                MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,

            useShouldOverrideUrlLoading: true,
            useOnLoadResource: false,
            useOnDownloadStart: false,

            transparentBackground: widget.backgroundColor != null,
          ),
          onWebViewCreated: (controller) {},
          onLoadStart: (controller, url) {
            if (!mounted) return;
            setState(() => _isLoading = true);
            widget.onPageStarted?.call(url?.toString() ?? '');
          },
          onLoadStop: (controller, url) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            widget.onPageFinished?.call(url?.toString() ?? '');
          },
          onProgressChanged: (controller, progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress / 100;
              _isLoading = progress < 100;
            });
          },
          onReceivedError: (controller, request, error) {
            if (!mounted) return;
            widget.onLoadError?.call();
          },
          onReceivedHttpError: (controller, request, errorResponse) {
            if (!mounted) return;
            final statusCode = errorResponse.statusCode;
            if (statusCode != null && statusCode >= 500) {
              widget.onLoadError?.call();
            }
          },
          shouldOverrideUrlLoading:
              (controller, navigationAction) async {
            final uri = navigationAction.request.url;
            if (uri == null) {
              return NavigationActionPolicy.ALLOW;
            }

            final urlString = uri.toString();
            final initialUri = Uri.parse(widget.initialUrl);

            if (urlString == widget.initialUrl) {
              return NavigationActionPolicy.ALLOW;
            }

            if (uri.host == initialUri.host) {
              return NavigationActionPolicy.ALLOW;
            }

            // External links — open in system browser.
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            } catch (_) {}

            return NavigationActionPolicy.CANCEL;
          },
          onCreateWindow:
              (controller, createWindowAction) async {
            final url = createWindowAction.request.url;
            if (url == null) return true;

            final initialUri = Uri.parse(widget.initialUrl);

            if (url.host == initialUri.host) {
              await controller.loadUrl(
                urlRequest: URLRequest(url: url),
              );
              return true;
            }

            try {
              if (await canLaunchUrl(url)) {
                await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              }
            } catch (_) {}

            return true;
          },
        ),
        if (_isLoading)
          Container(
            color: widget.backgroundColor ??
                theme.scaffoldBackgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: _loadingProgress > 0
                              ? _loadingProgress
                              : null,
                          color: theme.colorScheme.primary,
                          strokeWidth: 4,
                        ),
                      ),
                      if (_loadingProgress > 0)
                        Text(
                          '${(_loadingProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  if (widget.loadingMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.loadingMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
