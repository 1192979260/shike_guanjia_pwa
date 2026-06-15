import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/providers/providers.dart';
import 'package:shike_guanjia/widgets/design/sticker_widgets.dart';

class FamilySharingScreen extends StatefulWidget {
  const FamilySharingScreen({super.key});

  @override
  State<FamilySharingScreen> createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends State<FamilySharingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().loadFamily();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyProvider>();
    final currentUserId = provider.currentUserId;
    return Scaffold(
      appBar: AppBar(title: const Text('家庭共享')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                provider.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            StickerCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.family_restroom_rounded),
                title: Text(provider.family?.name ?? '暂无家庭信息'),
                subtitle: Text('当前 ${provider.members.length}/2 位成员'),
                trailing: provider.sessionInvalidated
                    ? TextButton(
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                        child: const Text('重新登录'),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('家庭成员', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (provider.members.isEmpty)
              const StickerCard(child: Text('暂无成员'))
            else
              ...provider.members.map(
                (member) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StickerCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(_relationInitial(member.relation)),
                      ),
                      title: Text(_memberTitle(member, currentUserId)),
                      subtitle: Text(_memberSubtitle(member)),
                      trailing: IconButton(
                        tooltip: '移除成员',
                        onPressed: provider.isMutating
                            ? null
                            : () => _confirmRemove(context, member),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            if (provider.canAddMember)
              ElevatedButton.icon(
                onPressed: provider.isMutating
                    ? null
                    : () => _showAddSheet(context),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('添加家庭成员'),
              )
            else
              const StickerCard(child: Text('当前家庭最多支持 2 位成员')),
          ],
        ],
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context) async {
    final familyProvider = context.read<FamilyProvider>();
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddFamilyMemberSheet(familyProvider: familyProvider),
    );
    if (added != true || !context.mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      familyProvider.loadFamily();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('成员已添加')));
  }

  Future<void> _confirmRemove(BuildContext context, FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('移除家庭成员？'),
        content: Text('确认移除 ${member.displayName ?? member.userId} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final removingCurrentUser =
        member.userId == context.read<FamilyProvider>().currentUserId;
    final ok = await context.read<FamilyProvider>().removeMember(member.id);
    if (ok && context.mounted) {
      if (removingCurrentUser) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('成员已移除')));
    }
  }
}

class _AddFamilyMemberSheet extends StatefulWidget {
  const _AddFamilyMemberSheet({required this.familyProvider});

  final FamilyProvider familyProvider;

  @override
  State<_AddFamilyMemberSheet> createState() => _AddFamilyMemberSheetState();
}

class _AddFamilyMemberSheetState extends State<_AddFamilyMemberSheet> {
  final _phoneController = TextEditingController();
  var _relation = FamilyRelation.father;
  var _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final ok = await widget.familyProvider.addMember(
      _phoneController.text,
      _relation,
      refresh: false,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.familyProvider.error ?? '添加成员失败，请稍后重试')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('添加成员', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: '手机号',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<FamilyRelation>(
            initialValue: _relation,
            decoration: const InputDecoration(labelText: '关系'),
            items: FamilyRelation.values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(_relationLabel(item)),
                  ),
                )
                .toList(),
            onChanged: _isSubmitting
                ? null
                : (value) {
                    if (value != null) setState(() => _relation = value);
                  },
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: Text(_isSubmitting ? '添加中...' : '确认添加'),
          ),
        ],
      ),
    );
  }
}

String _relationLabel(FamilyRelation relation) {
  switch (relation) {
    case FamilyRelation.mother:
      return '宝妈';
    case FamilyRelation.father:
      return '爸爸';
  }
}

String _relationInitial(FamilyRelation relation) {
  switch (relation) {
    case FamilyRelation.mother:
      return '妈';
    case FamilyRelation.father:
      return '爸';
  }
}

String _memberTitle(FamilyMember member, String? currentUserId) {
  final name = member.displayName?.trim();
  if (name != null && name.isNotEmpty) return name;
  if (member.userId == currentUserId) return '当前账号';
  return '家庭成员';
}

String _memberSubtitle(FamilyMember member) {
  return _relationLabel(member.relation);
}
