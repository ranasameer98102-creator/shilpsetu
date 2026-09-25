import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../core/session.dart';
import '../widgets.dart';

/// Mobile number + OTP over SMS. On Android the OTP is read automatically (SMS Retriever API).
/// The number can be typed on a big keypad or spoken.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.next});
  final String? next;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool sent = false, busy = false;
  String? demoCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.voice.speak(context.l.enterPhone));
  }

  Future<void> _send() async {
    final s = context.read<Session>();
    setState(() => busy = true);
    try {
      final r = await s.requestOtp(_phone.text);
      setState(() {
        sent = true;
        demoCode = r['dev_otp'] as String?;
      });
      if (!mounted) return;
      context.voice.speak(context.l.enterCode);
      _autoRead();
    } catch (e) {
      if (mounted) spokenError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _autoRead() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final res = await SmartAuth.instance.getSmsWithRetrieverApi(matcher: r'\d{6}');
    final code = res.data?.code;
    if (code != null && mounted) {
      _code.text = code;
      _verify();
    }
  }

  Future<void> _verify() async {
    final s = context.read<Session>();
    setState(() => busy = true);
    try {
      await s.verifyOtp(_phone.text, _code.text.trim());
      if (!mounted) return;
      final next = widget.next ??
          switch (s.role) {
            'artisan' => s.hasProfile ? '/artisan' : '/consent',
            'operator' => '/kiosk',
            _ => '/store',
          };
      context.go(next);
    } catch (e) {
      if (mounted) spokenError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _speakNumber() async {
    await context.voice.listen(onFinal: (t) {
      final digits = t.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) setState(() => _phone.text = digits);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final big = Theme.of(context).textTheme.headlineMedium?.copyWith(letterSpacing: 2, color: SS.ink);
    return Scaffold(
      appBar: AppBar(title: Text(sent ? l.enterCode : l.enterPhone)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          Expanded(child: Text(sent ? l.codeSentTo(_phone.text) : l.enterPhone, style: Theme.of(context).textTheme.titleLarge)),
          SpeakButton(sent ? l.enterCode : l.enterPhone),
        ]),
        const SizedBox(height: 16),
        if (!sent) ...[
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            style: big,
            maxLength: 13,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
            decoration: InputDecoration(
              prefixText: '+91 ',
              suffixIcon: IconButton(onPressed: _speakNumber, tooltip: l.sayNumber, icon: Icon(Icons.mic_rounded, color: SS.maroon)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: busy ? null : _send,
              icon: const Icon(Icons.sms_rounded),
              label: Text(l.sendCode),
            ),
          ),
        ] else ...[
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            style: big,
            maxLength: 6,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              if (v.length == 6) _verify();
            },
          ),
          if (demoCode != null)
            ActionChip(
              avatar: const Icon(Icons.sms_outlined, size: 18),
              label: Text(l.demoCode(demoCode!)),
              onPressed: () {
                _code.text = demoCode!;
                _verify();
              },
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: FilledButton.icon(onPressed: busy ? null : _verify, icon: const Icon(Icons.check_rounded), label: Text(l.verify)),
          ),
          TextButton(onPressed: () => setState(() => sent = false), child: Text(l.back)),
        ],
      ]),
    );
  }
}
