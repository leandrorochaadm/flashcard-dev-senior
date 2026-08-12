# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Idioma

**Todo o código é em inglês americano** — identificadores, comentários dentro do
código, nomes de arquivo, descrições de `test()` e mensagens de log. Grafia
americana: `color`, `initialize`, `canceled`.

```dart
// ✓ scheduling ceiling for the day; the cap always wins
test('no interval exceeds the daily ceiling', () { … });

// ✗ agendando o teto do dia
test('nenhum intervalo excede o teto do dia', () { … });
```

**Exceção — texto que o usuário lê é em português do Brasil**, porque os
requisitos fixam os rótulos com as palavras do cliente: os 4 botões são "Errei",
"Lembrei só uma parte", "Lembrei com esforço", "Sabia de cor". O mesmo vale para
o valor de `Card.subject` (vem do Markdown importado) e para `Difficulty`, cujos
rótulos no arquivo são `básico`/`intermediário`/`avançado` — o **enum** é
`Difficulty.basic | intermediate | advanced`, e o parser mapeia um no outro.

Documentos `.md`, mensagens de commit e a conversa continuam em português.

## Estado atual

**As 16 histórias estão implementadas.** `flutter analyze` sai limpo e
`flutter test` roda 273 testes, com **100% de cobertura de linha em `domain/` e
`data/`** — nenhum deles usa `WidgetTester`. `flutter build web --release`
compila; use `tool/build_web.sh`, que carimba versão, build e hash do commit
(lidos do `pubspec.yaml` e do git) na tela `/sobre`.

Os cinco arquivos soltos da tentativa interrompida em 11/08/2026 foram
**aproveitados** — seguiam as regras deste documento — e hoje são parte de
`lib/core/clock.dart`, `lib/domain/models/` e `lib/domain/scheduling/`.

Decisões tomadas ao implementar, que valem como leitura obrigatória:

- **`relearningSteps` repete os quatro degraus.** O handoff configurava só
  `[15 min]`, mas os requisitos dizem que o cartão errado passa pelos quatro
  degraus de novo. Requisito ganha do handoff; está comentado no adapter.
- **A escada serve `learningSteps[degrau atual]`.** `learningStep` conta os
  degraus já vencidos, então a primeira resposta devolve 15 min — é a escada
  desenhada nos requisitos, não o passo interno do pacote.
- **A data de primeira revisão do cartão importado é o dia projetado de
  liberação** (`ContentIntakePolicy.projectedReleaseDate`), não um degrau de
  15 min. É o que espalha o lote de 100 pelos 5 dias na prévia (H5) e o que faz
  o cartão já estar vencido no dia em que é liberado.
- **A fila de liberação desempata por `id`**: `List.sort` não é estável e o lote
  inteiro compartilha o mesmo `importedAt`.
- **`ReviewLog` guarda `stabilityBefore`**, sem o qual a curva de calibração não
  pode ser redesenhada com os pesos antigos antes de desfazer um reajuste.
- **`explicit_to_json: true`** no `build.yaml`: sem isso a sessão interrompida
  volta sem os placares dos rounds.
- **O teto em 04/09 é 1,2 dia, não 1,0.** O texto do requisito arredonda; a
  tabela do próprio documento e a fórmula dizem 1,2. O piso de 1,0 chega em
  09/09.
- **`web_database_factory.dart`** existe porque `sembast_web` não compila na VM
  Dart; se o import morasse no adapter, todo teste de repositório exigiria
  `--platform chrome`.

A especificação completa está em dois documentos, que são a fonte da verdade:

- **`temp/requisitos-flashcard-dev-senior.md`** — linguagem de negócio, 16 requisitos
  essenciais, regras e exceções. Público: o cliente.
- **`temp/handoff-flashcard-dev-senior.md`** — H1–H16 rastreadas aos requisitos,
  arquitetura, pipeline de agendamento, riscos. Público: o time.

**Nunca invente requisito novo.** Lacuna percebida ao codificar volta para
_Pontos em aberto_ do documento de requisitos; não é preenchida por conta própria.

## Comandos

```sh
flutter pub get
flutter run -d chrome                     # a única plataforma-alvo
flutter analyze
flutter test
flutter test --coverage                                        # domain/ e data/ em 100%
tool/build_web.sh                                              # release com versão e commit
flutter test test/domain/scheduling/moving_ceiling_test.dart   # um arquivo
flutter test --plain-name 'exceeds the daily ceiling'          # um teste
flutter test --platform chrome --tags=chrome-only              # ver abaixo
flutter build web --release
dart run build_runner build --delete-conflicting-outputs       # freezed/json
dart run build_runner watch --delete-conflicting-outputs
```

