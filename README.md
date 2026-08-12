# Flashcards Dev Sênior

[![CI](https://github.com/leandrorochaadm/flashcard-dev-senior/actions/workflows/ci.yml/badge.svg)](https://github.com/leandrorochaadm/flashcard-dev-senior/actions/workflows/ci.yml)
[![Licença: PolyForm Noncommercial 1.0.0](https://img.shields.io/badge/licen%C3%A7a-PolyForm%20Noncommercial%201.0.0-blue)](LICENSE)
[![Flutter 3.44.0](https://img.shields.io/badge/Flutter-3.44.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)

Cartões de estudo com repetição espaçada (**FSRS**) para preparação de
entrevista de Flutter sênior — um PWA offline-first, escrito em Flutter Web,
sem backend.

**▶ [Abrir o app](https://flashcard-dev-senior.workers.dev)** — funciona no
navegador, instala na tela inicial e roda offline.

O app nasceu de um problema concreto: estudar por uma lista de perguntas e
respostas não funciona, porque a resposta fica logo abaixo da pergunta e nunca
se descobre o que realmente se sabe. Aqui a resposta fica escondida, cada
cartão volta na hora certa e o painel mostra, todo dia, se o método está
funcionando.

## Funcionalidades

- **Pergunta com resposta escondida** e 4 botões de autoavaliação — "Errei",
  "Lembrei só uma parte", "Lembrei com esforço", "Sabia de cor".
- **Agendamento FSRS** com ciclo curto de aprendizado (15 min → 1 h → 4 h → 1 d),
  espalhamento ±10%, nivelamento de carga e **teto móvel** que aperta os
  intervalos conforme o prazo se aproxima.
- **Importação por Markdown** — arquivo ou texto colado, com prévia de cartões
  válidos e inválidos, e formatação automática dos blocos `dart` da resposta.
- **Controle de entrada de conteúdo**: o lote importado é liberado aos poucos,
  em vez de despejar 100 cartões vencidos no mesmo dia.
- **Sessão em rounds de 5 minutos**, um assunto por round e quantos assuntos
  você escolher (cinco = os 25 minutos), com cronômetro controlável e descarte
  de tempo ocioso.
- **Painel de avanço** com indicadores por assunto, cartões-problema e
  acompanhamento do prazo.
- **Simulado de entrevista** — sorteia perguntas de todos os assuntos e grava o
  histórico **sem** contaminar o agendamento.
- **Backup e restauração** em arquivo, a única proteção real contra o despejo
  do IndexedDB pelo navegador.
- **PWA offline** com service worker próprio e atualização automática de versão.

## Screenshots

<!-- PENDENTE: salve os quatro prints em docs/screenshots/ (ver o README de lá)
     e apague estas duas linhas de comentário para publicar a seção.

|                       Painel                        |                              Cartão                              |
| :-------------------------------------------------: | :--------------------------------------------------------------: |
| ![Painel de avanço](docs/screenshots/dashboard.png) | ![Cartão com a resposta escondida](docs/screenshots/session.png) |

|                     Importação                      |                            Simulado                             |
| :-------------------------------------------------: | :-------------------------------------------------------------: |
| ![Prévia da importação](docs/screenshots/import.png) | ![Simulado de entrevista](docs/screenshots/mock_interview.png) |
-->

> Prints do painel, do cartão, da importação e do simulado entram aqui —
> veja [`docs/screenshots/README.md`](docs/screenshots/README.md).

## Privacidade

**Nenhum dado sai do seu navegador.** Não há conta, login, sincronização nem
telemetria; o servidor entrega só arquivos estáticos. Cartões e histórico vivem
no IndexedDB do dispositivo, e o backup é um arquivo local que você guarda onde
quiser. O outro lado da moeda: **se o navegador despejar o IndexedDB, não há
como recuperar** — por isso o backup existe. Detalhes em
[SECURITY.md](SECURITY.md).

## Rodando localmente

### Requisitos

| Ferramenta | Versão            | Observação                                          |
| ---------- | ----------------- | --------------------------------------------------- |
| Flutter    | **3.44.0** stable | mesma versão do CI e do deploy                      |
| Dart SDK   | `^3.12.0`         | vem junto com o Flutter 3.44.0                      |
| Chrome     | qualquer recente  | única plataforma-alvo, e o navegador dos testes web |
| Node/npx   | opcional          | só para `wrangler deploy` (Cloudflare Workers)      |

Não há Android, iOS, desktop nem plugin com código nativo: o app é **Flutter
Web puro**. Conferir a versão instalada:

```sh
flutter --version    # esperado: Flutter 3.44.0 • channel stable
flutter doctor       # basta a seção Chrome estar verde
```

Se você usa [FVM](https://fvm.app) ou mantém vários SDKs, fixe a 3.44.0 antes de
`pub get` — versões diferentes de Flutter geram `.freezed.dart`/`.g.dart`
diferentes e sujam o diff.

### Primeiros passos

```sh
git clone git@github.com:leandrorochaadm/flashcard-dev-senior.git
cd flashcard-dev-senior
flutter pub get
flutter run -d chrome    # a única plataforma-alvo
```

O app sobe já funcional, mas **vazio**: não há baralho embutido. Para ver algo
na tela, siga o caminho de onboarding:

1. Abra **/importar**.
2. Clique em **copiar template** e cole o texto num chat de IA, pedindo os
   cartões dos assuntos que você quer estudar (ou escreva o Markdown à mão —
   o formato está na seção [Formato de importação](#formato-de-importação)).
3. Cole o resultado de volta na tela de importação. A **prévia** separa cartões
   válidos de inválidos antes de gravar qualquer coisa.
4. Confirme. Os cartões entram retidos e a `ContentIntakePolicy` libera o lote
   aos poucos, ao longo dos primeiros dias — importar não é liberar.
5. Vá para **/** (painel) e comece uma **/sessao**.

Rotas úteis: `/` painel · `/sessao` estudo · `/importar` · `/cartoes` ·
`/simulado` · `/backup` · `/sobre` (versão, build e hash do commit).

**Antes de fechar o navegador, faça um backup** em `/backup`. Todo o progresso
vive no IndexedDB, que o navegador pode despejar sem aviso; o arquivo de backup
é a única proteção real.

Para experimentar o agendamento sem esperar dias, existe a tela **`/debug`**
(viagem no tempo), que troca o `SystemClock` por um `FakeClock` e opera num
banco separado — `flashcards_debug`, nunca no real.

### Regenerando código

Ao mexer em qualquer modelo `freezed` / `json_serializable`, regere o código
antes de `analyze` ou `test`:

```sh
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
```

### Build de produção

```sh
tool/build_web.sh    # carimba versão, build e hash do commit na tela /sobre
```

O script usa `--pwa-strategy=none`: o service worker gerado pelo Flutter está
deprecado e se autodestrói, então o `web/sw.js` do projeto assume o cache.

### Testes

```sh
flutter test                                        # 271 testes na VM Dart
flutter test --coverage                             # domain/ e data/ em 100% de linha
flutter test --platform chrome --tags=chrome-only   # o que precisa de js_interop / IndexedDB
flutter analyze
```

O teste que vale por todos é a **simulação dos 30 dias** com `FakeClock`,
avançando dia a dia e conferindo teto, carga e ausência de duplicatas. Roda em
milissegundos porque o `Clock` é injetável e o domínio não importa Flutter.

### CI e deploy

`.github/workflows/ci.yml` roda dois jobs de teste em todo push — um na VM Dart
(`--exclude-tags=chrome-only`) e outro no Chrome (`--tags=chrome-only`, para o
que precisa de `dart:js_interop` e IndexedDB). Em `main`, o build de release
sobe para o Cloudflare Workers via `wrangler deploy`.

## Formato de importação

Cada cartão é um bloco separado por `---`, com três rótulos de cabeçalho
(`id`, `assunto`, `dificuldade`) e dois campos (`**Pergunta**` e `**Resposta**`):

````markdown
---
id: est-001
assunto: Gerência de estado
dificuldade: intermediário

**Pergunta**
Qual a diferença entre setState e um notifier?

**Resposta**
`setState` reconstrói o widget inteiro a partir do ponto onde foi chamado.
Um notifier avisa apenas quem está ouvindo aquele pedaço de estado.

##### Por quê
`setState` acopla o estado ao widget; o notifier separa quem guarda o estado
de quem o desenha.

##### Alternativa
Para estado local e efêmero, `setState` é a escolha certa.

##### Uso real
Um contador lido pelo cabeçalho e pelo rodapé ao mesmo tempo.

##### Código

```dart
class Counter extends ChangeNotifier { … }
```
---
````

`dificuldade` aceita `básico`, `intermediário` ou `avançado`. A resposta abre
direto com o conteúdo, sem rótulo, e depois traz as seções **Por quê**,
**Alternativa**, **Uso real** e **Código** (esta última só quando há código
Dart honesto a mostrar).

O renderizador é um Markdown reduzido, feito à mão: sem tabelas, sem escape com
barra invertida, e régua horizontal é `***` — `---` é o separador de cartões e
cortaria a resposta em dois. A tela de importação tem um botão **copiar
template** que entrega essas regras inteiras, prontas para colar num chat de IA
que gere o baralho.

## Arquitetura

MVVM com `ValueNotifier`, **feature-first apenas no `ui/`**; `domain/` e `data/`
são compartilhados, porque todas as telas são janelas para a mesma entidade
(`Card`).

```
lib/
├─ core/     di · clock · result · router
├─ domain/   models · scheduling · policies · mock_interview · stats · import
├─ data/     database (sembast_web) · repositories
└─ ui/       session · import · dashboard · mock_interview · cards · backup · shared
```

Regras que o projeto trata como não negociáveis:

1. Nada em `domain/` ou `data/` importa `package:flutter/*`.
2. Toda dependência externa com modelo próprio tem **uma porta única** — só
   `domain/scheduling/fsrs_adapter.dart` importa `package:fsrs`, só
   `data/database/sembast_adapter.dart` importa `package:sembast_web`.
3. `DateTime.now()` é proibido fora do `Clock` injetável.
4. **Toda regra de negócio mora em `domain/`** — o produto é o agendamento; se a
   conta vaza para o ViewModel, ela deixa de ser testável na simulação dos
   30 dias.

O detalhamento completo — pipeline de agendamento, armadilhas do `package:fsrs`,
regras do PWA e onde mora cada regra de negócio — está em
[`CLAUDE.md`](CLAUDE.md).

A especificação original (documento de requisitos em linguagem de negócio e
handoff técnico com as histórias H1–H16) mora em `temp/`, que **não é
versionado**: contém material de estudo pessoal. `CLAUDE.md` é o resumo público
das decisões que valem para quem for mexer no código.

## Stack

Flutter Web · [`fsrs`](https://pub.dev/packages/fsrs) ·
[`sembast_web`](https://pub.dev/packages/sembast_web) (IndexedDB) ·
`get_it` · `freezed` · `json_serializable` · `dart_style` · `collection`.

Sem `dart:io`, sem `dart:ffi`, **sem `dart:isolate`** — o alvo é JS/WASM.

## Contribuindo

Issues e pull requests são bem-vindos. O guia completo — idioma, fronteiras de
`domain/`, estratégia de testes, migrações e checklist do PR — está em
**[CONTRIBUTING.md](CONTRIBUTING.md)**. O resumo:

- `flutter analyze` precisa sair limpo e `flutter test` passar;
- código, identificadores, comentários e nomes de teste em **inglês americano**;
  texto que o usuário lê e documentos em **português do Brasil**;
- regra de negócio nova vai para `domain/`, com teste unitário sem
  `WidgetTester`;
- mudou um modelo `freezed` de forma que altere o JSON? Incremente
  `AppDatabase.schemaVersion` e escreva a migração.

Requisito novo não se inventa ao codificar: lacuna percebida volta para
_Pontos em aberto_ do documento de requisitos.

O histórico de versões está em [CHANGELOG.md](CHANGELOG.md); vulnerabilidades,
em [SECURITY.md](SECURITY.md) — não abra issue pública para elas.

## Licença

[PolyForm Noncommercial License 1.0.0](LICENSE).

O código é **aberto para leitura, uso, modificação e redistribuição**, desde que
para **fins não comerciais** — estudo, pesquisa, uso pessoal e projetos de
organizações sem fins lucrativos. **Vender o código, o app ou qualquer obra
derivada, ou usá-los em atividade comercial, não é permitido** sem autorização
por escrito do autor.

Ao redistribuir, mantenha uma cópia da licença e o aviso obrigatório:

> Required Notice: Copyright 2026 Leandro Rocha (https://github.com/leandrorochaadm)

Para uso comercial, entre em contato para uma licença separada.
