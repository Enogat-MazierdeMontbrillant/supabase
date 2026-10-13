import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthentificationService {
  final Logger logger = Logger();

  Future<void> login({required String login, required String pwd}) async {
    final response = await Supabase.instance.client.auth
        .signInWithPassword(email: login, password: pwd);
    final session = response.session;
    if (response.user == null || session == null) {
      throw const AuthException('La connexion n’a retourné aucune session.');
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('token', session.accessToken);
    await preferences.setString('email', response.user!.email ?? login);
    logger.i('Connexion réussie pour ${response.user!.email ?? login}.');
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
    await preferences.remove('email');
  }
}