Mexeu em modelo `freezed`/`json_serializable`? Rode o `build_runner` antes de
`analyze` ou `test`. Os arquivos `.freezed.dart` e `.g.dart` **são versionados**
(desde `22934d8`), então uma clonagem limpa compila sem o gerador e o CI não o
executa — mas o código gerado precisa ser commitado junto com a mudança do
modelo, ou o CI quebra contra o arquivo velho.

**`flutter test` roda na VM Dart, não no navegador.** Domínio e policies rodam
assim (é o objetivo da fronteira sem Flutter). Já o `sembast_web` depende de
IndexedDB, que **não existe na VM** — por isso o `SembastAdapter` recebe a
`DatabaseFactory` pelo construtor: teste injeta `databaseFactoryMemory`
(`package:sembast/sembast_memory.dart`) e roda normal. `--platform chrome` só é
necessário para testar o IndexedDB de verdade, o que quase nunca é o alvo.

`analysis_options.yaml` é o padrão do `flutter_lints`, sem regra customizada — as
fronteiras abaixo são revisão manual, o analisador não as impõe hoje.

## Arquitetura

MVVM com `ValueNotifier`, **feature-first apenas no `ui/`**; `domain/` e `data/`
são compartilhados. As features são janelas para a **mesma entidade** (`Card`),
então duplicar o domínio por feature produziria definições divergentes de "cartão
firme" e o painel discordaria da sessão sobre o progresso.

```
lib/
├─ core/     di · clock · result · router
├─ domain/   models · scheduling · policies · mock_interview · stats · import
├─ data/     database (sembast_web) · repositories
└─ ui/       session · import · dashboard · mock_interview · cards · backup · shared
```

Cada pasta de `ui/` é **apagável**: consome domínio, nunca o define.

### Regras de revisão de código (não negociáveis)

1. **Nada em `domain/` ou `data/` importa `package:flutter/*`** — nem
   `foundation.dart`. Consequência: repositórios expõem `Stream`/`Future`, nunca
   `ValueNotifier`. Quem cria notifier é o ViewModel.
2. **Toda dependência externa com modelo próprio tem uma porta única.** Só
   `domain/scheduling/fsrs_adapter.dart` importa `package:fsrs`; só
   `data/database/sembast_adapter.dart` importa `package:sembast_web`. Nenhum
   ViewModel, policy ou repository importa qualquer um dos dois. É o que torna
   real a promessa de trocar o pacote mexendo em um arquivo — e, no caso do
   banco, é o que permite injetar `databaseFactoryMemory` no teste.
   (`get_it`, `freezed` e `collection` não ganham adapter: não têm modelo a
   traduzir.) Contratos completos no handoff, seção _Adapters_.
3. **`DateTime.now()` é proibido fora do `Clock` injetável.** O teto móvel, o
   ciclo curto e o prazo de 09/09 são todos função da data; sem `Clock` não há
   como testar "o dia 25" a não ser mexendo no relógio da máquina.
4. **`firstWhereOrNull`, nunca `firstWhere`** (`package:collection`). Aqui "não
   achou" é estado de negócio previsto — `firstWhere` lançaria `StateError`
   exatamente nos caminhos que os requisitos descrevem como normais. O retorno é
   `Card?` explícito. Vale para todas as variantes que lançam.
5. **Estado de tela é union do `freezed`** (`loading | ready | error`), não pilha
   de booleanos.
6. **ViewModel não importa `material.dart`** e não resolve o `get_it` — recebe
   dependências pelo construtor; quem resolve é a View ou a rota.

### MANDATÓRIO: toda regra de negócio mora em `domain/`

Não é preferência de estilo nem meta de refatoração futura. **Regra de negócio
fora de `domain/` é motivo de rejeição em revisão**, mesmo que funcione e mesmo
que sejam três linhas. Não existe exceção "só desta vez porque é simples".

**Por quê, especificamente neste app:** o produto é o agendamento. Se a conta
vaza para o ViewModel, ela deixa de ser testável na simulação dos 30 dias — e
essa simulação é a única forma de responder *"o método funciona?"* antes de
09/09. Uma regra que vazou não aparece como bug: aparece como um estudo que
correu errado durante 30 dias e ninguém percebeu.

