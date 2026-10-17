import 'package:flutter/material.dart';

class CartaoDetalhesFilme extends StatelessWidget {
  final dynamic filme;

  const CartaoDetalhesFilme({super.key, required this.filme});

  Widget _exibirInformacao(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 4.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "$rotulo: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: valor),
          ],
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${filme["titulo"]} (${filme["ano"]})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                Text(
                  " IMDb ${filme["notaImdb"]}/10",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 6.0),
            child: Text(
              filme["sinopse"],
              style: const TextStyle(fontSize: 12),
            ),
          ),
          _exibirInformacao(
            List.from(filme["diretores"]).length > 1 ? "Diretores" : "Diretor",
            List.from(filme["diretores"]).join(", "),
          ),
          _exibirInformacao(
            "Elenco principal",
            List.from(filme["atores"]).join(", "),
          ),
          _exibirInformacao("Lançamento", filme["ano"].toString()),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
