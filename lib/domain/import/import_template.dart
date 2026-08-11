/// Text of the "copiar template" button (H15).
///
/// Pasted into an AI chat without any editing, it has to produce something the
/// parser reads with no issues in the preview. The `id:` field is already
/// there on purpose: it is what preserves a card's history on re-import.
///
/// The subject names are placeholders. TODO(open point): the five subjects are
/// the single remaining item under "Pontos em aberto — conteúdo (11/08/2026)"
/// of the requirements document; until Leandro picks them the "paste without
/// editing anything" acceptance criterion of Essencial 15 cannot be accepted.
const importTemplate = '''
Monte uma lista de cartões de estudo para entrevista de Flutter sênior no
formato Markdown abaixo. Regras do formato:

- Cada cartão é separado por uma linha contendo apenas três traços: ---
- Cada cartão começa com três rótulos, um por linha:
    id: um código curto e único, por exemplo est-001
    assunto: o tema do cartão
    dificuldade: básico, intermediário ou avançado
- Depois vem a linha **Pergunta** e, abaixo dela, a pergunta.
- Depois vem a linha **Resposta** e, abaixo dela, a resposta.
- Quando a resposta tiver código, use um bloco cercado por três crases com a
  linguagem, assim: ```dart
- Não escreva mais nada fora desse formato.

Dois exemplos já preenchidos (o segundo tem código):

---
id: est-001
assunto: <assunto 1>
dificuldade: intermediário

**Pergunta**
Qual a diferença entre setState e um notifier?

**Resposta**
setState reconstrói o widget inteiro a partir do ponto onde foi chamado.
Um notifier avisa apenas quem está ouvindo aquele pedaço de estado.
---
id: est-002
assunto: <assunto 2>
dificuldade: avançado

**Pergunta**
Como declarar um ChangeNotifier simples de contador?

**Resposta**
Estendendo ChangeNotifier e chamando notifyListeners ao mudar o valor:

```dart
class Contador extends ChangeNotifier {
  int valor = 0;

  void incrementar() {
    valor++;
    notifyListeners();
  }
}
```
---
''';
