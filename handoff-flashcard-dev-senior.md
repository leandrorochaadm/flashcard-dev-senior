# Handoff técnico — Flashcards para entrevista de Flutter sênior

_Gerado em 10/08/2026, a partir de `requisitos-flashcard-dev-senior.md` (validado em 10/08/2026)_

## Visão geral

PWA de repetição espaçada de uso pessoal, offline-first, para preparar um
desenvolvedor para entrevistas de Flutter sênior num prazo fechado de **30 dias
(10/08/2026 → 09/09/2026)**. A coleção começa com **100 cartões em 5 assuntos**,
importados em Markdown. O agendamento usa **FSRS** com retenção-alvo de 90%,
ciclo curto de aquisição (15 min → 1 h → 4 h → 1 dia) e um **teto móvel derivado
da carga diária desejada**, que encolhe de ~5 dias para 1 dia ao longo do prazo.

Entrega **única**: não há versão 2, não há lista de corte. Todos os 16 requisitos
essenciais entram na mesma entrega.

---

## Stack e decisões de arquitetura

| Camada | Decisão | Motivo |
|---|---|---|
| Plataforma | **Flutter Web**, empacotado como PWA instalável em celular | Requisito 9; um único aparelho, sem app store |
| Arquitetura | **MVVM** | Definido pelo time |
| Estado | **`ValueNotifier` / `ValueListenableBuilder`** | Definido pelo time; sem pacote de estado externo |
| Injeção | **`get_it`** (service locator) | Definido pelo time |
| Modelos | **`freezed` + `json_serializable`** | Imutabilidade, `copyWith`, união de estados de UI e serialização gratuita |
| Persistência | **`sembast_web`** (IndexedDB) | Ver seção _Persistência_ |
| Agendamento | **`package:fsrs`** (port Dart do py-fsrs) | Fórmula testada; evita erro de implementação |
| Autoajuste | **Otimizador próprio em Dart puro**, rodando em Isolate | O otimizador oficial é Rust/Python e `dart:ffi` não existe em Flutter Web |

### Estrutura de pastas — features no `ui/`, domínio compartilhado

```
lib/
│
├─ main.dart
│
├─ core/                                  ← infraestrutura, sem regra de negócio
│  ├─ di/service_locator.dart
│  ├─ clock.dart                          Clock injetável
│  ├─ result.dart                         Result<T> (freezed union)
│  └─ router.dart
│
├─ domain/                                ← COMPARTILHADO entre features
│  ├─ models/
│  │  ├─ card.dart                        freezed + json
│  │  ├─ review_log.dart
│  │  ├─ study_session.dart
│  │  └─ enums.dart                       Rating · CardState · Difficulty
│  ├─ scheduling/
│  │  ├─ card_scheduler.dart              o pipeline de 5 passos
│  │  ├─ moving_ceiling.dart              teto(t) = max(1, N ÷ carga(t))
│  │  ├─ memory_state.dart                a metade do cartão que o FSRS enxerga
│  │  ├─ fsrs_adapter.dart                ÚNICO ponto que toca package:fsrs
│  │  └─ optimizer/
│  │     ├─ fsrs_optimizer.dart
│  │     └─ optimizer_isolate.dart
│  ├─ policies/
│  │  ├─ session_policy.dart              round 5 min · 5 rounds · pausa
│  │  ├─ due_cards_policy.dart            antecipação: só o que vence hoje
│  │  ├─ content_intake_policy.dart       carga inicial · aviso dos 80%
│  │  └─ time_on_card_policy.dart         teto de 60 s
│  ├─ mock_interview/
│  │  └─ mock_interview_service.dart      sorteio equilibrado · não reagenda
│  ├─ stats/
│  │  ├─ calibration.dart                 previsto × real
│  │  └─ load_forecast.dart               barras dos próximos 7 dias
│  └─ import/
│     ├─ markdown_parser.dart
│     ├─ import_preview.dart
│     └─ import_template.dart             texto do botão "copiar template"
│
├─ data/                                  ← COMPARTILHADO entre features
│  ├─ database/
│  │  ├─ app_database.dart                interface + schemaVersion + migrações
│  │  └─ sembast_adapter.dart             ÚNICO ponto que toca sembast_web
│  └─ repositories/
│     ├─ card_repository.dart
│     ├─ review_log_repository.dart
│     ├─ session_repository.dart
│     ├─ settings_repository.dart
│     └─ backup_repository.dart           export/import do banco inteiro
│
└─ ui/                                    ← AQUI SIM, por feature
   │
   ├─ session/                            H1 · H2 · H8 · H11
   │  ├─ session_view.dart
   │  ├─ session_viewmodel.dart
   │  ├─ session_state.dart
   │  └─ widgets/
   │     ├─ card_face.dart                pergunta / resposta revelada
   │     ├─ rating_buttons.dart           os 4 botões
   │     ├─ round_timer.dart              notifier próprio (não rebuilda o cartão)
   │     └─ round_break_screen.dart       tela silenciosa da virada
   │
   ├─ import/                             H3 · H15 · H16
   │  ├─ import_view.dart
   │  ├─ import_viewmodel.dart
   │  ├─ import_state.dart
   │  └─ widgets/
   │     ├─ preview_list.dart             válidos × linhas problemáticas
   │     ├─ copy_template_button.dart
   │     └─ intake_warning.dart           aviso dos 80%
   │
   ├─ dashboard/                          H6 · H12 · H13
   │  ├─ dashboard_view.dart
   │  ├─ dashboard_viewmodel.dart
   │  ├─ dashboard_state.dart
   │  └─ widgets/
   │     ├─ firm_today_tile.dart
   │     ├─ accuracy_vs_target_tile.dart
   │     ├─ subject_map.dart
   │     ├─ calibration_chart.dart        linha: previsto × real
   │     ├─ load_forecast_chart.dart      barras dos próximos 7 dias
   │     ├─ avg_time_tile.dart            geral + quebra por assunto
   │     ├─ idle_time_panel.dart          os 3 botões do tempo ocioso
   │     └─ deadline_banner.dart          prazo 09/09
   │
   ├─ mock_interview/                     H10
   │  ├─ mock_interview_view.dart
   │  ├─ mock_interview_viewmodel.dart
   │  └─ mock_interview_state.dart
   │
   ├─ cards/                              H7
   │  ├─ cards_view.dart                  navegar a coleção
   │  ├─ cards_viewmodel.dart
   │  └─ widgets/problem_card_banner.dart
   │
   ├─ backup/                             H14
   │  ├─ backup_view.dart
   │  └─ backup_viewmodel.dart
   │
   └─ shared/
      ├─ code_block.dart                  monoespaçada · realce · rolagem lateral
      └─ app_scaffold.dart
```

**Quem consome o quê:**

```
   ui/session      ─┐
   ui/mock_int.    ─┤
   ui/dashboard    ─┼──▶  domain/scheduling  ──▶  package:fsrs
   ui/import       ─┤            │                (só via fsrs_adapter)
   ui/cards        ─┘            ▼
                          domain/policies
                                 │
                                 ▼
                          data/repositories  ──▶  sembast_web
```

**Por que o domínio NÃO se separa por feature.** Feature-first puro (cada feature
com `domain/`, `data/` e `ui/` próprios) serve para fatias verticais
independentes. Aqui as features são **quatro janelas para a mesma entidade** — o
`Card` e seu estado FSRS. Duplicar o domínio produziria três definições de
"cartão firme" que podem divergir, e o painel passaria a discordar da sessão
sobre o progresso — justamente o indicador que dá a sensação de avanço.

```
   ✗ feature-first puro
   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
   │ session/     │  │ dashboard/   │  │ mock/        │
   │  domain/     │  │  domain/     │  │  domain/     │
   │   card.dart  │  │   card.dart  │  │   card.dart  │  ← 3 verdades
   │   isFirm?    │  │   isFirm?    │  │   isFirm?    │     sobre "firme"
   └──────────────┘  └──────────────┘  └──────────────┘
```

A modularidade continua existindo, mas no `ui/`: **cada pasta de feature é
apagável**. Cortar o simulado é deletar `ui/mock_interview/` — ele só consome
domínio, não o define.

> **`fsrs_adapter.dart` é a única porta para o pacote externo.** É o que torna
> real a promessa de trocar o `package:fsrs` mexendo em um arquivo. Nenhum
> ViewModel, policy ou repository pode importar `package:fsrs` diretamente —
> vale como regra de revisão de código.

### Adapters: uma porta única por dependência externa

**Regra geral:** todo pacote externo com modelo próprio é acessado por **um
único arquivo adapter**, que traduz entre o tipo do pacote e o tipo nosso.
Nenhuma outra classe importa o pacote. Duas dependências se enquadram nisso — as
duas que trazem modelo próprio e API instável entre versões:

