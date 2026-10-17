import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcas/autenticador.dart';
import 'package:marcas/componentes/cartao_filme.dart';
import 'package:marcas/gerenciador_estado.dart';
import 'package:marcas/usuario.dart';
import 'package:toast/toast.dart';

class Filmes extends StatefulWidget {
  const Filmes({super.key});

  @override
  State<StatefulWidget> createState() => _FilmesState();
}

class _FilmesState extends State<Filmes> {
  List<dynamic> _filmes = [];
  bool _carregandoFilmes = false;
  String _filtro = "";

  final ScrollController _controladorListaFilmes = ScrollController();
  final TextEditingController _controladorFiltro = TextEditingController();

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);

    _carregarFilmes();
  }

  Future<List<dynamic>> _acessarFilmes() async {
    final String conteudo = await rootBundle.loadString(
      "recursos/jsons/filmes.json",
    );
    final dynamic dicionario = await json.decode(conteudo);

    return dicionario["filmes"];
  }

  void _carregarFilmes() {
    setState(() {
      _carregandoFilmes = true;
    });

    _acessarFilmes().then((filmes) async {
      setState(() {
        if (_filtro.isNotEmpty) {
          _filmes = filmes
              .where(
                (f) => f["titulo"].toLowerCase().contains(
                  _filtro.toLowerCase(),
                ),
              )
              .toList();
        } else {
          _filmes = List<dynamic>.from(filmes);
        }

        _carregandoFilmes = false;
      });
    });
  }

  Future<void> _atualizarFilmes() async {
    _filmes = [];
    _controladorFiltro.text = "";
    _filtro = "";

    _carregarFilmes();
  }

  void _aplicarFiltro(String filtro) {
    _filtro = filtro;
    _filmes.clear();

    _carregarFilmes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 10,
                right: 15,
              ),
              child: TextField(
                controller: _controladorFiltro,
                onSubmitted: (filtro) {
                  _aplicarFiltro(filtro);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Buscar filme...",
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: estadoApp.usuario != null
                ? IconButton(
                    onPressed: () {
                      Autenticador.logout().then(
                        (_) => setState(() {
                          estadoApp.logout();

                          Toast.show(
                            "Você foi desconectado com sucesso",
                            duration: Toast.lengthLong,
                            gravity: Toast.bottom,
                          );
                        }),
                      );
                    },
                    icon: const Icon(Icons.logout),
                  )
                : IconButton(
                    onPressed: () {
                      Autenticador.login().then(
                        (Usuario? usuario) => setState(() {
                          estadoApp.login(usuario);

                          Toast.show(
                            "Bem-vindo(a), ${usuario?.nome}!",
                            duration: Toast.lengthLong,
                            gravity: Toast.bottom,
                          );
                        }),
                      );
                    },
                    icon: const Icon(Icons.login),
                  ),
          ),
        ],
      ),
      body: _carregandoFilmes
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: Colors.deepPurple,
              onRefresh: () => _atualizarFilmes(),
              child: GridView.builder(
                controller: _controladorListaFilmes,
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 0.5,
                ),
                itemCount: _filmes.length,
                itemBuilder: (context, index) {
                  return CartaoFilme(filme: _filmes[index]);
                },
              ),
            ),
    );
  }
}
