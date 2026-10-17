import 'package:flutter/material.dart';
import 'package:marcas/gerenciador_estado.dart';
import 'package:marcas/telas/detalhes.dart';
import 'package:marcas/telas/filmes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const CineAcervo());
}

class CineAcervo extends StatelessWidget {
  const CineAcervo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GerenciadorEstado(),
      child: MaterialApp(
        title: 'CineAcervo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const TelaPrincipal(),
      ),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  @override
  Widget build(BuildContext context) {
    estadoApp = context.watch<GerenciadorEstado>();

    Widget tela = const SizedBox.shrink();
    if (estadoApp.exibicao == EmExibicao.telaFilmes) {
      tela = Filmes();
    } else if (estadoApp.exibicao == EmExibicao.telaDetalhes) {
      tela = Detalhes();
    }

    return tela;
  }
}
