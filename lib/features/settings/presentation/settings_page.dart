import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app.dart';
import '../../../core/localization/app_localization.dart';
import '../../auth/presentation/auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _notificationKey = 'settings_notifications';
  static const _recommendationKey = 'settings_recommendations';
  bool _notifications = true;
  bool _recommendations = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifications = prefs.getBool(_notificationKey) ?? true;
      _recommendations = prefs.getBool(_recommendationKey) ?? true;
      _loading = false;
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _chooseLanguage() async {
    final currentLocale = ref.read(appLocaleProvider);
    final selected = await showModalBottomSheet<Locale>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(context.tr('选择语言'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                ),
              ),
              for (final locale in supportedAppLocales)
                RadioListTile<Locale>(
                  value: locale,
                  groupValue: currentLocale,
                  activeColor: AppColors.primary,
                  title: Text(languageNames[localeKey(locale)]!),
                  onChanged: (value) => Navigator.pop(context, value),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    await ref.read(appLocaleProvider.notifier).select(selected);
  }

  Future<void> _clearCache() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('缓存已清理'))));
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('退出登录？')),
        content: Text(context.tr('退出后仍可浏览商品，订单和地址需要重新登录后查看。')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('取消'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.tr('退出'))),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.pop();
  }

  void _showInfo(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('知道了')))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).asData?.value;
    final locale = ref.watch(appLocaleProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('设置'), style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (user != null) ...[
                  _Section(
                    title: context.tr('账号'),
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: context.tr('个人资料'),
                        subtitle: '${user.name} · ${user.email}',
                        onTap: () => _showInfo(context.tr('个人资料'), '${context.tr('姓名')}：${user.name}\n${context.tr('邮箱')}：${user.email}'),
                      ),
                      _SettingsTile(
                        icon: Icons.location_on_outlined,
                        title: context.tr('收货地址'),
                        onTap: () => context.pushNamed('addresses'),
                      ),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: context.tr('账号与安全'),
                        onTap: () => _showInfo(context.tr('账号与安全'), context.tr('密码修改与设备管理功能将在后续版本开放。')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                _Section(
                  title: context.tr('偏好设置'),
                  children: [
                    SwitchListTile.adaptive(
                      secondary: const _TileIcon(Icons.notifications_none_rounded),
                      title: Text(context.tr('消息通知'), style: _titleStyle),
                      subtitle: Text(context.tr('订单状态与优惠消息'), style: _subtitleStyle),
                      value: _notifications,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() => _notifications = value);
                        _setBool(_notificationKey, value);
                      },
                    ),
                    const _Divider(),
                    SwitchListTile.adaptive(
                      secondary: const _TileIcon(Icons.auto_awesome_outlined),
                      title: Text(context.tr('个性化推荐'), style: _titleStyle),
                      subtitle: Text(context.tr('根据浏览偏好推荐商品'), style: _subtitleStyle),
                      value: _recommendations,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() => _recommendations = value);
                        _setBool(_recommendationKey, value);
                      },
                    ),
                    const _Divider(),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: context.tr('语言'),
                      trailingText: languageNames[localeKey(locale)],
                      onTap: _chooseLanguage,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _Section(
                  title: context.tr('其他'),
                  children: [
                    _SettingsTile(icon: Icons.cleaning_services_outlined, title: context.tr('清理缓存'), trailingText: '0 B', onTap: _clearCache),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: context.tr('隐私政策'),
                      onTap: () => _showInfo(context.tr('隐私政策'), context.tr('Mall Go 仅会使用提供购物、订单及配送服务所需的信息。')),
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: context.tr('关于 Mall Go'),
                      trailingText: 'v1.0.0',
                      onTap: () => _showInfo('Mall Go', '多商家购物平台\n版本 1.0.0'),
                    ),
                  ],
                ),
                if (user != null) ...[
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(context.tr('退出登录')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Color(0xFFFFD4D0)),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

const _titleStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
const _subtitleStyle = TextStyle(fontSize: 12, color: AppColors.muted);

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
            child: Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(children: children),
          ),
        ],
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, required this.onTap, this.subtitle, this.trailingText});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: _TileIcon(icon),
        title: Text(title, style: _titleStyle),
        subtitle: subtitle == null ? null : Text(subtitle!, style: _subtitleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null) Text(trailingText!, style: _subtitleStyle),
            const SizedBox(width: 3),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
        onTap: onTap,
      );
}

class _TileIcon extends StatelessWidget {
  final IconData icon;
  const _TileIcon(this.icon);
  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: const Color(0xFFFFEEE9), borderRadius: BorderRadius.circular(11)),
        child: Icon(icon, color: AppColors.primary, size: 21),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, indent: 72, color: Color(0xFFF0F0F3));
}