| Pacote | Adapter | Traduz |
|---|---|---|
| `fsrs 2.0.1` | `domain/scheduling/fsrs_adapter.dart` | `MemoryState` ⇄ `fsrs.Card` |
| `sembast_web 2.4.5` | `data/database/sembast_adapter.dart` | `Map<String, Object?>` ⇄ stores e transações |

`get_it`, `freezed` e `collection` **não** ganham adapter: são anotação,
extension e service locator — não têm modelo a traduzir, e envolvê-los seria
cerimônia sem ganho.

#### 1. `FsrsAdapter` — a porta do algoritmo

Contrato a implementar (a assinatura vale mais que o corpo):

```dart
abstract interface class FsrsGateway {
  /// Devolve o estado de memória atualizado. Quem extrai o intervalo e aplica
  /// espalhamento, nivelamento e teto é o CardScheduler (passos 3 a 5).
  MemoryState review(MemoryState state, Rating rating, DateTime now);

  /// Retenção prevista AGORA, em dias decimais. Alimenta
  /// ReviewLog.predictedRetention e, por consequência, a calibração.
  double retrievability(MemoryState state, DateTime now);

  List<double> get parameters;
  bool parametersAreInRange(List<double> candidate);
}

final class FsrsAdapter implements FsrsGateway { … }
```

**`MemoryState` (`domain/scheduling/memory_state.dart`) é a metade do cartão que
o algoritmo enxerga:** `state`, `step`, `stability`, `difficulty`, `dueAt`,
`lastReviewedAt`. Classe imutável simples, **sem freezed** — nunca é serializada
sozinha (viaja dentro de `Card.toJson()`) e precisa compilar sem o gerador. O
`Card` embute os mesmos campos e converte na fronteira.

> Por que o adapter não recebe o `Card` inteiro: pergunta, resposta, assunto e
> histórico de importação não têm nada a ver com o algoritmo. Passar o `Card`
> daria ao adapter acesso a campos que ele não pode usar — e é assim que regra
> de negócio migra para o lugar errado sem ninguém notar.

**Cinco traduções que o adapter é obrigado a fazer:**

| # | Do pacote | Para nós |
|---|---|---|
| 1 | `fsrs.State` tem só `learning · review · relearning` | `CardState.isNew` não existe lá → entra como `learning` com `step: 0` |
| 2 | `reviewDateTime` **precisa ser UTC** (`ArgumentError` se não for) | `toUtc()` na entrada, `toLocal()` na saída. Hora local é a do domínio |
| 3 | `fsrs.Card.cardId` é `int`; nosso `id` é `String` (`est-001`) | O pacote não usa `cardId` no cálculo → passar `0` e documentar |
| 4 | `fsrs.Card` é **mutável**, com `stability`/`difficulty` anuláveis | Sai de lá como `MemoryState` imutável |
| 5 | Construtor de `fsrs.Card` usa `DateTime.now().toUtc()` como `due` padrão | **Sempre** passar `due` explícito, senão o `Clock` é furado silenciosamente |

**A `retrievability` é reimplementada de propósito.** O
`getCardRetrievability` do pacote usa `.inDays`, que trunca — no ciclo curto
(15 min a 4 h) o resultado vira 1,0 sempre. Fórmula com dias decimais:

```dart
final elapsedDays = now.toUtc().difference(lastReview).inMinutes / 1440.0;
return math.pow(1 + _factor * elapsedDays / stability, _decay).toDouble();
// _decay = -parameters[20];  _factor = math.pow(0.9, 1 / _decay) - 1
```

`parametersAreInRange` usa `lowerBoundsParameters` e `upperBoundsParameters`,
exportados pelo pacote (21 pesos) — é o critério objetivo para o autoajuste
descartar um treino ruim, em vez de inventar limite próprio.

#### 2. `SembastAdapter` — a porta do banco

```dart
abstract interface class AppDatabase {
  StoreRef<String, Map<String, Object?>> get cards;
  StoreRef<int,    Map<String, Object?>> get reviews;
  StoreRef<String, Object?>              get settings;
  StoreRef<String, Map<String, Object?>> get sessions;

  Future<T> transaction<T>(Future<T> Function(DatabaseClient txn) action);

  Future<Map<String, Object?>> export();        // H14 — cópia de segurança
  Future<void> restore(Map<String, Object?> data);
  Future<void> close();
}

final class SembastAdapter implements AppDatabase { … }
```

**Por que a interface existe aqui, e não em cada repository:** ela recebe a
`DatabaseFactory` pelo construtor. Em produção entra `databaseFactoryWeb`
(IndexedDB); **no teste entra `databaseFactoryMemory`**, de
`package:sembast/sembast_memory.dart`, que roda na VM Dart. É o que torna
possível testar repositório com `flutter test` normal — sem isso, todo teste que
toca o banco exigiria `--platform chrome`.

**Três detalhes que não podem ser esquecidos:**

- `importDatabase(src, factory, path)` **apaga o banco destino** e devolve uma
  **nova** instância de `Database` — o adapter precisa reatribuir a sua
  referência interna, senão continua escrevendo no banco antigo.
- `openDatabase` recebe `version: schemaVersion` e `onVersionChanged`; é ali que
  as migrações em cadeia rodam (ver _Versionamento e migração de schema_).
- `navigator.storage.persist()` é chamado na abertura, **fora** do adapter — é
  API de navegador, não de banco.
- O `path` é parâmetro, não constante: `flashcards` em produção,
  `flashcards_debug` na tela de viagem no tempo.

### Contrato do MVVM com `ValueNotifier`

Regras que devem ser seguidas em toda feature:

1. A **View** não contém regra de negócio. Ela lê `viewModel.state` por
   `ValueListenableBuilder` e chama métodos do ViewModel.
2. O **ViewModel** estende `ChangeNotifier`? **Não** — expõe um ou mais
   `ValueNotifier<T>` públicos e finais. Isso evita reconstrução da tela inteira
   quando só um pedaço mudou (ex.: o cronômetro do round tem seu próprio
   notifier, separado do estado do cartão).
3. O ViewModel **não importa `flutter/material.dart`**. Só `foundation.dart`
   (que traz `ValueNotifier`). Isso mantém o ViewModel testável sem
   `WidgetTester`.
4. O ViewModel recebe dependências pelo construtor; quem resolve no `get_it` é a
   View (ou a rota), nunca o próprio ViewModel — assim o teste injeta fakes sem
   tocar no locator.
5. Todo estado de tela é uma **union do freezed** (`loading | ready | error`),
   não uma pilha de booleanos (`isLoading`, `hasError`).

```dart
// exemplo do contrato
@freezed
sealed class SessionState with _$SessionState {
  const factory SessionState.loading() = SessionLoading;
  const factory SessionState.showingQuestion(Card card, int roundSecondsLeft) = ShowingQuestion;
  const factory SessionState.showingAnswer(Card card, Map<Rating, Duration> previews) = ShowingAnswer;
  const factory SessionState.roundBreak(Subject finished, Subject next) = RoundBreak;
  const factory SessionState.scoreboard(SessionScore score) = Scoreboard;
}

class SessionViewModel {
  SessionViewModel(this._scheduler, this._sessionPolicy, this._cards, this._clock);

  // notifiers separados: o tick de 1 s não reconstrói o cartão
  final ValueNotifier<SessionState> state = ValueNotifier(const SessionState.loading());
  final ValueNotifier<Duration> elapsedOnCard = ValueNotifier(Duration.zero);
  // …
}
```

### Convenções de código

**Busca em coleção: `firstWhereOrNull`, nunca `firstWhere`.**
Usar `package:collection`. Neste app "não achou" é um **estado de negócio
previsto**, não um erro — e `firstWhere` lançaria `StateError: No element`
exatamente nos caminhos que a tabela _Quando dá errado_ dos requisitos descreve
como normais.

```dart
// ✗ lança StateError quando nada vence — que é um caso previsto
final next = dueCards.firstWhere((c) => c.subject == subject);

// ✓ null é resposta legítima; o chamador decide o que fazer
final next = dueCards.firstWhereOrNull((c) => c.subject == subject);
if (next == null) return _dueCardsPolicy.anticipateToday(subject);
```

Pontos onde isso aparece e o significado do `null`:

| Chamada | `null` significa |
|---|---|
| `DueCardsPolicy.nextDueCard(subject)` | Nada vencido no assunto → **antecipar o que vence hoje** (H8) |
| `RoundQueue.next()` | Round esgotado → **perguntar se quer estender** (H8) |
| `CardRepository.byId(id)` | Cartão não existe → na importação, é **cartão novo** (H16) |
| `MockInterviewService.pick(subject)` | Assunto sem cartão disponível → **redistribuir a cota** entre os demais (H10) |
| `SettingsRepository.previousParams()` | Nunca houve ajuste → **esconder o botão "voltar ao anterior"** (Autoajuste) |

O tipo de retorno deve ser **`Card?` explícito**, não `Card` com exceção
documentada — assim o compilador obriga o chamador a tratar o caso que os
requisitos já preveem.

