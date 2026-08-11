# Prompt para gerar os 100 cartões

_Criado em 10/08/2026 · use hoje, antes de o app existir_

**Como usar:** copie tudo o que está **abaixo da linha dupla** e cole no chat da
IA. Peça um assunto por vez (5 pedidos de 20 cartões) — lote grande demais faz a
IA encurtar as respostas e repetir perguntas.

Ao final, junte os 5 arquivos num só e guarde. Em 11/08 ele entra no app de uma
vez, e o espalhamento distribui as datas.

> Este texto é o mesmo conteúdo que vai virar o botão "copiar template" (H15),
> acrescido das instruções de quantidade e assunto — que o botão não terá, porque
> lá você já estará importando lotes menores.

═══════════════════════════════════════════════════════════════════════

Você vai criar cartões de estudo (flashcards) para me preparar para uma
entrevista de **desenvolvedor Flutter sênior**.

## O que eu preciso

**20 cartões** sobre o assunto: **[ESCREVA AQUI UM DOS 5 ASSUNTOS]**

Distribuição de dificuldade nos 20:
- 5 básicos — fundamento que todo dev Flutter sabe
- 10 intermediários — o que separa pleno de júnior
- 5 avançados — o que um entrevistador usa para achar o teto do candidato

## A regra mais importante: uma pergunta, um fato

Cada cartão deve testar **uma única ideia**, respondível em **até 3 frases** (ou
um trecho curto de código). Pergunta ampla vira cartão impossível de lembrar
inteiro.

    ✗ RUIM:  "Explique o ciclo de vida de um StatefulWidget"
             → resposta de 2 minutos, nunca lembrada por completo

    ✓ BOM:   "Em qual método do StatefulWidget é seguro chamar
              context.dependOnInheritedWidgetOfExactType?"
             "O que acontece se você chamar setState depois do dispose?"
             "Qual método roda quando o widget pai troca a configuração?"

Prefira perguntas que começam com **o que / qual / quando / por que**, e que
tenham resposta verificável. Evite "fale sobre", "explique", "discorra".

## Perguntas boas para entrevista sênior

Priorize, nesta ordem:

1. **Trade-off** — "quando X é pior que Y?"
2. **Consequência** — "o que acontece se…?"
3. **Diagnóstico** — "esta tela reconstrói demais; qual a causa mais provável?"
4. **Definição precisa** — só quando o termo for realmente usado no dia a dia

Evite trivia de decoreba (nomes de parâmetros raros, valores default obscuros).

## Formato de saída — siga exatamente

Cada cartão começa e termina com uma linha `---`. Os campos `id`, `assunto` e
`dificuldade` vêm no topo, sem negrito. A pergunta e a resposta vêm sob os
rótulos `**Pergunta**` e `**Resposta**`. Código vai em bloco cercado com o nome
da linguagem.

O `id` segue o padrão `<prefixo do assunto>-<número de 3 dígitos>`, começando em
001 e sem repetir. Use estes prefixos:

| Assunto | Prefixo |
|---|---|
| Estado e arquitetura | `est` |
| Renderização e performance | `perf` |
| Dart assíncrono | `async` |
| Testes | `test` |
| Plataforma e entrega | `plat` |

**Exemplo com dois cartões — copie esta forma:**

---
id: est-001
assunto: Estado e arquitetura
dificuldade: básico

**Pergunta**
O que exatamente é reconstruído quando você chama setState?

**Resposta**
A subárvore a partir do widget onde setState foi chamado — não a tela inteira,
e não apenas o trecho que usa a variável alterada. É por isso que setState num
widget alto na árvore é caro.
---
id: est-002
assunto: Estado e arquitetura
dificuldade: intermediário

**Pergunta**
Por que ValueNotifier evita reconstruções que setState causaria?

**Resposta**
Porque quem escuta é o ValueListenableBuilder, e só a subárvore dentro dele é
reconstruída. O widget que segura o notifier não reconstrói.

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

## Regras de formatação que não podem falhar

1. **Sempre** abrir e fechar cada cartão com `---` numa linha sozinha.
2. **Sempre** preencher `id`, `assunto` e `dificuldade`. O `id` é o que preserva
   meu histórico quando eu corrigir um cartão depois — cartão sem `id` perde o
   progresso na reimportação.
3. Escrever `dificuldade` como exatamente uma destas palavras: `básico`,
   `intermediário`, `avançado`.
4. Código sempre em bloco cercado com ```dart (ou ```yaml, ```sh conforme o
   caso). Nunca código solto no meio do texto.
5. Manter a indentação do código; linhas de até ~70 colunas quando der.
6. **Não** numerar os cartões fora do campo `id`, **não** adicionar títulos,
   introduções ou comentários entre eles. A saída deve ser só a sequência de
   cartões.
7. Não repetir pergunta já feita em cartão anterior do mesmo lote.

Comece agora, com os 20 cartões do assunto que eu indiquei acima.

═══════════════════════════════════════════════════════════════════════

## Os 5 assuntos (20 cartões cada)

Rode o prompt acima uma vez por assunto, trocando a linha do assunto:

1. **Estado e arquitetura** — `est`
   ValueNotifier e ChangeNotifier, MVVM, injeção de dependência, separação de
   camadas, InheritedWidget, quando cada abordagem quebra, imutabilidade.

2. **Renderização e performance** — `perf`
   Widget/Element/RenderObject, keys, const, rebuild × relayout × repaint,
   causas de jank, RepaintBoundary, listas longas, DevTools.

3. **Dart assíncrono** — `async`
   Future × Stream, async/await, microtask queue × event loop, isolates (e sua
   ausência no web), tratamento de erro, cancelamento, broadcast.

4. **Testes** — `test`
   unit × widget × integration, fakes × mocks, pumpAndSettle, golden tests,
   injeção para testabilidade, o que não vale testar.

5. **Plataforma e entrega** — `plat`
   platform channels, Flutter Web e PWA, service worker, build modes, tree
   shaking, versionamento, CI, limitações de dart:io e dart:isolate no web.

## Depois de gerar

- Junte os 5 blocos num arquivo só, na ordem que quiser.
- Confira que os `id` não repetem entre os arquivos (prefixos diferentes já
  resolvem isso).
- Guarde o arquivo — ele é a origem dos seus cartões. Quando o app marcar um
  cartão-problema, você edita **este arquivo**, mantém o `id`, quebra a pergunta
  em duas (a segunda ganha `id` novo) e reimporta.
