import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/child_provider.dart';
import '../../widgets/design/sticker_widgets.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ageText = _ageCtrl.text.trim();
    final age = ageText.isEmpty ? null : int.parse(ageText);
    final provider = context.read<ChildProvider>();
    final child = await provider.addChild(_nameCtrl.text.trim(), age, null);
    if (!mounted) return;

    if (child == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error ?? '添加宝贝失败，请稍后重试')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已添加 ${child.name}')));
    Navigator.pop(context, child);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ChildProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('添加宝贝')),
      body: OrganicBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                StickerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '宝贝信息',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: '姓名',
                          prefixIcon: Icon(Icons.child_care_rounded),
                        ),
                        validator: (value) {
                          final errors = Child.validate(
                            name: value ?? '',
                            age: _parseAge(_ageCtrl.text),
                          ).where((error) => error.field == 'name');
                          return errors.isEmpty ? null : errors.first.message;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: '年龄',
                          hintText: '可不填',
                          prefixIcon: Icon(Icons.cake_rounded),
                        ),
                        onFieldSubmitted: (_) {
                          if (!isLoading) _save();
                        },
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isNotEmpty && int.tryParse(text) == null) {
                            return '年龄必须是整数';
                          }
                          final errors = Child.validate(
                            name: _nameCtrl.text,
                            age: _parseAge(text),
                          ).where((error) => error.field == 'age');
                          return errors.isEmpty ? null : errors.first.message;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _save,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_rounded),
                          label: const Text('保存宝贝'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static int? _parseAge(String value) {
    final text = value.trim();
    return text.isEmpty ? null : int.tryParse(text);
  }
}