> Vale o mesmo para `singleWhereOrNull`, `lastWhereOrNull` e `elementAtOrNull`.
> Nenhuma variante que lança deve aparecer em `domain/`.

### Onde mora cada regra de negócio

**Toda regra de negócio fica fora da View e do ViewModel.** O ViewModel orquestra
e traduz para estado de tela; quem decide é o domínio.

Dois testes para classificar qualquer lógica nova:

1. _"Isso mudaria se o app fosse de terminal?"_ — se **não**, é domínio.
2. _"Se isso estiver errado, o usuário estuda errado?"_ — se **sim**, é domínio e
   precisa de teste unitário sem `WidgetTester`.

| Regra (documento de requisitos) | Classe de domínio |
|---|---|
| Os 4 botões → intervalo | `CardScheduler` |
| Teto móvel (a fórmula) | `MovingCeiling` |
| Ciclo curto 15 min → 1 h → 4 h → 1 d | `CardScheduler` |
| Espalhamento e nivelamento | `CardScheduler` |
| Cartão firme / pronto | `Card.isFirm` / `Card.isReady` |
| Cartão-problema (4 erros no total) | `Card.isProblem` |
| Autoajuste + reversão de parâmetros | `FsrsOptimizer` |
| Antecipação (só o que vence hoje) | `DueCardsPolicy` |
| Aviso dos 80% e carga inicial | `ContentIntakePolicy` |
| Simulado: sorteio equilibrado | `MockInterviewService` |
| Teto de 60 s no tempo por cartão | `TimeOnCardPolicy` |
| Round de 5 min, sessão de 5 rounds, pausa que congela tudo | `SessionPolicy` |
| Formato Markdown e prévia de importação | `MarkdownParser` / `ImportPreview` |
| Calibração (previsto × real) | `Calibration` |
| Previsão de carga dos próximos 7 dias | `LoadForecast` |

> Os dois últimos são **cálculo**, não desenho. O widget do painel recebe a série
> pronta; se a conta da calibração morar no `DashboardViewModel`, o indicador que
> audita o app deixa de ser testável isoladamente.

**O que fica no ViewModel:** sequência de telas, tradução de resultado do domínio
para `XState`, ciclo de vida de `Timer`/`Isolate`, chamadas a repositórios.
**Nunca** um `if` sobre `stability`, `lapses` ou datas de vencimento.

```dart
Future<void> answer(Rating rating) async {
  final updated = _scheduler.apply(_currentCard, rating, _clock.now()); // domínio decide
  await _cards.save(updated);
  await _reviews.append(ReviewLog.from(_currentCard, rating, _clock.now()));

  final next = _roundQueue.next();                    // Card? — firstWhereOrNull
  state.value = next == null                          // null = round esgotado
      ? SessionState.roundBreak(_current, _nextSubject)
      : SessionState.showingQuestion(next, _secondsLeft);
}
```

⚠️ **Duas regras que parecem de tela e não são:**

- **Cronômetro** — o `Timer` de 1 s é infraestrutura (ViewModel), mas "round dura
  5 minutos", "a pausa congela cartão + round + sessão" e "acima de 60 s descarta
  o tempo" são requisitos 8 e 11 → `SessionPolicy` / `TimeOnCardPolicy`.
- **Prévia de importação** — o parser devolve `ImportPreview(válidos,
  problemáticos)` como dado puro; a View apenas pinta.

> **Regra de revisão de código:** nenhum arquivo em `domain/` **nem em `data/`**
> pode importar `package:flutter/*` — nem `foundation.dart`. Vale como regra de
> lint: garante o teste 1 automaticamente e mantém as duas camadas testáveis em
> Dart puro. Consequência prática: repositórios expõem `Stream`/`Future`, nunca
> `ValueNotifier`. Quem cria notifier é o ViewModel.

### Registro no `get_it`

```dart
Future<void> setupLocator() async {
  // a factory é o ponto de troca: databaseFactoryMemory no teste
  final db = await SembastAdapter.open(databaseFactoryWeb, 'flashcards');

  getIt
    ..registerSingleton<Clock>(const SystemClock())
    ..registerSingleton<AppDatabase>(db)
    ..registerLazySingleton<CardRepository>(() => CardRepository(getIt(), getIt()))
    ..registerLazySingleton<ReviewLogRepository>(() => ReviewLogRepository(getIt()))
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepository(getIt()))
    ..registerLazySingleton<BackupRepository>(() => BackupRepository(getIt()))

    // domínio — singletons sem estado próprio
    ..registerLazySingleton<FsrsGateway>(() => FsrsAdapter(getIt()))
    ..registerLazySingleton<MovingCeiling>(() => MovingCeiling(getIt(), getIt()))
    ..registerLazySingleton<CardScheduler>(() => CardScheduler(getIt(), getIt(), getIt()))
    ..registerLazySingleton<SessionPolicy>(SessionPolicy.new)
    ..registerLazySingleton<DueCardsPolicy>(() => DueCardsPolicy(getIt()))
    ..registerLazySingleton<ContentIntakePolicy>(() => ContentIntakePolicy(getIt(), getIt()))
    ..registerLazySingleton<TimeOnCardPolicy>(TimeOnCardPolicy.new)
    ..registerLazySingleton<MockInterviewService>(() => MockInterviewService(getIt()))
    ..registerLazySingleton<FsrsOptimizer>(() => FsrsOptimizer(getIt(), getIt()))
    ..registerLazySingleton<MarkdownParser>(MarkdownParser.new)

    // ViewModels são factory: um por tela aberta, descartado no dispose
    ..registerFactory(() => SessionViewModel(getIt(), getIt(), getIt(), getIt()))
    ..registerFactory(() => ImportViewModel(getIt(), getIt(), getIt()))
    ..registerFactory(() => DashboardViewModel(getIt(), getIt(), getIt()))
    ..registerFactory(() => MockInterviewViewModel(getIt(), getIt()))
    ..registerFactory(() => CardsViewModel(getIt()))
    ..registerFactory(() => BackupViewModel(getIt()));
}
```

> **`Clock` injetável não é preciosismo aqui.** O teto móvel, o ciclo curto de
> horas e o prazo de 09/09 são todos função da data. Sem um relógio injetável,
> não há como testar "o que acontece no dia 25" a não ser mexendo no relógio da
> máquina. Proibir `DateTime.now()` fora do `Clock` é regra de revisão de código.

---

## Persistência

**`sembast_web`** — banco NoSQL de documentos sobre **IndexedDB**.

### Por que esta escolha

| Critério | Consequência |
|---|---|
| Casa com o freezed | O sembast grava e lê `Map<String, dynamic>` — exatamente o que `toJson()`/`fromJson()` produzem. Sem modelo duplicado, sem conversor. |
| Volume real é pequeno | 100 cartões + ~2.200 revisões em 30 dias ≈ **300 KB**. Cabe em memória; índice de banco não acelera um `.where()` sobre 100 itens. |
| Peso no PWA | Zero asset extra. O drift exigiria `sqlite3.wasm` + worker (~1,3 MB) e headers COOP/COEP para OPFS — custo direto no primeiro carregamento em celular. |
| Requisito 14 sai pronto | `exportDatabase`/`importDatabase` do sembast produzem JSON legível, que é literalmente o arquivo de cópia de segurança. |

### Stores

| Store | Chave | Valor | Observação |
|---|---|---|---|
| `cards` | `id` do cartão (o `id:` do Markdown) | `Card.toJson()` | Contém o estado do FSRS: `stability`, `difficultyFsrs`, `dueAt`, `state`, `lapses` — e `introducedAt`, que controla a liberação diária (H16) |
| `reviews` | auto-incremento | `ReviewLog.toJson()` | Append-only. É a base do autoajuste e da calibração |
| `settings` | chave textual | valores diversos | Parâmetros FSRS ativos, **histórico de parâmetros anteriores**, data de início, data-alvo, contadores de revisão desde o último ajuste |
| `sessions` | `id` da sessão | `StudySession.toJson()` | Guarda a sessão em andamento (round atual, tempo restante) para retomada |

### Carregamento e escrita

- Na abertura, `CardRepository` carrega **todos os cartões em memória** e os
  mantém num cache interno, exposto por `List<Card> get all` e
  `Stream<List<Card>> get changes`. Todas as consultas (vencidos, por assunto,
  mapa de firmeza) são operações em memória.
  - ⚠️ **O repositório não expõe `ValueNotifier`.** `ValueNotifier` vem de
    `package:flutter/foundation.dart`; usá-lo aqui arrastaria o Flutter para
    dentro do `data/` e quebraria a mesma fronteira que o `domain/` respeita.
    **Quem converte `Stream` em `ValueNotifier` é o ViewModel** — é justamente o
    papel dele.
- Escritas são pontuais: cada resposta grava **um** `Card` atualizado e
  **um** `ReviewLog` novo. Não há reescrita em bloco.
