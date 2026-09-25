import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../widgets.dart';

/// Cart + checkout: address, delivery estimate, UPI (payment-gateway sandbox) or Cash on Delivery.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.addProductId});

  /// Added on arrival: "Add to cart" before logging in comes back here once logged in.
  final String? addProductId;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? cart;
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _phone = TextEditingController(), _line = TextEditingController(),
      _city = TextEditingController(), _state = TextEditingController(), _pin = TextEditingController();
  String method = 'upi';
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = context.read<Session>();
    if (!s.canShop) {
      final add = widget.addProductId;
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => ensureShopper(context, add == null ? '/store/cart' : '/store/cart?add=$add', replace: true));
      return;
    }
    try {
      if (widget.addProductId != null && cart == null) {
        await s.api.post('/cart', {'product_id': widget.addProductId, 'quantity': 1});
        if (mounted) spokenMessage(context, context.l.addedToCart);
      }
      final c = await s.api.get('/cart', {'lang': s.language});
      if (mounted) setState(() => cart = Map<String, dynamic>.from(c));
    } catch (e) {
      if (!mounted) return;
      spokenError(context, e);
      if (cart == null) setState(() => cart = {'items': [], 'total': 0}); // never leave a spinner behind
    }
  }

  Future<void> _checkout() async {
    if (!_form.currentState!.validate()) return;
    final s = context.read<Session>();
    final l = context.l;
    setState(() => busy = true);
    try {
      final r = Map<String, dynamic>.from(await s.api.post('/checkout', {
        'address': {
          'name': _name.text, 'phone': _phone.text, 'line1': _line.text, 'city': _city.text, 'state': _state.text,
          'pincode': _pin.text,
        },
        'payment_method': method,
      }));
      await s.setBuyerState(_state.text.trim());
      final pay = r['payment'];
      if (pay != null && pay['checkout']?['provider'] == 'mock') {
        // UPI sandbox: simulate the buyer approving the collect request, then confirm the signature server-side.
        final sim = await s.api.post('/payments/mock/${pay['id']}/pay');
        await s.api.post('/payments/confirm', sim);
      }
      if (!mounted) return;
      spokenMessage(context, l.orderPlacedThanks);
      context.go('/store');
      context.push('/store/orders');
    } catch (e) {
      if (mounted) spokenError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final items = (cart?['items'] as List? ?? []).cast<Map>();
    return Scaffold(
      appBar: AppBar(title: Text(l.cart)),
      body: cart == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(child: Text(l.cartEmpty))
              : Form(
                  key: _form,
                  child: ListView(padding: const EdgeInsets.all(16), children: [
                    for (final it in items)
                      Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: SizedBox(width: 64, height: 64, child: CraftImage(it['thumb'], radius: 12)),
                          title: Text(it['title'] ?? ''),
                          subtitle: Text('${rupees(it['price'])} × ${it['quantity']}\n${it['artisan_name'] ?? ''}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () async {
                              final c = await context.read<Session>().api.delete('/cart/${it['id']}');
                              setState(() => cart = Map<String, dynamic>.from(c));
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text(l.total, style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text(rupees(cart!['total']), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: SS.maroon)),
                    ]),
                    Text(l.shippingIncluded, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 20),
                    Text(l.address, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    _f(_name, l.name),
                    _f(_phone, l.phone, keyboard: TextInputType.phone),
                    _f(_line, l.address),
                    Row(children: [Expanded(child: _f(_city, l.city)), const SizedBox(width: 10), Expanded(child: _f(_state, l.state))]),
                    _f(_pin, l.pincode, keyboard: TextInputType.number, validator: (v) => RegExp(r'^\d{6}$').hasMatch(v ?? '') ? null : '6'),
                    const SizedBox(height: 8),
                    RadioGroup<String>(
                      groupValue: method,
                      onChanged: (v) => setState(() => method = v!),
                      child: Column(children: [
                        RadioListTile(value: 'upi', title: Text(l.payUpi), secondary: const Icon(Icons.qr_code_2_rounded)),
                        RadioListTile(value: 'cod', title: Text(l.cod), secondary: const Icon(Icons.payments_outlined)),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: FilledButton(
                        onPressed: busy ? null : _checkout,
                        style: FilledButton.styleFrom(shape: const StadiumBorder()),
                        child: busy ? const CircularProgressIndicator(color: SS.cream) : Text('${l.placeOrder} · ${rupees(cart!['total'])}'),
                      ),
                    ),
                  ]),
                ),
    );
  }

  Widget _f(TextEditingController c, String label, {TextInputType? keyboard, String? Function(String?)? validator}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label),
          validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? label : null,
        ),
      );
}
