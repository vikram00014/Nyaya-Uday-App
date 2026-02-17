import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final TextAlign? textAlign;

  const ExternalLinkText({
    super.key,
    required this.text,
    this.style,
    this.linkStyle,
    this.textAlign,
  });

  Future<void> _open(BuildContext context, String url) async {
    final cleaned = _normalizeUrl(url);
    debugPrint('ExternalLinkText: open url=$url cleaned=$cleaned');
    final uri = Uri.tryParse(cleaned);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid link: $url')),
      );
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    debugPrint('ExternalLinkText: launchUrl ok=$ok uri=$uri');
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open: $cleaned'),
        ),
      );
    }
  }

  Future<void> _onOpen(BuildContext context, LinkableElement link) async {
    var url = link.url;

    if (link is EmailElement && !url.startsWith('mailto:')) {
      url = 'mailto:$url';
    }

    await _open(context, url);
  }

  static String _normalizeUrl(String url) {
    var value = url.trim();

    const trailing = " \t\n\r)]}>\"'.,;:!?";
    while (value.isNotEmpty && trailing.contains(value[value.length - 1])) {
      value = value.substring(0, value.length - 1);
    }

    final lower = value.toLowerCase();
    if (lower.startsWith('mailto:') || lower.startsWith('tel:')) {
      return value;
    }

    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return value;
    }

    if (lower.startsWith('www.')) {
      return 'https://$value';
    }

    // Handles cases like: indiankanoon.org/doc/709776/
    // or: docs.google.com/...
    // We only prefix if it looks like a domain.
    final looksLikeDomain = RegExp(r'^[a-z0-9-]+(\.[a-z0-9-]+)+(/.*)?$')
        .hasMatch(lower);
    if (looksLikeDomain) {
      return 'https://$value';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Linkify(
      text: text,
      onOpen: (link) => _onOpen(context, link),
      style: style,
      linkStyle: linkStyle ??
          const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}
