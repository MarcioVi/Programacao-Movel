import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcas/componentes/avaliacao_estrelas.dart';
import 'package:marcas/componentes/cartao_comentario.dart';
import 'package:marcas/componentes/cartao_detalhes_filme.dart';
import 'package:marcas/componentes/controles_usuario.dart';
import 'package:marcas/gerenciador_estado.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:toast/toast.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DetalhesState();
  }
}

class _DetalhesState extends State<Detalhes> {
  dynamic _filme;
  List<String> _imagens = [];

  List<dynamic> _comentarios = [];
  bool _carregandoComentarios = false;

  bool _favoritou = false;
  int _notaSelecionada = 0;

  final TextEditingController _controladorNovoComentario =
      TextEditingController();

  late PageController _controladorSlides;
  late int _slideSelecionado;

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);

    _favoritou = estadoApp.favoritou(estadoApp.idFilme);

    _iniciarSlides();
    _carregarFilme();
    _carregarComentarios();
  }

  void _iniciarSlides() {
    _slideSelecionado = 0;
    _controladorSlides = PageController(initialPage: _slideSelecionado);
  }

  Future<dynamic> _acessarFilme(int idFilme) async {
    final String conteudo = await rootBundle.loadString(
      "recursos/jsons/filmes.json",
    );
    final dynamic dicionario = await json.decode(conteudo);

    final filme = dicionario["filmes"].firstWhere((f) => f["_id"] == idFilme);

    return filme;
  }

  void _carregarFilme() {
    _acessarFilme(estadoApp.idFilme).then(
      (filme) => {
        setState(() {
          _filme = filme;
          _imagens = [filme["capa"], ...List<String>.from(filme["cenas"])];
        }),
      },
    );
  }

  Future<List<dynamic>> _acessarComentarios() async {
    final String conteudo = await rootBundle.loadString(
      "recursos/jsons/comentarios.json",
    );
    final dynamic dicionario = await json.decode(conteudo);

    return dicionario["comentarios"];
  }

  void _carregarComentarios() {
    setState(() {
      _carregandoComentarios = true;
    });

    _acessarComentarios().then((comentarios) {
      setState(() {
        _comentarios = comentarios
            .where((c) => c["filmeId"] == estadoApp.idFilme)
            .toList();

        _carregandoComentarios = false;
      });
    });
  }

  Widget _exibirMensagemComentariosInexistentes() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.comment, size: 26),
            Text("não existem comentários", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _exibirComentarios() {
    if (_carregandoComentarios) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: List.generate(_comentarios.length, (index) {
        final comentario = _comentarios[index];
        bool usuarioLogadoComentou =
            estadoApp.usuario != null &&
            estadoApp.usuario!.email == comentario["user"]["email"];

        return SizedBox(
          height: 100,
          child: Dismissible(
            key: ValueKey(comentario["_id"]),
            direction: usuarioLogadoComentou
                ? DismissDirection.endToStart
                : DismissDirection.none,
            background: Container(
              alignment: Alignment.centerRight,
              child: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.delete, color: Colors.red),
              ),
            ),
            child: CartaoComentario(
              comentario: comentario,
              somenteLeitura: !usuarioLogadoComentou,
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: const Text("Deseja apagar o comentário?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("NÃO"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("SIM"),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              setState(() {
                _comentarios.removeAt(index);
              });

              Toast.show(
                "comentário removido",
                duration: Toast.lengthLong,
                gravity: Toast.bottom,
              );
            },
          ),
        );
      }),
    );
  }

  void _adicionarComentario(String conteudo) {
    if (_notaSelecionada == 0) {
      Toast.show(
        "selecione uma nota de 1 a 5 estrelas",
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
      return;
    }

    if (conteudo.trim().isEmpty) {
      Toast.show(
        "digite um comentário",
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
      return;
    }

    setState(() {
      _comentarios.insert(0, {
        "_id": DateTime.now().millisecondsSinceEpoch,
        "filmeId": _filme["_id"],
        "user": {
          "userId": 1,
          "email": estadoApp.usuario?.email,
          "name": estadoApp.usuario?.nome,
        },
        "datetime": DateTime.now().toString(),
        "nota": _notaSelecionada,
        "content": conteudo.trim(),
      });

      _notaSelecionada = 0;
      _controladorNovoComentario.clear();
    });

    FocusScope.of(context).unfocus();

    Toast.show(
      "comentário publicado",
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
    );
  }

  void _onFavoritouDesfavoritou() {
    setState(() {
      _favoritou = !_favoritou;

      if (_favoritou) {
        estadoApp.favoritar(_filme["_id"]);
      } else {
        estadoApp.desfavoritar(_filme["_id"]);
      }
    });

    Toast.show(
      _favoritou
          ? "filme adicionado aos favoritos"
          : "filme removido dos favoritos",
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
    );
  }

  String _mediaUsuarios() {
    if (_comentarios.isEmpty) {
      return "sem avaliações";
    }

    final soma = _comentarios.fold<int>(
      0,
      (total, c) => total + (c["nota"] as int),
    );

    return "${(soma / _comentarios.length).toStringAsFixed(1)}/5 (${_comentarios.length} avaliações)";
  }

  Widget _exibirFilme() {
    bool usuarioLogado = estadoApp.usuario != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Text(
                _filme["titulo"],
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            GestureDetector(
              onTap: () {
                estadoApp.exibirFilmes();
              },
              child: const Icon(Icons.arrow_back, size: 30),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: 230,
            color: Colors.black,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: _imagens.length,
                  controller: _controladorSlides,
                  onPageChanged: (slide) {
                    setState(() {
                      _slideSelecionado = slide;
                    });
                  },
                  itemBuilder: (context, pagePosition) {
                    return Image.asset(
                      "recursos/imagens/${_imagens[pagePosition]}",
                      fit: pagePosition == 0 ? BoxFit.contain : BoxFit.cover,
                    );
                  },
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: ControlesUsuario(
                    filme: _filme,
                    usuarioFavoritou: _favoritou,
                    usuarioLogado: usuarioLogado,

                    onFavoritou: _onFavoritouDesfavoritou,
                    onDesfavoritou: _onFavoritouDesfavoritou,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: PageViewDotIndicator(
              currentItem: _slideSelecionado,
              count: _imagens.length,
              unselectedColor: Colors.black26,
              selectedColor: Colors.deepPurple,
              duration: const Duration(milliseconds: 200),
              boxShape: BoxShape.circle,
            ),
          ),
          CartaoDetalhesFilme(filme: _filme),
          const Center(
            child: Text(
              "Comentários",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Center(
            child: Text(
              "Nota dos usuários: ${_mediaUsuarios()}",
              style: const TextStyle(fontSize: 12),
            ),
          ),
          usuarioLogado
              ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sua nota: ",
                            style: TextStyle(fontSize: 14),
                          ),
                          AvaliacaoEstrelas(
                            nota: _notaSelecionada,
                            tamanho: 32,
                            onAvaliou: (nota) {
                              setState(() {
                                _notaSelecionada = nota;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _controladorNovoComentario,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black87,
                              width: 0.0,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                          hintStyle: const TextStyle(fontSize: 14),
                          hintText: 'Digite aqui seu comentário...',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              _adicionarComentario(
                                _controladorNovoComentario.text,
                              );
                            },
                            child: const Icon(
                              Icons.send,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          _comentarios.isNotEmpty || _carregandoComentarios
              ? _exibirComentarios()
              : _exibirMensagemComentariosInexistentes(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget detalhes = SizedBox.expand(
      child: Container(
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );

    if (_filme != null) {
      detalhes = _exibirFilme();
    }

    return detalhes;
  }
}