- O log de revisões **não** é carregado inteiro na abertura — só quando o
  otimizador roda (então vai inteiro para o Isolate).

### Durabilidade — ponto crítico

O IndexedDB pode ser **despejado pelo navegador** sob pressão de disco, ou
apagado pelo usuário ao limpar dados de navegação. Duas medidas obrigatórias:

1. Chamar **`navigator.storage.persist()`** na primeira abertura, para pedir ao
   navegador que marque o armazenamento como persistente. Não é garantia, mas
   reduz drasticamente o risco de despejo.
2. O requisito 14 (cópia de segurança) é a **única** garantia real. A tela do
   painel deve exibir há quantos dias o último backup foi baixado.

---

## Modelo de domínio

```dart
@freezed
sealed class Card with _$Card {
  const factory Card({
    required String id,              // vem do `id:` do Markdown
    required String question,
    required String answer,
    required String subject,         // assunto → nome do round
    required Difficulty difficulty,  // básico | intermediário | avançado
    // estado FSRS
    required double stability,       // dias de memória — base de "firme"/"pronto"
    required double difficultyFsrs,  // 1..10, do FSRS (não confundir com o campo acima)
    required CardState state,        // novo | aprendendo | revisão | reaprendendo
    required int learningStep,       // 0..3 — posição no ciclo curto
    required DateTime? dueAt,
    required int lapses,             // total de "errei" — 4 marca cartão-problema
    required int reps,
    required DateTime? lastReviewedAt,
    // entrada de conteúdo (H16)
    required DateTime importedAt,    // quando entrou na coleção
    required DateTime? introducedAt, // null = importado mas ainda NÃO liberado
  }) = _Card;

  factory Card.fromJson(Map<String, Object?> json) => _$CardFromJson(json);
}

@freezed
sealed class ReviewLog with _$ReviewLog {
  const factory ReviewLog({
    required String cardId,
    required DateTime reviewedAt,
    required Rating rating,            // again | hard | good | easy
    required double elapsedDays,       // intervalo real desde a última revisão
    required double predictedRetention, // o que o app previu — alimenta a calibração
    required Duration? timeOnCard,     // null se > 60 s (descartado da média)
    required ReviewSource source,      // session | simulado
  }) = _ReviewLog;

  factory ReviewLog.fromJson(Map<String, Object?> json) => _$ReviewLogFromJson(json);
}

enum Rating { again, hard, good, easy }   // ← os 4 botões, nesta ordem
```

**Mapa dos 4 botões** (requisito 2 → FSRS):

| Botão na tela | `Rating` | Efeito |
|---|---|---|
| Errei | `again` | Volta ao passo 0 do ciclo curto (15 min), `lapses++` |
| Lembrei só uma parte | `hard` | Intervalo menor que o cálculo padrão |
| Lembrei com esforço | `good` | Intervalo padrão do FSRS |
| Sabia de cor | `easy` | Intervalo maior que o padrão |

**Linguagem ubíqua — termo do cliente → identificador no código:**

| Cliente | Código |
|---|---|
| Cartão | `Card` |
| Coleção | `Collection` (a lista completa de `Card`) |
| Assunto | `subject` (String) |
| Sessão / Round | `StudySession` / `Round` |
| Cartão vencido | `dueCards` (`dueAt <= now`) |
| Teto móvel | `MovingCeiling` |
| Cartão firme | `card.isFirm` → `stability >= 7` |
| Cartão pronto | `card.isReady` → `stability >= max(1, diasAté(09/09))` |
| Cartão-problema | `card.isProblem` → `lapses >= 4` |
| Firmar um cartão | transição `isFirm` false → true |

---

## O núcleo de agendamento

A ordem das operações é **normativa** e está no requisito 4 + regra
_Espalhamento e nivelamento_. Implementar exatamente nesta sequência:

```dart
DateTime scheduleNext(Card card, Rating rating, DateTime now) {
  // 1. ciclo curto tem precedência absoluta enquanto o cartão não graduou
  if (card.state.isLearning || rating == Rating.again) {
    return now.add(_learningSteps[nextStep]);   // 15min → 1h → 4h → 1d
  }

  // 2. FSRS calcula o intervalo ideal (adapter chama reviewCard e extrai o Duration)
  var interval = _fsrs.nextInterval(card, rating, now);

  // 3. espalhamento ±10%
  interval = _fuzz(interval);

  // 4. nivelamento: entre as datas candidatas, a de menor carga
  var date = _loadBalance(now.add(interval));

  // 5. TETO CORTA POR ÚLTIMO — tem sempre a palavra final
  final ceiling = _ceiling.forDate(now);
  final maxDate = now.add(ceiling);
  return date.isAfter(maxDate) ? maxDate : date;
}
```

> ⚠️ **O passo 5 não pode ser movido.** Espalhamento e nivelamento empurram a
> data para frente; se o teto agisse antes deles, um cartão com teto de 3 dias
> poderia acabar em 3,3 dias. Escreva o teste que prova isso.

### Como configurar o `package:fsrs` — e o que NÃO usar dele

O FSRS trabalha em **dias decimais** por natureza (a `stability` é um double: 2,7
dias = 65 h), então o ciclo curto em horas é configuração nativa, não gambiarra:

```dart
// API conferida no fsrs 2.0.1 instalado (10/08/2026)
final scheduler = Scheduler(
  learningSteps:   const [Duration(minutes: 15), Duration(hours: 1),
                          Duration(hours: 4),    Duration(days: 1)],
  relearningSteps: const [Duration(minutes: 15)],
  desiredRetention: 0.90,
  enableFuzzing: false,     // DESLIGADO — nome real do parâmetro
  maximumInterval: 36500,   // neutralizado — ver abaixo
);
```

**A API real do pacote (2.0.1), que difere do que se supôs:**

```dart
({fsrs.Card card, fsrs.ReviewLog reviewLog}) reviewCard(
  fsrs.Card card, fsrs.Rating rating, {DateTime? reviewDateTime, int? reviewDuration});

double getCardRetrievability(fsrs.Card card, {DateTime? currentDateTime});
```

- **Não existe `nextInterval(...)`.** `reviewCard` devolve um *record* com o
  cartão já atualizado — a data está em `card.due`, e `stability`/`difficulty`
  são `double?` **mutáveis**. O adapter extrai o `Duration` de
  `card.due.difference(now)` e devolve isso ao passo 2 do pipeline.
- **`desiredRetention` é do `Scheduler`, não da chamada.** Não há como pedir
  retenção diferente por cartão.
- ⚠️ **`reviewDateTime` precisa ser UTC** — o pacote lança `ArgumentError` se não
  for. O `Clock` continua devolvendo hora local (o teto e o prazo são locais); a
  conversão `toUtc()` na entrada e `toLocal()` na saída acontece **só dentro do
  `fsrs_adapter.dart`**. Vazar UTC para o domínio deslocaria as datas em 3 h.
- ⚠️ **Colisão de nomes:** o pacote exporta `Card`, `ReviewLog`, `Rating` e
  `State` — todos homônimos dos nossos. Importar **sempre** com prefixo:
  `import 'package:fsrs/fsrs.dart' as fsrs;`. Como só o adapter importa o
  pacote, a colisão fica confinada a um arquivo.
- ✅ **`lowerBoundsParameters` / `upperBoundsParameters` são exportados** (21
  pesos). É exatamente a validação de faixa que o autoajuste precisa: parâmetro
  fora dos limites → descarta o treino e mantém os anteriores, sem inventar
  critério próprio. `Scheduler` já valida no construtor e lança `ArgumentError`.
- **`Scheduler.customRandom(Random)`** existe e é `@visibleForTesting` — permite
  fixar a semente do fuzz do pacote. Não precisamos dele (o fuzz fica desligado),
  mas serve se um teste quiser comparar contra o comportamento padrão.

⚠️ **Truncamento sub-diário — impacto na calibração.** Tanto
`getCardRetrievability` quanto o cálculo interno de `daysSinceLastReview` usam
`.inDays`, que **trunca**: uma revisão 4 h após a anterior vira `elapsedDays = 0`
e a retrievability prevista vira **1,0**. Durante o ciclo curto (15 min → 4 h),
que é quase todo o começo do prazo, `ReviewLog.predictedRetention` viria
constante em 1,0 — e a calibração, único indicador que audita o app, mostraria
uma linha reta sem significado. **O adapter calcula `predictedRetention` por
conta própria**, com dias decimais:

```dart
double retrievabilityAt(fsrs.Card card, DateTime now) {
  final elapsedDays = now.toUtc().difference(card.lastReview!).inMinutes / 1440.0;
  return math.pow(1 + _factor * elapsedDays / card.stability!, _decay).toDouble();
}
```

**Três recursos do pacote ficam desligados de propósito:**

