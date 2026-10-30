import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_id/mobile_id.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobileID Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Replace with your MobileID credentials.
  static const _clientId = 'YOUR_CLIENT_ID';
  static const _redirectUri = 'https://your-domain.com/callback';

  final _mobileId = MobileId();
  final _phoneController = TextEditingController(text: '84');

  String _log = 'Ready.';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _mobileId.setEnv(Environment.sandbox);
    _mobileId.setClientId(_clientId);
    _mobileId.setRedirectUri(_redirectUri);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _append(String line) {
    setState(() => _log = '$line\n$_log');
  }

  Future<void> _authenticate() async {
    final phone = _phoneController.text.trim();
    setState(() {
      _busy = true;
      _log = 'Checking coverage for $phone…';
    });

    try {
      final coverage = await _mobileId.checkCoverageWithPhoneNumber(phone);
      _append('Coverage available: ${coverage.isAvailable}');
      if (!coverage.isAvailable) {
        _append('Carrier not supported for this number.');
        return;
      }

      final auth = await _mobileId.doAuthentication(loginHint: phone);
      final code = auth.code;
      if (code != null && code.isNotEmpty) {
        _append('Auth success. code=$code');
        _append('Exchange this code with your backend for tokens.');
      } else {
        _append('Auth finished without an authorization code.');
      }
    } on PlatformException catch (e) {
      _append('Error: ${e.code} - ${e.message}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MobileID Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '84901234567',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _authenticate,
              child: const Text('Authenticate (cellular)'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_log, style: const TextStyle(fontFamily: 'monospace')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