Dois testes para classificar qualquer lógica nova:

1. *"Isso mudaria se o app fosse de terminal, sem tela?"* — se **não**, é domínio.
2. *"Se isso estiver errado, o usuário estuda errado?"* — se **sim**, é domínio e
   precisa de teste unitário **sem `WidgetTester`**.

**Sinais de que a regra vazou** (procure por eles ao revisar um ViewModel):

- qualquer `if` ou comparação sobre `stability`, `lapses`, `reps`, `dueAt`,
  `state` ou `introducedAt`;
- qualquer aritmética de `DateTime`/`Duration` que não seja formatação de exibição;
- qualquer número mágico do domínio: `7` (firme), `4` (cartão-problema), `0.90`
  (retenção), `120` (teto de segundos), `20`/`100`/`30` (a rampa), `0.8` (aviso);
- qualquer ordenação, sorteio ou filtragem de cartões;
- qualquer `%` ou média que vire indicador do painel.

**O ViewModel pode:** sequenciar telas, traduzir o resultado do domínio para
`XState`, criar e descartar `ValueNotifier`, gerenciar ciclo de vida de `Timer`,
chamar repositórios e formatar texto para exibição. Nada além disso.

```dart
// ✓ o domínio decide; o ViewModel só encaminha e traduz para estado de tela
Future<void> answer(Rating rating) async {
  final updated = _scheduler.apply(_currentCard, rating, _clock.now());
  await _cards.save(updated);
  final next = _roundQueue.next();          // Card? — null = round esgotado
  state.value = next == null
      ? SessionState.roundBreak(_current, _nextSubject)
      : SessionState.showingQuestion(next, _secondsLeft);
}

// ✗ vazou: o ViewModel virou a segunda autoridade sobre "firme"
if (card.stability >= 7) _firmToday.value++;
```

**Duas regras que parecem de tela e não são.** O `Timer` de 1 s é infraestrutura
do ViewModel, mas "round dura 5 minutos", "a pausa congela cartão + round +
sessão" e "acima do teto descarta o tempo" são `SessionPolicy` /
`TimeOnCardPolicy`. E a prévia de importação: o parser devolve
`ImportPreview(valid, invalid)` como dado puro; a View só pinta.

O handoff tem a tabela completa _regra do cliente → classe de domínio_ (seção
_Onde mora cada regra de negócio_). Consulte-a antes de criar classe nova — a
regra provavelmente já tem dono.

### Flutter Web: o que não existe

Sem `dart:io`, sem `dart:ffi`, **sem `dart:isolate`** — `Isolate.run` lança
`UnsupportedError` em código compilado para JS/WASM. O otimizador FSRS treina em
fatias na thread principal, cedendo o frame com `await Future.delayed(Duration.zero)`
entre épocas. Nenhum plugin com código nativo, nenhum `sqflite`.

## PWA: offline e atualização

**O service worker do Flutter está desligado.** Desde a 3.44 o
`flutter_service_worker.js` gerado se autodestrói — chama `skipWaiting()` no
install e `registration.unregister()` no activate — e não guarda nada em cache;
o próprio bundle o rotula "deprecated and will be removed in a future Flutter
release". Por isso `tool/build_web.sh` passa **`--pwa-strategy=none`** e o
`web/sw.js` assume, registrado pelo `index.html`.

`web/sw.js` serve navegação por rede-primeiro com queda para o `index.html` do
cache, e o resto por cache-primeiro. O nome do cache carrega o build
(`flashcards-1.0.0+7.abc1234`, carimbado pelo `build_web.sh`), então um build
novo abre um cache novo e apaga o anterior inteiro — nunca um `main.dart.js`
novo contra um manifesto de assets velho.

**Duas armadilhas, ambas descobertas testando no navegador de verdade:**

- **`register()` não verifica se o script mudou.** O navegador só rebusca o
  `sw.js` conforme o cache HTTP; num teste com servidor sem `Cache-Control`, o
  app ficou preso no build antigo mesmo com o servidor já publicando o novo.
  Por isso, ao ver o `version.json` mudar, o `index.html` chama
  **`registration.update()` explicitamente**. Sem essa linha, a atualização não
  acontece.
