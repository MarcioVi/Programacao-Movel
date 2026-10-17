import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ControlesUsuario extends StatelessWidget {
  final dynamic filme;

  final bool usuarioLogado;
  final bool usuarioFavoritou;

  final void Function() onFavoritou;
  final void Function() onDesfavoritou;

  const ControlesUsuario({
    super.key,

    required this.filme,
    required this.usuarioLogado,
    required this.usuarioFavoritou,

    required this.onFavoritou,
    required this.onDesfavoritou,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        usuarioLogado
            ? IconButton(
                onPressed: () {
                  if (usuarioFavoritou) {
                    onDesfavoritou();
                  } else {
                    onFavoritou();
                  }
                },
                icon: Icon(
                  usuarioFavoritou ? Icons.favorite : Icons.favorite_border,
                ),
                color: Colors.red,
                iconSize: 32,
              )
            : const SizedBox.shrink(),
        IconButton(
          onPressed: () {
            final texto =
                '${filme["titulo"]} (${filme["ano"]}) - nota IMDb ${filme["notaImdb"]}. Confira no CineAcervo!';
            SharePlus.instance.share(
              ShareParams(title: "CineAcervo", text: texto),
            );
          },
          icon: const Icon(Icons.share),
          color: Colors.white,
          iconSize: 26,
        ),
      ],
    );
  }
}