| Recurso | Motivo de não usar |
|---|---|
| `maximumInterval` | É **inteiro em dias** — não expressa "teto de 2,4 dias". O teto móvel é decimal e roda no passo 5, depois do pacote |
| `enableFuzzing` | O pacote espalha **antes** do teto; isso furaria o teto. O espalhamento é o passo 3 do nosso pipeline |
| Otimizador | Não existe em Dart — é o código próprio da seção _Autoajuste_ |

**Atrito conhecido:** para cartões já graduados, o pacote arredonda o intervalo
para dias inteiros. Impacto pequeno, porque durante quase todo o prazo o
intervalo do FSRS é **maior** que o teto, e quem define a data é o nosso clamp
decimal. Se for preciso precisão sub-diária também abaixo do teto, ler a
`stability` devolvida pelo pacote e recalcular o intervalo:

```dart
double intervalFor(double stability, double retention) =>
    (stability / FACTOR) * (math.pow(retention, 1 / DECAY) - 1);
```

**Acoplamento a isolar:** o pacote tem o próprio modelo de cartão, diferente do
nosso `Card` do freezed. O mapeamento ida-e-volta vive em
**`domain/scheduling/fsrs_adapter.dart`** — arquivo próprio, não dentro do
`CardScheduler`. É o único lugar do projeto autorizado a importar
`package:fsrs`, e é o que torna real a promessa de trocar o pacote mexendo em um
arquivo só.

> ✅ Assinaturas **conferidas no `fsrs 2.0.1`** instalado em 10/08/2026. Ao subir
> de versão, reconferir — o adapter é o único arquivo que precisa mudar.

### Teto móvel

```dart
class MovingCeiling {
  MovingCeiling(this._settings, this._cards);

  final SettingsRepository _settings;   // startDate (10/08) e targetDate (09/09)
  final CardRepository _cards;          // origem do collectionSize

  static const _c0 = 20.0;    // C₀ — revisões/dia no dia 0
  static const _c1 = 100.0;   // C₁ — revisões/dia no dia 30
  static const _t  = 30;      // T  — dias de prazo

  Duration forDate(DateTime now) {
    final t = now.difference(_settings.startDate).inDays.clamp(0, _t);

    final load = _c0 + (_c1 - _c0) * t / _t;              // carga(t) = 20 + 2,67·t
    final days = math.max(1.0, _collectionSize / load);   // teto(t) = max(1, N ÷ carga)

    return Duration(minutes: (days * 24 * 60).round());   // minutos preservam o decimal
  }
}
```

Três detalhes que não podem ser "simplificados" depois:

- **`Duration` em minutos, não em dias.** `Duration(days: 2)` perderia o `,4` de
  "2,4 dias". A conta vira minutos antes de virar `Duration` (2,4 d = 3.456 min).
- **`clamp(0, 30)` é o comportamento pós-prazo.** Depois de 09/09 o `t` para em
  30, a carga trava em 100 e o teto fica no piso de 1 dia — exatamente o padrão
  escolhido até haver nova data-alvo (H13).
- **`max(1.0, …)` é o piso.** Sem ele, coleção pequena produziria teto abaixo de
  1 dia e o cartão apareceria duas vezes no mesmo dia — proibido.

**`_collectionSize` é o tamanho REAL da coleção** (decidido em 10/08/2026), lido
do `CardRepository` a cada chamada — não a constante 100. O que a fórmula protege
é a carga diária; o teto é consequência. Importar 50 cartões no dia 10 leva o
teto de 2,1 para 3,2 dias e mantém a carga na rampa, em vez de subir o estudo
diário de ~47 para ~70 revisões em silêncio.

> Conta apenas cartões **liberados** (`introducedAt != null`). Cartões importados
> e ainda retidos pela `ContentIntakePolicy` não geram revisão, então não podem
> inflar o teto de quem já está em estudo.

### Autoajuste (otimizador)

Gatilho: **400 revisões E 7 dias de uso** (as duas condições), depois a cada
**200 revisões novas**.

```
   ReviewLogRepository.all()   →   treino em fatias (main thread)
                                        │
                            gradiente descendente sobre a
                            log-loss entre retenção prevista
                            e resultado real (acerto/erro)
                                        │
                      novos parâmetros  →  SettingsRepository
                                           (empilhando os anteriores)
```

⚠️ **`dart:isolate` NÃO funciona em Flutter Web.** Código compilado para
JavaScript/WASM não tem isolates: `Isolate.run` lança `UnsupportedError`. Não é
limitação de tipos serializáveis — é ausência total do recurso. O treino roda em
**fatias na thread principal**, cedendo o controle entre elas:

```dart
Future<FsrsParams> optimize(List<ReviewLog> logs) async {
  var params = _current;
  for (var epoch = 0; epoch < _epochs; epoch++) {
    params = _gradientStep(params, logs);
    await Future.delayed(Duration.zero);   // devolve o frame ao navegador
  }
  return params;
}
```

- **Por que isso basta aqui:** ~2.200 amostras e poucas dezenas de épocas são
  segundos de CPU. Fatiado com `Future.delayed(Duration.zero)` a cada época, o
  navegador desenha entre elas e a UI não trava.
- **Se ficar lento**, a saída é um **Web Worker de verdade**: um `main` Dart
  separado compilado para JS próprio e instanciado com `Worker(...)`, trocando
  mensagens JSON. Custa uma entrada de build a mais — só fazer se medir
  necessidade.
- Rodar o treino **fora da sessão de estudo** (na abertura do painel ou ao fim
  da sessão), nunca no meio de um round.
- **Sempre reversível:** cada ajuste empilha os parâmetros anteriores em
  `settings`. A tela de calibração precisa de um botão "voltar ao anterior".
- Se o treino falhar ou produzir parâmetros fora de faixa, **mantém os
  anteriores em silêncio** e registra o erro — nunca aplica parâmetro suspeito.

---

## Histórias de usuário (1ª versão)

### H1 — Pergunta com resposta escondida `(origem: Requisito Essencial 1)`

**Como** quem estuda, **quero** ver só a pergunta primeiro, **para** ser forçado
a tentar lembrar antes de conferir.

**Critérios de aceitação:**
- **Dado** um cartão aberto na sessão, **quando** a tela carrega, **então** só a
  pergunta é renderizada — a resposta não está no widget tree.
- **Dado** a pergunta na tela, **quando** o usuário toca "mostrar resposta",
  **então** a resposta aparece.

**Nota técnica:** a resposta não deve estar apenas invisível (`Opacity`,
`Visibility`) — deve não estar montada, para não vazar por seleção de texto ou
inspeção acidental.

---

### H2 — Quatro botões de resposta `(origem: Requisito Essencial 2)`

**Como** quem estuda, **quero** classificar o quanto lembrei em 4 níveis,
**para** o app calcular quando o cartão volta.

**Critérios de aceitação:**
- **Dado** um cartão com a resposta escondida, **quando** ela ainda não foi
  revelada, **então** os 4 botões não aparecem.
- **Dado** a resposta revelada, **quando** o usuário aperta cada um dos 4
  botões, **então** cada um produz uma data de retorno **diferente**.

**Regras envolvidas:** _Os 4 botões de resposta_ · _Como o app decide quando
cada cartão volta_ (mapa `Rating` na seção Modelo de domínio).

---

### H3 — Importar conteúdo por arquivo ou colando texto `(origem: Requisito Essencial 3)`

**Como** quem estuda, **quero** trazer perguntas de fora em Markdown, **para**
montar a coleção sem digitar cartão a cartão.

**Critérios de aceitação:**
- **Dado** uma lista de 20 perguntas colada na caixa, **quando** confirma a
  importação, **então** aparecem 20 cartões com assunto e dificuldade
  preenchidos.