- **O reload não pode ser disparado pela detecção da versão.** Recarregar antes
  de o worker novo ativar serve um `index.html` novo com os assets do cache
  antigo. Quem manda recarregar é o próprio worker: no `activate`, depois de
  limpar os caches, ele faz `postMessage({type:'activated'})` para as páginas
  abertas. Só então o `index.html` marca o reload — e o executa **quando a
  página fica oculta**, para não arrancar o cartão da frente de quem estuda.

`web/_headers` marca `no-cache` em **tudo** (`/*`), não só nos entry points: o
Flutter web **não gera nome com hash**, então `main.dart.js`, `AssetManifest.bin`
e `MaterialIcons-Regular.otf` mudam de conteúdo mantendo o nome, e marcá-los
`immutable` prenderia uma fonte velha sem forma de despejar. O Cloudflare
Workers serve `_headers` a partir do `[assets]` do `wrangler.toml`.

**Como testar sem confiar em impressão.** `Network.emulateNetworkConditions` do
DevTools **não alcança o service worker** — ele tem contexto de rede próprio, e
requisições same-origin continuam saindo. O único teste honesto é **derrubar o
servidor** e recarregar. Use um perfil de navegador limpo: caches, service
workers e abas antigas de execuções anteriores contaminam o resultado, e uma
aba esquecida segue consultando o `version.json` e recriando caches.

O build number vem do `pubspec.yaml`, incrementado pelo hook de `pre-push`
(`tool/hooks/`), e é o que avisa um PWA suspenso de que existe versão nova.

## O núcleo: agendamento

A ordem das 5 operações é **normativa** e o passo 5 não pode ser movido —
espalhamento e nivelamento empurram a data para frente, então um teto aplicado
antes deles seria furado:

1. Ciclo curto tem precedência absoluta (`isLearning` ou `Rating.again`) →
   15 min → 1 h → 4 h → 1 d
2. FSRS calcula o intervalo (retenção-alvo 0,90)
3. Espalhamento ±10% (nosso, não o do pacote)
4. Nivelamento: entre datas candidatas, a de menor carga
5. **Teto móvel corta por último**

`teto(r) = max(1, N ÷ (100 − 2,67·r))`, com `r` = dias que **faltam** para
`targetDate` (limitado a 0..30) e `N` = número de cartões **liberados**
(`introducedAt != null`). O `Duration` é construído em **minutos**, não em dias —
`Duration(days: 2)` perderia o ",4" de 2,4 dias.

**É "faltam", não "decorridos"** (decisão de 11/08/2026). Dentro da janela
original de 30 dias as duas contas coincidem — 11/08 dá 4,4 dias nas duas —,
então um teste que passe não prova que a implementação está certa. O teste que
distingue é com `targetDate` remarcada: faltando 10 dias, o teto tem de ser
~1,4 dia, não ~5. `MovingCeiling` **não depende de `startDate`**.

Três recursos do `package:fsrs` ficam desligados de propósito: `maximumInterval`
(inteiro em dias, não expressa teto decimal), `enableFuzzing` (espalha antes do
teto, furaria) e o otimizador (não existe em Dart).

**Três armadilhas do `fsrs 2.0.1`, todas confinadas ao `fsrs_adapter.dart`:**

- **`reviewCard` exige `reviewDateTime` em UTC** (lança `ArgumentError`). O
  `Clock` devolve hora local — `toUtc()` na entrada e `toLocal()` na saída
  acontecem só dentro do adapter. UTC vazando para o domínio desloca as datas.
- **O pacote exporta `Card`, `ReviewLog`, `Rating` e `State`**, homônimos dos
  nossos. Importar sempre como `import 'package:fsrs/fsrs.dart' as fsrs;`.
- **`getCardRetrievability` usa `.inDays`, que trunca.** Numa revisão 4 h depois
  da anterior o resultado vira 1,0 — ou seja, durante todo o ciclo curto a
  `predictedRetention` seria constante e a calibração viraria uma linha reta sem
  significado. O adapter calcula a retrievability com dias **decimais**
  (`inMinutes / 1440`). Ver o handoff, seção _Como configurar o `package:fsrs`_.

O teto limita a **data agendada**, nunca a `stability`. Indicadores leem
`stability`; um cartão pode estar marcado para amanhã e ainda ser "pronto".

## Armadilhas específicas do domínio

- **`difficulty` × `difficultyFsrs`** — o primeiro é o rótulo do Markdown
  (básico/intermediário/avançado), o segundo é o 1..10 do algoritmo.
- **`importedAt` × `introducedAt`** — importar não é liberar. `introducedAt ==
  null` significa que o cartão está no banco mas retido pela
  `ContentIntakePolicy`. Sem essa distinção, H16 e H5 se excluem.
