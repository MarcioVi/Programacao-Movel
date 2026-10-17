import 'package:flutter/material.dart';
import 'package:marcas/gerenciador_estado.dart';

class CartaoFilme extends StatelessWidget {
  final dynamic filme;

  const CartaoFilme({super.key, required this.filme});

  @override
  Widget build(BuildContext context) {
    bool favorito = estadoApp.favoritou(filme["_id"]);

    return GestureDetector(
      onTap: () => {estadoApp.exibirDetalhes(filme["_id"])},
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "recursos/imagens/${filme["capa"]}",
                    fit: BoxFit.cover,
                  ),
                  favorito
                      ? const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.favorite, color: Colors.red),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Text(
                filme["titulo"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(
                    filme["ano"].toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const Spacer(),
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Text(
                      "IMDb ${filme["notaImdb"]}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
