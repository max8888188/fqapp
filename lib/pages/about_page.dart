import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/home/home_design.dart';

/// About page styled after PiliPlus: centered logo/name header followed by
/// grouped card rows (version, source code, feedback, ...).
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  static const versionText = '1.0.121 (126)';
  static const _logoPixelWidth = 384;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
    // 等第一帧渲染完再弹，避免 context 未就绪
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('小胡提示'),
            content: const Text('欢迎使用小胡短剧APP。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('我知道了'),
              ),
            ],
          );
        },
      );
    });
  }

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
                  cacheWidth: (88 * MediaQuery.devicePixelRatioOf(context))
                      .round()
                      .clamp(88, AboutPage._logoPixelWidth),
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
                '小胡短剧APP',
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
              '仅限个人使用\n请遵守相关法律法规',
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
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: url == null ? null : () => _launchExternalUrl(context, url!),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: theme.textTheme.labelMedium?.copyWith(color: outline),
            ),
      trailing: trailingText != null
          ? Text(trailingText!, style: TextStyle(fontSize: 13, color: outline))
          : url != null
          ? Icon(Icons.arrow_forward, size: 16, color: outline)
          : null,
    );
  }
}

Future<void> _launchExternalUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  var launched = false;
  try {
    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('无法打开链接')));
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();
  static const _sponsorUrl = 'https://sps.yy-gp.com/h3tjk/i.html';
  static const _brandColor = Color(0xFF946CE6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = HomePalette.of(context);
    final brand = palette.eink ? palette.ink : _brandColor;
    final onBrand = palette.eink ? palette.canvas : Colors.white;
    final tint = brand.withValues(
      alpha: palette.eink ? 0.06 : (palette.dark ? 0.20 : 0.10),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: tint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: brand.withValues(alpha: 0.35), width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: brand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.volunteer_activism,
                    size: 20,
                    color: onBrand,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '支持作者',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '如果这个项目对你有帮助，欢迎在打赏支持小胡',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _launchExternalUrl(context, _sponsorUrl),
                icon: const Icon(Icons.favorite, size: 18),
                label: const Text('前往打赏我'),
                style: FilledButton.styleFrom(
                  backgroundColor: brand,
                  foregroundColor: onBrand,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}