- **`source == session` × `simulado`** — o simulado grava `ReviewLog` e **nada
  mais**: não toca `stability`, `dueAt`, `state` nem `lapses`. `Calibration` e o
  otimizador precisam filtrar `source == session`, senão o único indicador que
  audita o app fica contaminado.
- **Carga inicial (11/08–15/08) ignora** a regra de "reduzir entrada quando
  estudou pouco". Essa precedência some numa refatoração — tem teste dedicado.
- **`isReady` tem piso**: `stability >= max(1, diasAté(09/09))`. Sem o `max`, em
  09/09 todo cartão viraria "pronto".
- **`startDate` e `targetDate` são dados de `settings`, não constantes**
  (decisão de 11/08/2026, que reverteu a data-alvo fixa). `startDate` é a
  véspera da primeira abertura, gravada uma única vez; `targetDate` é escolhida
  num calendário e, sem escolha, vale `startDate + 29 dias`. Hoje isso dá
  10/08/2026 e 09/09/2026, com o app abrindo em 11/08 no **dia 1**, teto de 4,4
  dias — mas o número vem da janela injetada, não de literal. Nenhum
  `DateTime(2026, …)` em `domain/`; não fixe "5,0 dias" em teste.
- **Mudou modelo `freezed` de forma que altere o JSON? Incremente
  `AppDatabase.schemaVersion` e escreva a migração.** Sem isso um backup de
  ontem quebra o app de amanhã — e o backup é a única proteção real contra o
  despejo do IndexedDB pelo navegador. Cada migração é função pura sobre `Map`,
  testável sem banco.
- **A tela `/debug` (viagem no tempo) opera em banco separado,
  `flashcards_debug`** — nunca no real, senão a ferramenta de teste corrompe o
  histórico que o app existe para proteger. Ela troca `SystemClock` por
  `FakeClock` no `get_it`; nenhum código de produção sabe que ela existe.

## Testes

O teste que vale por todos é a **simulação dos 30 dias** com `FakeClock`,
avançando dia a dia e verificando teto, carga e ausência de duplicatas. Roda em
milissegundos, e só é possível porque `Clock` é injetável e o domínio não importa
Flutter.

Oito testes obrigatórios estão tabelados em _Estratégia de testes_ no handoff — os
mais frágeis são a ordem das 5 operações e a precedência da carga inicial.

Widgets de gráfico e layout do painel **não** precisam de teste automatizado.

**Teste de widget roda em tela de celular.** O alvo é um PWA no celular, e o padrão
do `WidgetTester` é 800×600 — uma tela que nenhum usuário tem e larga o bastante
para esconder exatamente o estouro que um celular mostraria. Todo `testWidgets`
chama `useScreenSize(tester)` antes do `pumpWidget`:

```dart
useScreenSize(tester);                             // 390×844, o padrão
useScreenSize(tester, size: ScreenSize.smallPhone); // 360×640, o piso do layout
```

`test/support/screen_sizes.dart` registra o tear-down sozinho, então nenhum teste
vaza tamanho para o seguinte. O valor vale igual na máquina e no CI: o
`WidgetTester` desenha numa `TestFlutterView` virtual, nunca na janela real.

**Os arquivos marcados `@TestOn('browser')` são pulados no `flutter test`** e rodam
no job `widget-tests-chrome` do CI, via `flutter test --platform chrome
--tags=chrome-only`. Eles alcançam `dart:js_interop` (por `sembast_web` e por
`core/router.dart`), que não existe na VM Dart. A anotação é o que faz um
`flutter test` local sair limpo em vez de falhar ao compilar — a tag sozinha só
ajuda quem lembra de passar `--exclude-tags`.

## Ordem de implementação

Entrega única, sem lista de corte, mas a ordem importa (handoff, _Ordem de
implementação_): fatia 1 (importar + ler) → **fatia 2, o coração** (4 botões,
FSRS, teto, espalhamento, liberação diária) → fatia 3 (sessão + backup) → fatia 4
(painel) → fatia 5 (simulado, PWA, autoajuste).

H14 (backup) vem **antes** do painel: todo dia sem backup é histórico exposto ao
despejo do IndexedDB, que é o risco nº 2.

## Git

- `git mv` e `git rm` no lugar de `mv`/`rm`, para preservar histórico.
- Commits **sem** trailer `Co-Authored-By`.
