import 'package:flutter/material.dart';
import '../../../core/localization/app_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app.dart';
import '../domain/shipping_address.dart';
import 'address_provider.dart';

class AddressPage extends ConsumerWidget {
  final bool selectMode;
  const AddressPage({super.key, this.selectMode = false});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(addressProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(selectMode ? '选择收货地址' : '地址管理'), style: const TextStyle(fontWeight: FontWeight.w900)), backgroundColor: Colors.white),
      body: rows.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_off_outlined, size: 64, color: Colors.black26), SizedBox(height: 12), Text(context.tr('还没有收货地址'))])) : RefreshIndicator(
        onRefresh: ref.read(addressProvider.notifier).refresh,
        child: ListView.separated(padding: const EdgeInsets.all(14), itemCount: rows.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) { final address = rows[i]; return InkWell(
          onTap: selectMode ? () => context.pop(address) : null,
          borderRadius: BorderRadius.circular(18),
          child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text('${address.receiverName}  ${address.phone}', style: const TextStyle(fontWeight: FontWeight.w900))), if (address.isDefault) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFFE5DE), borderRadius: BorderRadius.circular(6)), child: Text(context.tr('默认'), style: TextStyle(color: AppColors.primary, fontSize: 11)))]),
            const SizedBox(height: 9), Text(address.fullAddress, style: const TextStyle(color: AppColors.muted, height: 1.4)),
            if (!selectMode) ...[const Divider(height: 24), Row(children: [if (!address.isDefault) TextButton(onPressed: () => ref.read(addressProvider.notifier).makeDefault(address.id), child: Text(context.tr('设为默认'))), const Spacer(), IconButton(onPressed: () => _showForm(context, ref, address), icon: const Icon(Icons.edit_outlined)), IconButton(onPressed: () => _delete(context, ref, address), icon: const Icon(Icons.delete_outline, color: Colors.redAccent))])],
          ])),
        ); }),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showForm(context, ref, null), backgroundColor: AppColors.primary, foregroundColor: Colors.white, icon: const Icon(Icons.add), label: Text(context.tr('新增地址'))),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ShippingAddress address) async { final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: Text(context.tr('删除地址')), content: Text(context.tr('确定删除 ${address.receiverName} 的地址吗？')), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('取消'))), FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.tr('删除')))])); if (yes == true) await ref.read(addressProvider.notifier).remove(address.id); }

  Future<void> _showForm(BuildContext context, WidgetRef ref, ShippingAddress? old) async {
    final name = TextEditingController(text: old?.receiverName), phone = TextEditingController(text: old?.phone), line = TextEditingController(text: old?.addressLine), city = TextEditingController(text: old?.city), state = TextEditingController(text: old?.state), postal = TextEditingController(text: old?.postalCode); bool isDefault = old?.isDefault ?? false;
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (sheetContext) => StatefulBuilder(builder: (_, setSheetState) => Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 20), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(context.tr(old == null ? '新增收货地址' : '编辑收货地址'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 16),
      _field(name, context.tr('收货人')), const SizedBox(height: 10), _field(phone, context.tr('手机号'), type: TextInputType.phone), const SizedBox(height: 10), _field(line, context.tr('详细地址')), const SizedBox(height: 10), Row(children: [Expanded(child: _field(city, context.tr('城市'))), const SizedBox(width: 10), Expanded(child: _field(state, context.tr('州属')))]), const SizedBox(height: 10), _field(postal, context.tr('邮政编码'), type: TextInputType.number), SwitchListTile(value: isDefault, onChanged: (v) => setSheetState(() => isDefault = v), title: Text(context.tr('设为默认地址')), contentPadding: EdgeInsets.zero),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () async { if ([name, phone, line, city, state, postal].any((c) => c.text.trim().isEmpty)) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('请填写完整地址')))); return; } await ref.read(addressProvider.notifier).save(id: old?.id, receiverName: name.text, phone: phone.text, addressLine: line.text, city: city.text, stateName: state.text, postalCode: postal.text, isDefault: isDefault); if (sheetContext.mounted) Navigator.pop(sheetContext); }, child: Text(context.tr('保存')))),
    ])))));
    for (final controller in [name, phone, line, city, state, postal]) { controller.dispose(); }
  }
  Widget _field(TextEditingController c, String label, {TextInputType? type}) => TextField(controller: c, keyboardType: type, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
}
