# Changelog

Todas as mudanças relevantes deste projeto são registradas aqui.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/), e
a versão é `MAJOR.MINOR.PATCH+BUILD` do `pubspec.yaml`. O **build number** é
incrementado pelo hook de `pre-push` e é o que avisa um PWA suspenso de que
existe versão nova — por isso ele aparece junto da versão em cada entrada.

## [Não publicado]

### Alterado

- A sessão deixou de ter cinco rounds fixos: os assuntos são escolhidos à mão e
  a sessão dura um round de 5 minutos por assunto escolhido — cinco assuntos
  continuam dando os 25 minutos do requisito 8.

### Adicionado

- Documentação de projeto aberto: `README.md` completo, `CONTRIBUTING.md`,
  `SECURITY.md`, templates de issue e de pull request.
- Licença [PolyForm Noncommercial 1.0.0](LICENSE) — uso não comercial.

## [1.0.0+3] — 2026-08-12

### Adicionado

- Respostas dos cartões renderizadas como Markdown, com um renderizador próprio
  e reduzido (sem tabelas, sem escape com barra invertida).
- Verificação e formatação automática dos blocos `dart` da resposta na
  importação, via `package:dart_style`.

### Corrigido

- O hook de `pre-push` agora atualiza `app_version.dart` junto com o
  `pubspec.yaml`, e roda os testes depois do bump.

## [1.0.0+2] — 2026-08-12

### Adicionado

- **Service worker próprio** (`web/sw.js`), com o build no nome do cache e
  recarga da página disparada pelo worker ao ativar. O service worker gerado
  pelo Flutter está desligado (`--pwa-strategy=none`) porque se autodestrói
  desde a 3.44.
- Liberação diária do lote importado feita uma única vez na inicialização, já
  carimbada, em vez de partir do `initState` do painel.
- Assuntos estudáveis e contagem de cartões por round em
  `domain/policies`.

### Corrigido

- Painel: as três saídas empilhadas para os rótulos caberem num celular, e
  `IntrinsicHeight` na linha de tiles para parar um assert de layout.

## [1.0.0+1] — 2026-08-11

Primeira versão completa — as 16 histórias (H1–H16) implementadas.

### Adicionado

- Cartão com **resposta escondida** e quatro botões de autoavaliação.
- **Agendamento FSRS** com ciclo curto (15 min → 1 h → 4 h → 1 d), espalhamento
  ±10%, nivelamento de carga e teto móvel aplicado por último.
- **Importação** por arquivo `.md` (vários de uma vez) ou texto colado, com
  prévia separando cartões válidos de inválidos, e botão "copiar template".
- **Controle de entrada de conteúdo**: o lote entra retido e é liberado aos
  poucos, em vez de vencer tudo no mesmo dia.
- **Sessão de 25 minutos** em 5 rounds de 5 minutos, um assunto por round, com
  cronômetro controlável e descarte de tempo ocioso acima de 60 s.
- **Painel de avanço** com sete indicadores, mapa por assunto e cartões-problema.
- **Simulado de entrevista**, que grava `ReviewLog` e nada mais — não toca
  `stability`, `dueAt`, `state` nem `lapses`.
- **Backup e restauração** em arquivo, com teste ponta a ponta contra o
  IndexedDB real.
- **PWA instalável e offline**; deploy contínuo para o Cloudflare Workers a
  partir de `main`.
- Tela `/debug` (viagem no tempo) operando em banco separado,
  `flashcards_debug`.

### Infraestrutura

- CI com dois jobs de teste — VM Dart e Chrome — e deploy em `main`.
- 100% de cobertura de linha em `domain/` e `data/`, nenhum deles usando
  `WidgetTester`.
- Código gerado por `freezed`/`json_serializable` versionado.
