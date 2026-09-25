import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/languages.dart';
import '../../core/recorder.dart';
import '../../core/session.dart';
import '../widgets.dart';

/// Operator onboards an artisan who may not own a smartphone. The artisan's spoken consent is recorded here.
class OnboardArtisanScreen extends StatefulWidget {
  const OnboardArtisanScreen({super.key});

  @override
  State<OnboardArtisanScreen> createState() => _OnboardArtisanScreenState();
}

class _OnboardArtisanScreenState extends State<OnboardArtisanScreen> {
  final _form = GlobalKey<FormState>();
  final c = {for (final k in ['name', 'name_native', 'village', 'district', 'state', 'craft_type', 'years', 'phone', 'pehchan', 'story'])
    k: TextEditingController()};
  String language = 'hi';
  String? gender = 'female';
  bool attested = false, voice = true, photo = true, location = true, recording = false, busy = false;
  String? consentUploadId;

  Future<void> _recordConsent() async {
    final rec = context.read<VoiceRecorder>();
    final api = context.read<Session>().api;
    if (!recording) {
      await context.voice.speak(context.l.consentBody, lang: language);
      if (await rec.start()) setState(() => recording = true);
      return;
    }
    final r = await rec.stop();
    setState(() => recording = false);
    if (r == null) return;
    final prev = api.actAsArtisanId;
    api.actAsArtisanId = null;
    try {
      final up = await api.post('/capture/uploads', {
        'idempotency_key': 'consent-${DateTime.now().microsecondsSinceEpoch}', 'kind': 'audio',
        'content_type': r.$2 == 'wav' ? 'audio/wav' : 'audio/webm', 'total_size': r.$1.length,
      });
      await api.putBytes('/capture/uploads/${up['upload_id']}', r.$1, {'offset': 0});
      await api.post('/capture/uploads/${up['upload_id']}/complete');
      setState(() => consentUploadId = up['upload_id']);
    } catch (e) {
      if (mounted) spokenError(context, e);
    } finally {
      api.actAsArtisanId = prev;
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || !attested || consentUploadId == null) return;
    final s = context.read<Session>();
    setState(() => busy = true);
    final prev = s.api.actAsArtisanId;
    s.api.actAsArtisanId = null;
    try {
      final a = await s.api.post('/operators/artisans', {
        'name': c['name']!.text,
        'name_native': c['name_native']!.text.isEmpty ? null : c['name_native']!.text,
        'village': c['village']!.text,
        'district': c['district']!.text,
        'state': c['state']!.text,
        'craft_type': c['craft_type']!.text,
        'years_practice': int.tryParse(c['years']!.text),
        'story_text': c['story']!.text.isEmpty ? null : c['story']!.text,
        'pehchan_id': c['pehchan']!.text.isEmpty ? null : c['pehchan']!.text,
        'phone': c['phone']!.text.isEmpty ? null : c['phone']!.text,
        'language': language,
        'gender': gender,
        'attestation': context.l.attestation,
        'consent': {'voice': voice, 'photo': photo, 'location': location},
        'consent_audio_upload_id': consentUploadId,
      });
      await s.selectArtisan(a['id'], a['name']);
      if (mounted) context.pop();
    } catch (e) {
      s.api.actAsArtisanId = prev;
      if (mounted) spokenError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget _f(String key, String label, {bool required = false, TextInputType? keyboard}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: c[key],
          keyboardType: keyboard,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: IconButton(
              icon: Icon(Icons.mic_rounded, color: SS.maroon),
              onPressed: () => context.voice.listen(lang: language, onFinal: (t) => c[key]!.text = t),
            ),
          ),
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? label : null : null,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.onboardArtisan)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          DropdownButtonFormField<String>(
            initialValue: language,
            decoration: InputDecoration(labelText: l.chooseLanguage),
            items: [for (final a in appLanguages) DropdownMenuItem(value: a.code, child: Text('${a.native} · ${a.english}'))],
            onChanged: (v) => setState(() => language = v!),
          ),
          const SizedBox(height: 10),
          _f('name', l.name, required: true),
          _f('name_native', '${l.name} (${languageFor(language).native})'),
          _f('phone', l.phone, keyboard: TextInputType.phone),
          _f('village', l.askVillage),
          _f('district', l.city),
          _f('state', l.state, required: true),
          _f('craft_type', l.askCraft, required: true),
          _f('years', l.askYears, keyboard: TextInputType.number),
          _f('pehchan', 'Pehchan ID'),
          _f('story', l.askStory),
          DropdownButtonFormField<String?>(
            initialValue: gender,
            decoration: InputDecoration(labelText: l.gender),
            items: [
              DropdownMenuItem(value: 'female', child: Text(l.genderFemale)),
              DropdownMenuItem(value: 'male', child: Text(l.genderMale)),
              DropdownMenuItem(value: 'other', child: Text(l.genderOther)),
              DropdownMenuItem(value: 'prefer_not', child: Text(l.genderPreferNot)),
            ],
            onChanged: (v) => gender = v,
          ),
          const SizedBox(height: 16),
          Text(l.consentTitle, style: Theme.of(context).textTheme.titleLarge),
          CheckboxListTile(value: voice, onChanged: (v) => setState(() => voice = v!), title: Text(l.consentVoice)),
          CheckboxListTile(value: photo, onChanged: (v) => setState(() => photo = v!), title: Text(l.consentPhoto)),
          CheckboxListTile(value: location, onChanged: (v) => setState(() => location = v!), title: Text(l.consentLocation)),
          ListTile(
            leading: MicButton(active: recording, onTap: _recordConsent, size: 44),
            title: Text(l.recordConsent),
            subtitle: consentUploadId != null ? Text('✓', style: TextStyle(color: SS.verifiedGreen, fontSize: 20)) : null,
          ),
          CheckboxListTile(value: attested, onChanged: (v) => setState(() => attested = v!), title: Text(l.attestation)),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: FilledButton(
              onPressed: busy || !attested || consentUploadId == null ? null : _save,
              child: Text(l.save),
            ),
          ),
        ]),
      ),
    );
  }
}
