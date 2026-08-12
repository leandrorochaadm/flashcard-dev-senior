/// Text of the "copiar template" button (H15).
///
/// Pasted into an AI chat without any editing, it has to produce something the
/// parser reads with no issues in the preview. The `id:` field is already
/// there on purpose: it is what preserves a card's history on re-import.
///
/// The answer asks for five fixed sections — what / why / better alternative /
/// real use / Dart code. That is a heavier answer than the three sentences the
/// requirements originally asked for, and the cost lands on the session: a
/// round of five minutes now covers fewer cards. The trade was made knowingly;
/// see the requirements document, "Formato da resposta (12/08/2026)".
///
/// Every format rule below is a real limit of `ui/shared/card_markdown.dart`,
/// which is hand-rolled and deliberately smaller than CommonMark:
///
/// - it has NO escape pass, so `\*` reaches the screen as `\*`;
/// - it has no table support at all;
/// - a line ending in a backslash is a hard break, never a literal backslash;
/// - `---` alone on a line is the card separator of the import parser, so an
///   answer that uses it as a horizontal rule is cut into two cards. `***` is
///   the rule the renderer accepts and the parser ignores.
///
/// The subject names are placeholders. TODO(open point): the five subjects are
/// the single remaining item under "Pontos em aberto — conteúdo (11/08/2026)"
/// of the requirements document; until Leandro picks them the "paste without
/// editing anything" acceptance criterion of Essencial 15 cannot be accepted.
const importTemplate = '''
Monte uma lista de cartões de estudo para entrevista de Flutter sênior no
formato Markdown abaixo.

ESTRUTURA DE CADA CARTÃO

- Cada cartão é separado por uma linha contendo apenas três traços: ---
- Cada cartão começa com três rótulos, um por linha:
    id: um código curto e único, por exemplo est-001
    assunto: o tema do cartão
    dificuldade: básico, intermediário ou avançado
- Depois vem a linha **Pergunta** e, abaixo dela, a pergunta.
- Depois vem a linha **Resposta** e, abaixo dela, a resposta.

A RESPOSTA TEM CINCO SEÇÕES, NESTA ORDEM

1. A resposta ABRE direto com o que a coisa é, em uma ou duas frases, SEM
   rótulo nenhum. Quem virou o cartão quer a resposta na primeira linha.
2. Depois vêm quatro seções, cada uma com o rótulo numa linha própria
   começando por cinco jogos-da-velha, e o texto na linha seguinte:

##### Por quê
Que problema isso resolve, ou por que existe.

##### Alternativa
Existe algo melhor para este caso? Diga qual e quando preferir cada um. Se
não existir alternativa melhor, escreva por que esta é a escolha certa.

##### Uso real
Uma situação concreta de projeto em que isso aparece.

##### Código
Um exemplo curto em Dart, em bloco cercado.

Deixe uma linha em branco antes de cada rótulo. A seção **Código** só entra
quando houver código Dart honesto a mostrar: em temas sem código —
comportamental, análise funcional, processo — pule a seção em vez de
inventar um exemplo artificial.

REGRAS DE FORMATAÇÃO (o app usa um Markdown reduzido)

- Bloco de código sempre cercado por três crases COM a linguagem: ```dart
- Para régua horizontal dentro da resposta use três asteriscos: ***
  Nunca use três traços: eles são o separador de cartões e cortariam a
  resposta em dois cartões na importação.
- NÃO use tabelas: elas não são suportadas e saem como texto cru.
- NÃO use escape de Markdown: uma barra invertida antes de um asterisco ou
  de um sublinhado aparece literalmente na tela. Para falar de um caractere
  especial, use crase simples ao redor dele.
- NÃO termine uma linha com barra invertida.
- Formatação disponível: títulos com #, listas com - ou 1., citação com >,
  negrito com **, itálico com *, tachado com ~~, código curto com crase
  simples e link no formato [texto](url).
- Não escreva mais nada fora desse formato: sem título de arquivo, sem
  introdução, sem comentário final.

DOIS EXEMPLOS JÁ PREENCHIDOS (o segundo tem código)

---
id: est-001
assunto: <assunto 1>
dificuldade: intermediário

**Pergunta**
Qual a diferença entre setState e um notifier?

**Resposta**
`setState` reconstrói o widget inteiro a partir do ponto onde foi chamado.
Um notifier avisa apenas quem está ouvindo aquele pedaço de estado.

##### Por quê
`setState` acopla o estado ao widget: só quem tem o `State` na mão consegue
mudá-lo, e a reconstrução alcança toda a subárvore abaixo. O notifier separa
quem guarda o estado de quem o desenha.

##### Alternativa
Para estado local e efêmero, como o texto digitado num campo, `setState` é a
escolha certa e um notifier seria cerimônia sem ganho. A troca vale quando o
mesmo estado é lido em mais de um lugar da árvore, ou quando a regra que o
altera precisa de teste sem widget.

##### Uso real
O contador de acertos de uma sessão de estudo é lido pelo cabeçalho e pelo
rodapé ao mesmo tempo. Com `setState` você subiria o estado até o ancestral
comum e reconstruiria a tela toda a cada acerto; com um notifier, só os dois
trechos que escutam se redesenham.

---
id: est-002
assunto: <assunto 2>
dificuldade: avançado

**Pergunta**
Como declarar um ChangeNotifier simples de contador?

**Resposta**
Uma classe que estende `ChangeNotifier`, guarda o valor e chama
`notifyListeners` depois de mudá-lo.

##### Por quê
`ChangeNotifier` já implementa a lista de ouvintes e o descarte, então a
classe fica só com a regra. Quem escuta é um `ListenableBuilder` ou um
`AnimatedBuilder`, que reconstrói apenas o trecho passado no `builder`.

##### Alternativa
Se o estado é um único valor, `ValueNotifier<int>` entrega o mesmo
comportamento sem escrever classe nenhuma, e o `ValueListenableBuilder`
recebe o valor já tipado. `ChangeNotifier` passa a valer quando o objeto tem
mais de um campo ou métodos com regra.

##### Uso real
O carrinho de compras de um app de pedidos: itens, total e cupom mudam juntos
e precisam notificar uma vez só por operação, o que um `ValueNotifier` por
campo não daria.

##### Código

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
