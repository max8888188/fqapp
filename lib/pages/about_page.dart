import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/home/home_design.dart';

/// About page styled after PiliPlus: centered logo/name header followed by
/// grouped card rows (version, source code, feedback, ...).
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  /// Display version, kept in lockstep with pubspec.yaml's
  /// `version`. Without a package_info dependency the value is
  /// static, so test/about_version_test.dart parses the pubspec and fails the
  /// build check when the two drift apart after a version bump.
  static const versionText = '1.0.121 (126)';

  /// Pixel width of the bundled logo (assets/images/app_logo.webp). The logo
  /// is displayed at 96dp, so it only needs re-decoding above 4× DPI; clamping
  /// to the asset's real width keeps a high-DPI device from asking the decoder
  /// to upscale a surface the asset does not have.
  static const _logoPixelWidth = 384;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(title: const Text('小胡'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: HomePalette.accent.withValues(alpha: 0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/app_logo.webp',
                  width: 88,
                  height: 88,
                  // Decode at the display size rather than the whole 384²
                  // surface, which would hold ~590 KB in the image cache for a
                  // 96dp logo.
                  cacheWidth: (88 * MediaQuery.devicePixelRatioOf(context))
                      .round()
                      .clamp(88, _logoPixelWidth),
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              Text(
                'fqapp',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '小说 / 短剧 / 漫剧 / 漫画 / 小胡短剧客户端',
                textAlign: TextAlign.center,
                style: TextStyle(color: outline, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _AboutCard(
            children: [
              _AboutRow(
                icon: Icons.commit_outlined,
                title: '当前版本',
                trailingText: AboutPage.versionText,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _AboutCard(
            children: [
              _AboutRow(
                icon: Icons.info_outline,
                title: '小胡介绍',
                subtitle: '进程内 Rust 核心运行，签名与解密在手机本地完成',
              ),
              Divider(height: 1, indent: 68),
              _AboutRow(
                icon: Icons.code,
                title: 'Source Code',
                subtitle: 'github.com/max8888188/fqapp',
                url: 'https://github.com/max8888188/fqapp',
              ),
              Divider(height: 1, indent: 68),
              _AboutRow(
                icon: Icons.feedback_outlined,
                title: '小胡音乐',
                subtitle: '前往小胡音乐下载',
                url: 'https://sps.yy-gp.com/hhxci/i.html',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _SupportCard(),
          const SizedBox(height: 28),
          Center(
            child: Text(
              '仅限个人学习研究使用\n请遵守相关法律法规',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: outline, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final List<Widget> children;
  const _AboutCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final String? url;

  const _AboutRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.url,
  });

  Future<void> _onTap() async {
    if (url == null) return;
    final uri = Uri.parse(url!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: url != null ? _onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            if (url != null)
              Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AboutCard(children: [
      _AboutRow(
        icon: Icons.favorite_outline,
        title: '支持作者',
        subtitle: '欢迎Star支持项目',
        url: 'https://github.com/max8888188/fqapp',
      ),
    ]);
  }
}
