import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/authentification_service.dart';
import 'splash_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.supabaseConfigured = true});
  static const route = '/login';

  final bool supabaseConfigured;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthentificationService _auth = AuthentificationService();
  bool _loading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Saisissez votre adresse e-mail et votre mot de passe.');
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.login(login: email, pwd: _passwordController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Connexion réussie.'),
        backgroundColor: Colors.green,
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashPage(email: email)),
      );
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (error) {
      if (mounted) _showMessage('Connexion impossible : $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.person, size: 100),
              const SizedBox(height: 16),
              const Text('Bienvenue!'),
              if (!widget.supabaseConfigured) ...[
                const SizedBox(height: 16),
                const Text(
                  'Supabase n’est pas configuré. Lancez l’application avec '
                  'SUPABASE_URL et SUPABASE_PUBLISHABLE_KEY (ou '
                  'SUPABASE_ANON_KEY, selon votre projet) (voir README.md).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Login',
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Mot de passe',
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    _loading || !widget.supabaseConfigured ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