- **Dado** uma resposta com bloco ` ```dart `, **quando** o cartão é exibido,
  **então** o código aparece em **fonte monoespaçada**, com **indentação e
  quebras preservadas**, **realce de sintaxe por tipo** (palavras-chave, strings,
  comentários), em **bloco com fundo destacado** e com **rolagem horizontal**
  própria — linha longa rola, não quebra nem estoura a tela.

**Notas técnicas:**
- Parser corta o texto nos separadores `---` e processa **cada bloco de forma
  independente** — um bloco inválido não pode invalidar os demais.
- Realce de sintaxe: pacote de highlight com tema; o `SingleChildScrollView`
  horizontal envolve o bloco de código, nunca o cartão inteiro.

**Tratamento de erros:** _"A importação traz uma linha que o app não consegue
separar"_ → ver H16.

---

### H4 — Agendamento FSRS com ciclo curto e teto móvel `(origem: Requisito Essencial 4)`

**Como** quem estuda, **quero** que cada cartão volte na hora certa, **para**
não revisar cedo demais (perda de tempo) nem tarde demais (esquecimento).

**Critérios de aceitação:**
- **Dado** qualquer cartão, **quando** o usuário aperta "errei", **então** ele é
  reagendado para **15 minutos** à frente.
- **Dado** o dia 0 do prazo, **quando** qualquer cartão é agendado, **então**
  nenhuma data fica além de **~5 dias**.
- **Dado** uma data a partir de **04/09/2026**, **quando** qualquer cartão é
  agendado, **então** nenhuma data fica além de **1 dia**.

**Regras envolvidas:** _Horas × dias — o teto que encolhe_ · _Ciclo curto do
cartão novo ou errado_ · _Cartão firme_.

**Nota técnica:** o teto limita a **data agendada**, nunca a `stability`
calculada. Um cartão pode estar marcado para amanhã por causa do teto e ainda
assim ser "pronto". Os indicadores leem `stability`, não `dueAt`.

---

### H5 — Espalhar e nivelar a carga `(origem: Requisito Essencial 5)`

**Como** quem estuda, **quero** que um bloco importado junto não vença sempre no
mesmo dia, **para** não ter dias cheios seguidos de dias vazios.

**Critérios de aceitação:**
- **Dado** a importação dos 100 cartões de uma vez, **quando** a tela de
  importação exibe a prévia, **então** as datas de primeira revisão **não são
  todas idênticas** — aparecem distribuídas entre dias próximos, verificável ali
  mesmo, sem esperar semanas.

**Regras envolvidas:** _Espalhamento e nivelamento da carga_ — inclusive a ordem
obrigatória das 4 operações.

---

### H6 — Painel de avanço com sete indicadores `(origem: Requisito Essencial 6)`

**Como** quem estuda, **quero** ver o progresso mexer todo dia, **para** ter
sensação de avanço e saber se o método está funcionando.

**Critérios de aceitação:** ao fim de um dia de estudo, o painel mostra:

| Indicador | Formato exigido |
|---|---|
| Cartões que firmaram hoje | Contagem de cartões que passaram a `stability >= 7` |
| Acerto real × alvo | Percentual acertado contra os 90% mirados |
| Mapa por assunto | Por assunto, quantos cartões estão "prontos" |
| Placar da sessão | Desempenho em cada um dos 5 rounds |
| **Calibração** | **Gráfico de linha** com previsto e real lado a lado ao longo dos dias |
| **Previsão de carga** | **Gráfico de barras dos próximos 7 dias**, uma barra por dia |
| **Tempo médio por cartão** | **Média geral + quebra por assunto** |

**Nota técnica:** a calibração é o único indicador que **audita o próprio app** —
ela compara `ReviewLog.predictedRetention` com o acerto real. Não pode ser
derivada dos mesmos parâmetros que está auditando.

---

### H7 — Cartões-problema `(origem: Requisito Essencial 7)`

**Como** quem estuda, **quero** ser avisado quando um cartão está mal escrito,
**para** reescrevê-lo em perguntas menores em vez de brigar com ele para sempre.

**Critérios de aceitação:**
- **Dado** um cartão errado pela **4ª vez no total** (não precisam ser
  seguidas), **quando** o erro é registrado, **então** o cartão recebe marca
  visível e o app oferece quebrá-lo em perguntas menores.

**Nota técnica:** depende de `lapses` acumulado, não de sequência. Quando o
usuário reescreve e reimporta, o `id:` preserva o histórico — é o único caminho
que faz esta história ter valor (ver H15/H16).

---

### H8 — Sessão de 25 min em 5 rounds de 5 min `(origem: Requisito Essencial 8)`

**Como** quem estuda, **quero** estudar em blocos curtos por assunto, **para**
manter concentração e cobrir os 5 assuntos.

**Critérios de aceitação:**
- **Dado** os 5 assuntos escolhidos manualmente, **quando** a sessão começa,
  **então** rodam 5 rounds de 5 minutos, um por assunto.
- **Dado** a virada de um round, **quando** ela ocorre, **então** aparece uma
  **tela silenciosa** (sem som) dizendo qual assunto acabou e qual começa,
  aguardando confirmação.

**Tratamento de erros:**
- Round acaba com cartões vencidos sobrando → avisa quantos e **pergunta se quer
  estender**.
- Nenhum cartão vencido do assunto → **adianta só os que vencem ainda hoje**
  (regra _Antecipação_).
- **App fechado no meio de um round** → ao voltar, **continua de onde parou**:
  mesmo round, mesmo tempo restante (regra _Sessão interrompida_).
  - **Dado** uma sessão fechada no round 3 com 2 min restantes, **quando** o app
    reabre, **então** ele retoma no round 3 com 2 min — não recomeça a sessão.
  - Nota técnica: é a razão de existir o store `sessions`. O estado é gravado a
    cada resposta e a cada troca de round; não depende de evento de fechamento
    do navegador, que não é confiável.

**Nota técnica:** cronômetro do round num `ValueNotifier<Duration>` separado do
estado do cartão, para o tick de 1 s não reconstruir o cartão inteiro.

---

### H9 — PWA offline `(origem: Requisito Essencial 9)`

**Como** quem estuda, **quero** instalar o app na tela do celular e usar sem
internet, **para** estudar em qualquer lugar.

**Critérios de aceitação:**
- **Dado** o app instalado na tela do celular, **quando** o aparelho está em modo
  avião, **então** é possível rodar uma sessão inteira **e importar uma lista**,
  sem nenhuma mensagem de erro.

**Notas técnicas:** manifest com ícones e `display: standalone`; service worker
com cache dos assets; **nenhuma requisição de rede** no caminho crítico —
inclusive fontes e o tema de realce de sintaxe devem estar embutidos no bundle.

---

### H10 — Simulado de entrevista `(origem: Requisito Essencial 10)`

**Como** quem estuda, **quero** um modo que sorteia perguntas de todos os
assuntos, **para** treinar o formato real de entrevista.

**Critérios de aceitação:**
- **Dado** um simulado de 20 perguntas, **quando** ele roda, **então** as
  perguntas vêm equilibradas entre os assuntos.
- **Dado** o fim do simulado, **quando** o placar aparece, **então** a **hora de
  voltar de todos os cartões** e o **mapa por assunto** permanecem inalterados.
- **Dado** o fim do simulado, **quando** o placar aparece, **então** ele mostra o
  **acerto por assunto naquele simulado** e a comparação com os anteriores.

**Nota técnica — placar separado do mapa** (decidido em 10/08/2026): o simulado
grava `ReviewLog` com `source = simulado`, e **nada mais**. Não toca `stability`,
`dueAt`, `state` nem `lapses`.

| Indicador | Lê | Responde |
|---|---|---|
| Mapa por assunto | `Card.stability` | "eu lembraria disso em 09/09?" |
| Placar do simulado | `ReviewLog` com `source = simulado` | "como fui numa prova real?" |

A divergência entre os dois é sinal de diagnóstico: **mapa verde com simulado
ruim** = cartões decorados sem o assunto conectado. Fundir os dois apagaria esse
sinal — e contaminaria a calibração, que só pode olhar revisões agendadas.

O botão **"ver assuntos fracos"** do tempo ocioso (H12) lê **os dois**.

---

### H11 — Cronômetro controlável `(origem: Requisito Essencial 11)`

**Como** quem estuda, **quero** ligar e desligar o relógio, **para** decidir
quando quero pressão de tempo.

**Critérios de aceitação:**
- **Dado** o relógio ligado, **quando** o cartão está na tela, **então** o tempo
  corre visivelmente; ao pausar, ele congela.
- **Dado** um cartão deixado **5 minutos** na tela, **quando** é respondido,
  **então** esse tempo **não entra** na média (teto de 60 s).
- **Dado** qualquer resposta, **quando** o cartão é reagendado, **então** o tempo
  **não influencia** a data — só o botão apertado.

**Nota técnica:** a pausa congela **tudo** — cronômetro do cartão, os 5 minutos
do round e a contagem da sessão.

---

### H12 — Tempo ocioso `(origem: Requisito Essencial 12)`

**Como** quem estuda, **quero** saber o que fazer quando zerei o dia, **para**
não perder tempo livre.

**Critérios de aceitação:**
- **Dado** nada vencido e nada para antecipar, **quando** o app detecta isso,
  **então** mostra "você está em dia" e **três botões lado a lado**: importar
  mais perguntas · fazer um simulado · ver os assuntos fracos.

---

### H13 — Acompanhar o prazo de 09/09/2026 `(origem: Requisito Essencial 13)`

**Como** quem estuda, **quero** que os intervalos apertem conforme o prazo
chega, **para** chegar em 09/09 lembrando de tudo.

**Critérios de aceitação:**
- **Dado** a última semana do prazo, **quando** qualquer cartão é agendado,
  **então** nenhum vai para mais de 1 dia.
- **Dado** 09/09/2026, **quando** o app abre, **então** ele mostra o mapa por
  assunto e **pergunta** se o usuário quer nova data-alvo ou seguir no piso de 1
  dia — não segue calado.

---

### H14 — Cópia de segurança `(origem: Requisito Essencial 14)`

**Como** quem estuda, **quero** baixar e restaurar todo o progresso, **para** não
perder o histórico se o navegador limpar os dados.

**Critérios de aceitação:**
- **Dado** a cópia baixada, **quando** os dados do navegador são limpos e o
  arquivo é restaurado, **então** os mesmos cartões reaparecem com o **mesmo
  histórico** e as **mesmas datas de retorno**.

**Nota técnica:** `exportDatabase(db)` → `jsonEncode` → download via
`AnchorElement`. Restauração é destrutiva: exige confirmação explícita. Incluir
número de versão do schema no arquivo.

---

### H15 — Botão "copiar template" `(origem: Requisito Essencial 15)`

**Como** quem estuda, **quero** copiar de uma vez o texto que explica o formato à
IA, **para** não descrever o formato de memória a cada importação.

**Critérios de aceitação:**
- **Dado** o botão tocado na tela de importação, **quando** o texto é colado no
  chat da IA sem edição, **então** o que a IA devolve entra no app **sem erro na
  prévia**.

**Conteúdo obrigatório do template:** explicação dos rótulos, do separador `---`
e do bloco de código, mais **2 cartões de exemplo preenchidos, um deles com
código**, e o campo **`id:` já presente** — é ele que preserva o histórico na
reimportação.

---

### H16 — Controle de entrada de conteúdo `(origem: Requisito Essencial 16)`

**Como** quem estuda, **quero** que os 100 primeiros cartões entrem aos poucos e
que o app me avise se eu importar demais, **para** não afogar a coleção.

**Critérios de aceitação:**
- **Dado** 100 cartões importados em 11/08, **quando** os dias passam, **então**
  ~20 cartões novos são liberados por dia até 15/08.
- **Dado** 60% de cartões firmes, **quando** o usuário tenta importar mais,
  **então** vê o aviso com a porcentagem atual **e consegue continuar assim
  mesmo**.

**Regras envolvidas:** _Ritmo de entrada de cartões novos_.

**Nota técnica — importar ≠ liberar.** Os 100 cartões entram no banco de uma vez
em 11/08, mas só ~20 por dia ficam disponíveis para estudo. O `Card` distingue os
dois momentos:

| Campo | Significa |
|---|---|
| `importedAt` | entrou na coleção (todos os 100 em 11/08) |
| `introducedAt` | **`null` = ainda não liberado**; preenchido no dia em que a `ContentIntakePolicy` o solta |

`ContentIntakePolicy.releaseToday()` escolhe o lote diário entre os cartões com
`introducedAt == null`. Sem essa distinção, a única saída seria adiar a
importação — o que quebraria H5 (o espalhamento é conferido **na tela de
importação**, com os 100 de uma vez).

⚠️ **Precedência:** a carga inicial (11/08 a 15/08) **ignora** a regra geral de
"reduzir a entrada quando estudou pouco". Escrever o teste que fixa essa
precedência — é o tipo de regra que se perde numa refatoração.

**Tratamento de erros:**
- Prévia de importação com **linhas problemáticas marcadas**, permitindo corrigir
  antes de confirmar; os cartões válidos entram normalmente.
- **Previsão de carga mostra acúmulo à frente** → a `ContentIntakePolicy`
  **segura sozinha a liberação de cartões novos** até normalizar, e **avisa que
  fez isso**. Não é silencioso: sem o aviso, o usuário veria a coleção parar de
  crescer sem entender por quê.
- **Estudou pouco nos últimos dias** → reduz a liberação diária, **exceto durante
  a carga inicial** (ver precedência abaixo).

---

## Ordem de implementação

A entrega é única, mas a **ordem importa**: o app precisa estar utilizável em
11/08 para a carga inicial começar. As histórias abaixo estão em ordem de
dependência — cada fatia deixa algo que roda.

```
  FATIA 1 — o app existe e recebe conteúdo
  ├─ infra: get_it · Clock · AppDatabase (sembast) · schemaVersion
  ├─ H3   importar Markdown + prévia
  ├─ H15  botão "copiar template"
  └─ H1   pergunta com resposta escondida
       ▸ entregável: dá para importar os 100 cartões e ler um a um

  FATIA 2 — o método funciona          ← o coração; nada depois disso conserta
  ├─ H2   os 4 botões → Rating
  ├─ H4   FsrsAdapter + ciclo curto + MovingCeiling
  ├─ H5   espalhamento e nivelamento (ordem das 5 operações)
  └─ H16  importedAt / introducedAt + ContentIntakePolicy
       ▸ entregável: estudo real, agendado corretamente

  FATIA 3 — a rotina diária
  ├─ H8   sessão 25 min · 5 rounds · retomada
  ├─ H11  cronômetro, pausa, teto de 60 s
  └─ H14  cópia de segurança          ← antes de acumular histórico, não depois
       ▸ entregável: o dia de estudo completo, com backup

  FATIA 4 — enxergar o avanço
  ├─ H6   painel: 7 indicadores (Calibration, LoadForecast)
  ├─ H7   cartões-problema
  ├─ H13  banner do prazo + pergunta em 09/09
  └─ H12  tempo ocioso
       ▸ entregável: a sensação de avanço em tempo real

  FATIA 5 — o que não bloqueia o dia 1
  ├─ H10  simulado (parcialmente bloqueado — ponto em aberto 2)
  ├─ H9   PWA: manifest, service worker, teste em modo avião
  └─ Autoajuste (só dispara com 400 revisões E 7 dias → ~18/08)
