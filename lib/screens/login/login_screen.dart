import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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
  final _codeCtrl = TextEditingController();
  Timer? _timer;
  int _countdown = 0;
  bool _agreed = true;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length != 11) {
      _showMessage('请输入正确的手机号');
      return;
    }
    await context.read<AuthProvider>().sendVerificationCode(phone);
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) timer.cancel();
    });
    _showMessage('验证码已发送，模拟环境任意 6 位数字可登录');
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      _showMessage('请先阅读并同意用户协议和隐私政策');
      return;
    }
    final success = await context.read<AuthProvider>().login(
      _phoneCtrl.text.trim(),
      _codeCtrl.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => context.read<AuthProvider>().onboardingDone
              ? const HomeScreen()
              : const OnboardingScreen(),
        ),
      );
    } else {
      _showMessage('验证码错误，请重新输入');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
                      Text('欢迎回来', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text('输入手机号，开启有序的一天', style: theme.textTheme.bodyMedium),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeCtrl,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: const InputDecoration(
                                labelText: '验证码',
                                hintText: '6 位数字',
                                prefixIcon: Icon(Icons.verified_user_rounded),
                                counterText: '',
                              ),
                              validator: (value) =>
                                  value == null || value.trim().length != 6
                                  ? '请输入验证码'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 112,
                            child: OutlinedButton(
                              onPressed: _countdown > 0 ? null : _sendCode,
                              child: Text(
                                _countdown > 0 ? '${_countdown}s' : '获取验证码',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _agreed,
                            activeColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            onChanged: (value) =>
                                setState(() => _agreed = value ?? false),
                          ),
                          Expanded(
                            child: Text(
                              '我已阅读并同意《用户协议》与《隐私政策》',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: auth.isLoading ? null : _login,
                        icon: auth.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.arrow_forward_rounded),
                        label: const Text('开启奇妙旅程'),
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
