# Contribuindo

Obrigado pelo interesse. Este documento reúne o que você precisa saber antes de
abrir um PR. As decisões de arquitetura em detalhe — pipeline de agendamento,
armadilhas do `package:fsrs`, regras do PWA — estão em [`CLAUDE.md`](CLAUDE.md),
que apesar do nome é o documento técnico do projeto (ele é lido tanto por
pessoas quanto pelo Claude Code).

## Ambiente

Flutter **3.44.0** stable, a mesma versão do CI. Ver
[README — Requisitos](README.md#requisitos).

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Ao mexer em modelo `freezed` / `json_serializable`, regere o código antes de
`analyze` ou `test`:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Os arquivos gerados (`.freezed.dart`, `.g.dart`) **são versionados** — commite-os
junto com a mudança do modelo.

## Idioma

**Todo o código é em inglês americano** — identificadores, comentários,
nomes de arquivo, descrições de `test()` e mensagens de log. Grafia americana:
`color`, `initialize`, `canceled`.

```dart
// ✓ scheduling ceiling for the day; the cap always wins
test('no interval exceeds the daily ceiling', () { … });

// ✗ agendando o teto do dia
test('nenhum intervalo excede o teto do dia', () { … });
```

**Exceção — texto que o usuário lê é em português do Brasil**, porque os
requisitos fixam os rótulos com as palavras do cliente: os quatro botões são
"Errei", "Lembrei só uma parte", "Lembrei com esforço", "Sabia de cor". O mesmo
vale para `Card.subject` e para os rótulos de `Difficulty`
(`básico`/`intermediário`/`avançado`) — o **enum** é
`Difficulty.basic | intermediate | advanced`, e o parser mapeia um no outro.

Documentos `.md`, mensagens de commit, issues e PRs continuam em português.

## Regras de revisão não negociáveis

1. **Nada em `domain/` ou `data/` importa `package:flutter/*`** — nem
   `foundation.dart`. Consequência: repositórios expõem `Stream`/`Future`,
   nunca `ValueNotifier`. Quem cria notifier é o ViewModel.
2. **Toda dependência externa com modelo próprio tem uma porta única.** Só
   `domain/scheduling/fsrs_adapter.dart` importa `package:fsrs`; só
   `data/database/sembast_adapter.dart` importa `package:sembast_web`.
3. **`DateTime.now()` é proibido fora do `Clock` injetável.**
4. **`firstWhereOrNull`, nunca `firstWhere`** (`package:collection`). Aqui "não
   achou" é estado de negócio previsto.
5. **Estado de tela é union do `freezed`** (`loading | ready | error`), não pilha
   de booleanos.
6. **ViewModel não importa `material.dart`** e não resolve o `get_it` — recebe
   dependências pelo construtor.

## Toda regra de negócio mora em `domain/`

**Regra de negócio fora de `domain/` é motivo de rejeição em revisão**, mesmo
que funcione e mesmo que sejam três linhas.

O produto é o agendamento. Se a conta vaza para o ViewModel, ela deixa de ser
testável na simulação dos 30 dias — e uma regra que vazou não aparece como bug:
aparece como um estudo que correu errado durante 30 dias e ninguém percebeu.

Dois testes para classificar qualquer lógica nova:

1. _"Isso mudaria se o app fosse de terminal, sem tela?"_ — se **não**, é domínio.
2. _"Se isso estiver errado, o usuário estuda errado?"_ — se **sim**, é domínio e
   precisa de teste unitário **sem `WidgetTester`**.

**Sinais de que a regra vazou**, ao revisar um ViewModel:

- `if` ou comparação sobre `stability`, `lapses`, `reps`, `dueAt`, `state` ou
  `introducedAt`;
- aritmética de `DateTime`/`Duration` que não seja formatação de exibição;
- número mágico do domínio: `7` (firme), `4` (cartão-problema), `0.90`
  (retenção), `60` (teto de segundos), `20`/`100`/`30` (a rampa), `0.8` (aviso);
- ordenação, sorteio ou filtragem de cartões;
- `%` ou média que vire indicador do painel.

**O ViewModel pode:** sequenciar telas, traduzir o resultado do domínio para
`XState`, criar e descartar `ValueNotifier`, gerenciar ciclo de vida de `Timer`,
chamar repositórios e formatar texto para exibição. Nada além disso.

## Testes

- Domínio e policies rodam na **VM Dart**, sem `WidgetTester`. Esse é o objetivo
  da fronteira sem Flutter.
- Teste de repositório injeta `databaseFactoryMemory`
  (`package:sembast/sembast_memory.dart`) — não precisa de navegador.
- Teste que precisa de `dart:js_interop` ou IndexedDB de verdade leva
  `@TestOn('browser')` e `@Tags(['chrome-only'])`, e roda no job
  `widget-tests-chrome` do CI.
- **Teste de widget roda em tela de celular**: chame `useScreenSize(tester)`
  antes do `pumpWidget`. O padrão do `WidgetTester` é 800×600, uma tela que
  nenhum usuário tem e larga o bastante para esconder o estouro que um celular
  mostraria.

```dart
useScreenSize(tester);                              // 390×844, o padrão
useScreenSize(tester, size: ScreenSize.smallPhone); // 360×640, o piso do layout
```

Widgets de gráfico e layout do painel **não** precisam de teste automatizado.

## Migrações

**Mudou um modelo `freezed` de forma que altere o JSON? Incremente
`AppDatabase.schemaVersion` e escreva a migração.** Sem isso um backup de ontem
quebra o app de amanhã — e o backup é a única proteção real contra o despejo do
IndexedDB pelo navegador. Cada migração é função pura sobre `Map`, testável sem
banco.

## Git

- `git mv` e `git rm` no lugar de `mv`/`rm`, para preservar histórico.
- Commits no formato `tipo(camada->feature): descrição`, seguindo o histórico —
  `feat(domain->import): check and tidy dart code blocks on import`,
  `fix(tool->hooks): …`, `chore: bump build number to 3`.
- Sem trailer `Co-Authored-By`.
- O hook de `pre-push` (`tool/hooks/`) incrementa o build number do
  `pubspec.yaml` e mantém `app_version.dart` em sincronia. Não edite os dois à
  mão.

## Escopo: não invente requisito

O app foi construído a partir de um documento de requisitos. **Lacuna percebida
ao codificar volta para _Pontos em aberto_ do documento**; não é preenchida por
conta própria. Se sua ideia muda o comportamento de estudo, abra uma issue antes
de abrir o PR — a discussão é sobre a regra, não sobre o código.

## Checklist do PR

- [ ] `flutter analyze` sai limpo
- [ ] `flutter test` passa
- [ ] regra de negócio nova está em `domain/`, com teste sem `WidgetTester`
- [ ] modelo alterado? `schemaVersion` incrementado e migração escrita
- [ ] código em inglês, texto de tela em português
- [ ] arquivos gerados commitados junto