```

**Três precedências que não são óbvias:**

1. **H14 (backup) vem antes do painel, não depois.** Ele protege histórico; todo
   dia sem backup é histórico exposto a despejo do IndexedDB.
2. **O autoajuste pode ficar por último** — o gatilho é 400 revisões **e** 7
   dias, o que só acontece por volta de 18/08. Não bloqueia a abertura.
3. **H9 (PWA) é configuração, não feature** — mas o critério de aceitação é
   "modo avião", que só dá para testar com as fatias 1–3 prontas.

## Estratégia de testes

O documento manda "escrever o teste que prova isso" em quatro lugares. Aqui
estão eles, mais o que vale por todos.

### O teste que vale por todos: simulação dos 30 dias

```dart
test('30 dias inteiros respeitam o teto e a rampa', () async {
  final clock = FakeClock(DateTime(2026, 8, 11));
  final app   = buildDomain(clock: clock, cards: fixture100Cards());

  for (var day = 1; day <= 30; day++) {
    await app.releaseDailyCards();          // ContentIntakePolicy
    await app.answerAllDue(profile: 0.90);  // acerta 9 em cada 10

    expect(app.maxScheduledInterval, lessThanOrEqualTo(app.ceilingToday));
    expect(app.reviewsToday, closeTo(expectedLoad(day), tolerance));
    expect(app.duplicatesToday, isEmpty);   // ninguém aparece 2× no mesmo dia

    clock.advance(const Duration(days: 1));
  }

  expect(app.cardsIntroduced, 100);         // todos entraram até o 5º dia
});
```

Roda em milissegundos e responde a pergunta que o cliente não quer descobrir em
09/09: *"o método funciona?"*. Só é possível porque `Clock` é injetável e o
domínio não importa Flutter.

### Testes obrigatórios por regra

| # | O que provar | Por quê |
|---|---|---|
| 1 | **Nenhum agendamento excede o teto do dia** — para os 4 ratings, em 5 datas ao longo do prazo | É a promessa central do produto |
| 2 | **A ordem das 5 operações** — espalhamento empurrando além do teto ainda resulta em data cortada | O bug silencioso mais provável |
| 3 | **Precedência da carga inicial** — "estudou pouco" NÃO reduz a liberação entre 11/08 e 15/08 | Regra que some numa refatoração |
| 4 | **Ciclo curto** — errar em qualquer degrau volta ao passo 0 (15 min) | Requisito 4 |
| 5 | **`isReady` no último dia** — em 09/09 um cartão frágil **não** conta como pronto (piso de 1 dia) | O mapa por assunto existe para esse dia |
| 6 | **Simulado não reagenda** — `dueAt` de todos os cartões idêntico antes e depois | Requisito 10 |
| 7 | **Teto de 60 s** — tempo acima do teto sai da média, mas a revisão conta | Requisito 11 |
| 8 | **Backup ida e volta** — exportar, zerar o banco, importar, comparar cartão a cartão | Requisito 14 |

### Testes de parser (goldens)

O `MarkdownParser` recebe arquivos de fixture e compara com a saída esperada:

- arquivo bem formado com 20 cartões → 20 cartões, 0 problemas;
- **cartão 47 quebrado** → 99 válidos + 1 marcado (a promessa da prévia);
- bloco ` ```dart ` com indentação e linha longa → preservado byte a byte;
- reimportação com o mesmo `id:` → atualiza, **não duplica**, mantém histórico;
- reimportação **sem** `id:`, pergunta idêntica → reconhece pelo texto;
- reimportação sem `id:` com pergunta editada → entra como novo (comportamento
  esperado e documentado, não bug).

