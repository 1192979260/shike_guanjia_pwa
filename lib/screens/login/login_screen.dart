import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/http/api_client.dart';
import '../../themes/app_theme.dart';
import '../../widgets/design/sticker_widgets.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _agreed = true;
  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      _showMessage('请先阅读并同意用户协议和隐私政策');
      return;
    }
    try {
      final auth = context.read<AuthProvider>();
      final phone = _phoneCtrl.text.trim();
      final password = _passwordCtrl.text;
      final success = _isRegistering
          ? await auth.register(phone, password)
          : await auth.login(phone, password);
      if (!mounted) return;
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => auth.onboardingDone
                ? const HomeScreen()
                : const OnboardingScreen(),
          ),
        );
      } else {
        _showMessage(_isRegistering ? '注册失败，请检查手机号或密码' : '手机号或密码错误');
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(_messageForApiError(error));
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _messageForApiError(ApiException error) {
    if (error.code == 'UNAUTHORIZED') return '手机号或密码错误';
    if (error.code == 'BAD_REQUEST' && _isRegistering) {
      return error.message == 'Phone already registered'
          ? '该手机号已注册'
          : '请检查手机号或密码';
    }
    return error.message;
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _confirmPasswordCtrl.clear();
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: OrganicBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
            children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: AppTheme.sage,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.moss.withValues(alpha: 0.16),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.child_care_rounded,
                        color: AppTheme.textInverse,
                        size: 42,
                      ),
                    ),
                    const Positioned(
                      right: -8,
                      top: -8,
                      child: StickerIcon(
                        icon: Icons.star_rounded,
                        backgroundColor: AppTheme.accent,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Lesson Butler',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '让课程管理变得如拆开贴纸书般轻松',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 34),
              StickerCard(
                rotated: true,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isRegistering ? '创建账号' : '欢迎回来',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isRegistering ? '用手机号和密码创建你的家庭账号' : '输入手机号和密码，开启有序的一天',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        decoration: const InputDecoration(
                          labelText: '手机号码',
                          hintText: '请输入 11 位手机号',
                          prefixIcon: Icon(Icons.phone_iphone_rounded),
                          counterText: '',
                        ),
                        validator: (value) =>
                            value == null || value.trim().length != 11
                            ? '请输入正确的手机号'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: _isRegistering
                            ? TextInputAction.next
                            : TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: '密码',
                          hintText: '至少 6 位',
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword ? '显示密码' : '隐藏密码',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                          ),
                        ),
                        validator: (value) => value == null || value.length < 6
                            ? '请输入至少 6 位密码'
                            : null,
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _isRegistering
                            ? Padding(
                                key: const ValueKey('confirm-password'),
                                padding: const EdgeInsets.only(top: 14),
                                child: TextFormField(
                                  controller: _confirmPasswordCtrl,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    labelText: '确认密码',
                                    hintText: '再次输入密码',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                    ),
                                    suffixIcon: IconButton(
                                      tooltip: _obscureConfirmPassword
                                          ? '显示密码'
                                          : '隐藏密码',
                                      onPressed: () => setState(
                                        () => _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                      ),
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                      ),
                                    ),
                                  ),
                                  validator: (value) =>
                                      value != _passwordCtrl.text
                                      ? '两次输入的密码不一致'
                                      : null,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: auth.isLoading ? null : _toggleMode,
                          child: Text(
                            _isRegistering ? '已有账号，去登录' : '没有账号，立即注册',
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _isRegistering
                            ? Row(
                                key: const ValueKey('agreement'),
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _agreed,
                                    activeColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    onChanged: (value) => setState(
                                      () => _agreed = value ?? false,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '我已阅读并同意《用户协议》与《隐私政策》',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(height: _isRegistering ? 12 : 18),
                      ElevatedButton.icon(
                        onPressed: auth.isLoading ? null : _submit,
                        icon: auth.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _isRegistering
                                    ? Icons.person_add_alt_1_rounded
                                    : Icons.arrow_forward_rounded,
                              ),
                        label: Text(_isRegistering ? '注册并进入' : '登录'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                '其他登录方式',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Center(
                child: IconButton.filledTonal(
                  onPressed: () => _showMessage('指纹登录将在绑定账号后可用'),
                  icon: const Icon(Icons.fingerprint_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
