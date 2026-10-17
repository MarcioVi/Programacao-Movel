import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marcas/componentes/avaliacao_estrelas.dart';

class CartaoComentario extends StatelessWidget {
  final dynamic comentario;
  final bool somenteLeitura;

  const CartaoComentario({
    super.key,
    required this.comentario,
    required this.somenteLeitura,
  });

  @override
  Widget build(BuildContext context) {
    String dataFormatada = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(DateTime.parse(comentario["datetime"]));

    return Card(
      color: somenteLeitura ? Colors.white54 : Colors.deepPurple[50],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 6, right: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    comentario["user"]["name"],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AvaliacaoEstrelas(nota: comentario["nota"] ?? 0),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                comentario["content"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, right: 6.0),
            child: Container(
              alignment: Alignment.bottomRight,
              child: Text(dataFormatada, style: const TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}
