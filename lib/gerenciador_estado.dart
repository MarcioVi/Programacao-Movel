import 'package:flutter/material.dart';
import 'package:marcas/usuario.dart';

enum EmExibicao { telaFilmes, telaDetalhes }

class GerenciadorEstado extends ChangeNotifier {
  EmExibicao _exibicao = EmExibicao.telaFilmes;
  EmExibicao get exibicao => _exibicao;

  int _idFilme = -1;
  int get idFilme => _idFilme;

  Usuario? _usuario;
  Usuario? get usuario => _usuario;

  final Set<int> _favoritos = {};

  void exibirFilmes() {
    _exibicao = EmExibicao.telaFilmes;

    notifyListeners();
  }

  void exibirDetalhes(int idFilme) {
    _exibicao = EmExibicao.telaDetalhes;
    _idFilme = idFilme;

    notifyListeners();
  }

  void login(Usuario? usuario) {
    _usuario = usuario;
  }

  void logout() {
    _usuario = null;
    _favoritos.clear();
  }

  bool favoritou(int idFilme) {
    return _favoritos.contains(idFilme);
  }

  void favoritar(int idFilme) {
    _favoritos.add(idFilme);
  }

  void desfavoritar(int idFilme) {
    _favoritos.remove(idFilme);
  }
}

late GerenciadorEstado estadoApp;
