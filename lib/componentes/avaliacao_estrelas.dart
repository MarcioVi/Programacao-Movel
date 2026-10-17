import 'package:flutter/material.dart';

class AvaliacaoEstrelas extends StatelessWidget {
  final int nota;
  final double tamanho;
  final void Function(int nota)? onAvaliou;

  const AvaliacaoEstrelas({
    super.key,
    required this.nota,
    this.tamanho = 16,
    this.onAvaliou,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final estrela = Icon(
          index < nota ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber,
          size: tamanho,
        );

        return onAvaliou == null
            ? estrela
            : GestureDetector(
                onTap: () => onAvaliou!(index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: estrela,
                ),
              );
      }),
    );
  }
}
