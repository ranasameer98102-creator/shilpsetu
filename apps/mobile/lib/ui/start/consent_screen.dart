import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../widgets.dart';

/// Explicit, spoken consent for storing voice, photo and location, in the artisan's language (§9.1).
/// Consent choices are passed to the voice-profile step and stored with a timestamp on the server.
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool voice = true, photo = true, location = true;
  String heard = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _read());
  }

  void _read() {
    final l = context.l;
    context.voice.speak('${l.consentTitle}. ${l.consentBody} ${l.sayYesToAgree}');
  }

  static const _yes = ['yes', 'haan', 'han', 'हाँ', 'हां', 'जी', 'ঠিক', 'হ্যাঁ', 'हो', 'होय', 'ஆம்', 'అవును', 'હા', 'ಹೌದು', 'ہاں', 'ହଁ', 'ഉവ്വ്', 'ਹਾਂ'];

  Future<void> _listen() async {
    await context.voice.listen(onFinal: (t) {
      setState(() => heard = t);
      if (_yes.any((w) => t.toLowerCase().contains(w))) _agree();
    });
  }

  void _agree() => context.go('/profile?voice=$voice&photo=$photo&location=$location');

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    Widget row(String label, IconData icon, bool v, ValueChanged<bool> set) => Card(
          child: SwitchListTile(
            value: v,
            onChanged: set,
            secondary: Icon(icon, color: SS.heading, size: 30),
            title: Text(label, style: Theme.of(context).textTheme.titleMedium),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l.consentTitle)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.privacy_tip_rounded, color: SS.ochre, size: 40),
          const SizedBox(width: 12),
          Expanded(child: Text(l.consentBody, style: Theme.of(context).textTheme.bodyLarge)),
          IconButton(onPressed: _read, icon: Icon(Icons.volume_up_rounded, color: SS.heading, size: 30)),
        ]),
        const SizedBox(height: 16),
        row(l.consentVoice, Icons.mic_rounded, voice, (v) => setState(() => voice = v)),
        const SizedBox(height: 10),
        row(l.consentPhoto, Icons.photo_camera_rounded, photo, (v) => setState(() => photo = v)),
        const SizedBox(height: 10),
        row(l.consentLocation, Icons.place_rounded, location, (v) => setState(() => location = v)),
        const SizedBox(height: 24),
        SizedBox(
          height: 64,
          child: FilledButton.icon(onPressed: _agree, icon: const Icon(Icons.check_circle_rounded, size: 28), label: Text(l.iAgree)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: _listen, icon: Icon(Icons.mic_rounded, color: SS.maroon), label: Text(l.sayYesToAgree)),
        if (heard.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('${l.weHeard} “$heard”')),
      ]),
    );
  }
}
