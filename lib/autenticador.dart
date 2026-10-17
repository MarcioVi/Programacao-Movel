import 'package:marcas/usuario.dart';

class Autenticador {
  static Future<Usuario?> login() async {
    return Usuario("Márcio Vinicius", "marciovinicius3672@gmail.com");
  }

  static Future<Usuario?> recuperarUsuario() async {
    return Usuario("Márcio Vinicius", "marciovinicius3672@gmail.com");
  }

  static Future<void> logout() async {}
}