### O que NÃO precisa de teste automatizado

Widgets de gráfico e layout do painel. São verificação visual; testá-los com
golden de imagem custa mais do que protege num app de um usuário só.

## Modo viagem no tempo (ferramenta de desenvolvimento)

Tela escondida (rota `/debug`, sem link na navegação) com:

```
  ┌──────────────────────────────────────┐
  │  Data simulada:  11/08/2026  (dia 1) │
  │  [ +1 dia ]  [ +7 dias ]  [ reset ]  │
  │                                      │
  │  teto hoje ......... 4,4 dias        │
  │  carga prevista .... 23 revisões     │
  │  cartões liberados . 20 / 100        │
  │  [ responder tudo como "de cor" ]    │
  │  [ responder tudo como "errei" ]     │
  └──────────────────────────────────────┘
```

- Usa o mesmo `Clock` injetável: a tela troca `SystemClock` por `FakeClock` no
  `get_it`. **Nenhum código de produção sabe que isso existe.**
- Serve para validar a curva de carga e o mapa por assunto **no primeiro dia**,
  em vez de descobrir em 30.
- Deve operar sobre um banco separado (`flashcards_debug`), nunca sobre o real —
  senão o próprio teste corrompe o histórico que o app existe para proteger.

## Versionamento e migração de schema

```dart
class AppDatabase {
  static const schemaVersion = 1;

  static Future<Database> open() => databaseFactoryWeb.openDatabase(
        'flashcards',
        version: schemaVersion,
        onVersionChanged: (db, oldV, newV) async {
          for (var v = oldV; v < newV; v++) {
            await _migrations[v]!(db);   // migrações em cadeia, uma por versão
          }
        },
      );
}
```

- O **arquivo de backup carrega `schemaVersion`**. Ao restaurar: versão igual →
  importa; versão menor → aplica as migrações antes de importar; versão maior →
  **recusa com mensagem clara**, nunca tenta adivinhar.
- Cada migração é uma função pura sobre `Map` — testável sem banco.
- Toda mudança em modelo freezed que altere o JSON **exige** incrementar
  `schemaVersion` e escrever a migração. Sem isso, um backup de ontem quebra o
  app de amanhã — e o backup é a única proteção real contra despejo do
  IndexedDB.

## Backlog (Desejável / Futuro)

_Vazio por decisão do cliente: não haverá versão 2. Não existe lista de corte —
se algo atrasar, a entrega inteira espera._

## Fora de escopo

- **Gerar perguntas automaticamente** — nenhuma chamada a IA, nenhuma busca na
  internet. Todo conteúdo vem por importação.
- **Multiusuário** — sem cadastro, login, sincronização ou compartilhamento.
- **Correção automática da resposta** — o app não avalia texto nem áudio; quem
  julga o acerto é o usuário pelos 4 botões.
- **Modo véspera por entrevista** — recusado pelo cliente; o teto móvel cobre o
  mesmo terreno para o prazo inteiro.
- **Nuvem / backend** — não há servidor. Tudo no aparelho.

## Dados e volumetria

| | |
|---|---|
| Cartões iniciais | 100, em 5 assuntos (~20 cada) |
| Revisões no prazo | ~2.200 em 30 dias (~22 passadas pela coleção) |
| Pico diário | 100 revisões/dia na reta final (09/09) |
| Dias mais pesados | 11/08 a 16/08 — ~60 a 96 revisões/dia (carga inicial) |
| Tamanho em disco | ~300 KB de JSON no fim do prazo |
| Usuários simultâneos | 1 |
| Origem dos dados | Importação manual em Markdown (arquivo ou colagem) |

**Curva de carga** (de _Informações e volume_): U no começo — carga inicial
pesada (11/08–16/08), respiro curto (17/08–21/08), rampa linear até 09/09.
A **previsão de carga** do painel (H6) deve reproduzir essa curva.

⚠️ **Dia 0 é 10/08, mas o app abre em 11/08.** O desenvolvimento termina em
11/08, então a primeira importação é nesse dia. **`startDate` permanece
10/08/2026 e `targetDate` permanece 09/09/2026** — decisão do cliente de manter
a data-alvo fixa. Consequência: o app nasce no **dia 1**, com teto de **4,4
dias** em vez de 5,0, e a rampa tem 29 dias úteis em vez de 30. Nenhum ajuste de
fórmula é necessário; só não fixar em teste a expectativa de "5,0 dias no
primeiro dia de uso".

## Restrições

- **Prazo de produto:** 09/09/2026 governa o teto dos intervalos (não é prazo de
  desenvolvimento).
- **Um aparelho só**, offline-first, sem backend e sem sincronização.
- **Flutter Web** — sem `dart:ffi`, sem `dart:io`, sem `sqflite`, sem plugins
  que exijam código nativo.
- **Sem orçamento, integrações ou obrigações legais** — uso pessoal, nenhum dado
  de terceiros, nada que atraia LGPD.

## Glossário do domínio

- **Cartão**: uma pergunta com a resposta escondida.
- **Coleção**: o conjunto de todos os cartões.
- **Assunto**: o tema que marca cada cartão e dá nome a cada round.
- **Sessão**: bloco de 25 minutos — 5 rounds de 5 minutos.
- **Round**: pedaço de 5 minutos dentro da sessão, dedicado a um assunto.
- **Cartão vencido**: cartão cuja hora de revisar já chegou.
- **Teto móvel**: intervalo máximo permitido no momento —
  `max(1, N ÷ (20 + 2,67 × dias desde 10/08))`, nunca abaixo de 1 dia.
- **Prazo**: 09/09/2026.
- **Cartão firme**: o app calcula que a memória dura ao menos 1 semana.
- **Cartão pronto**: o app calcula que a memória dura até 09/09/2026 (alvo que
  aperta conforme a data chega).
- **Cartão-problema**: errado 4 vezes no total; provavelmente mal escrito.
- **Firmar um cartão**: passar de frágil para firme.

## Riscos e pontos de atenção

| # | Risco | Impacto | Mitigação |
|---|---|---|---|
| 1 | **Otimizador FSRS em Dart puro não tem referência pronta** para web | Alto — é o requisito com maior chance de estourar prazo | Isolar atrás de uma interface; app deve funcionar **inteiro** com os parâmetros padrão se o otimizador falhar. Validar o resultado contra o py-fsrs num dataset conhecido |
| 2 | **Despejo do IndexedDB pelo navegador** | Alto — perda total do histórico | `navigator.storage.persist()` + backup manual (H14) + aviso de "último backup há N dias" |
| 3 | **`_collectionSize` cresce e afrouxa o teto** — decidido: usa o tamanho real | Baixo/Médio — importar muito perto de 09/09 alonga intervalos | Contar só cartões liberados; o aviso dos 80% e a previsão de carga são as travas |
| 4 | **Calibração contaminada por revisões de simulado** | Médio — invalidaria o único indicador que audita o app | Filtrar `source == session` em `Calibration` e no otimizador; teste dedicado |
| 5 | **Ordem das 4 operações de agendamento** | Alto — furar o teto invalida a promessa central do produto | Teste dedicado provando que nenhum agendamento excede o teto do dia, para os 4 ratings |
| 6 | **`DateTime.now()` espalhado pelo código** | Alto — inviabiliza testar o comportamento no dia 25 | `Clock` injetável obrigatório; regra de revisão de código |
| 7 | **Realce de sintaxe pesando no bundle** | Baixo/Médio — conflita com H9 (abrir rápido offline) | Registrar apenas a linguagem `dart`, não o pacote inteiro de linguagens |
| 8 | **100 perguntas cobrem pouco para vaga sênior** (alerta já registrado nos requisitos) | Alto para o objetivo de negócio, nulo para o software | Fora do controle do time; H12 (tempo ocioso) é o mecanismo que empurra mais conteúdo |
| 9 | **`dart:isolate` não existe em Flutter Web** — `Isolate.run` lança `UnsupportedError` | Alto — invalida a solução óbvia para o otimizador | Treino em fatias na thread principal com `Future.delayed(Duration.zero)`; Web Worker compilado à parte só se medir lentidão. Ver seção _Autoajuste_ |
| 10 | **`importedAt` × `introducedAt`** — importar não é liberar (H16) | Médio — sem os dois campos, H16 e H5 se excluem | Campos já no modelo; `ContentIntakePolicy` é a única a escrever `introducedAt` |
| 11 | **16 histórias com desenvolvimento até 11/08** e entrega única, sem lista de corte | Alto — qualquer atraso empurra o início do estudo, e cada dia perdido encurta a rampa | A _Ordem de implementação_ existe para isso: a fatia 2 é o que precisa estar certo em 11/08; fatias 4 e 5 podem chegar dias depois sem invalidar o agendamento já feito |
