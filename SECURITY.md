# Segurança e privacidade

## Não existe backend

O app é **Flutter Web puro, sem servidor de aplicação**. Não há conta, login,
sincronização nem telemetria. O Cloudflare Workers serve apenas arquivos
estáticos — HTML, JS e assets — e não recebe nenhum dado de estudo.

Consequências práticas:

- **Seus cartões e seu histórico nunca saem do navegador.** Tudo vive no
  IndexedDB do dispositivo, gravado pelo `sembast_web`.
- **O backup é um arquivo local**, gerado e lido pelo próprio navegador. Ele não
  é enviado a lugar nenhum; onde você o guarda depois é escolha sua.
- **Não há como recuperar dados perdidos.** O navegador pode despejar o
  IndexedDB sem aviso — em modo anônimo, sob pressão de armazenamento, ou ao
  limpar dados do site. Fazer backup regularmente é a única proteção real.
- Nenhum plugin com código nativo, nenhuma permissão de sistema.

## Superfície de ataque

O conteúdo importado é Markdown escrito pelo próprio usuário e renderizado por
um renderizador reduzido, feito à mão (`ui/shared/card_markdown.dart`), que não
executa HTML nem scripts. Ainda assim, **trate um baralho recebido de terceiros
como você trataria qualquer arquivo de origem desconhecida**: leia antes de
importar.

O arquivo de backup é JSON carimbado com o `schemaVersion` do banco. Na
restauração, um arquivo sem versão é recusado, um arquivo de schema mais antigo
passa pelas migrações, e um arquivo de schema mais novo que o app é recusado com
mensagem clara em vez de ser adivinhado. A restauração é **destrutiva** por
natureza — ela substitui o banco atual.

## Reportando uma vulnerabilidade

Se você encontrar um problema de segurança, **não abra uma issue pública**. Abra
um [security advisory privado][advisory] no repositório, descrevendo:

- o que acontece e como reproduzir;
- o impacto que você enxerga;
- versão do app (a tela `/sobre` mostra versão, build e hash do commit) e
  navegador.

[advisory]: https://github.com/leandrorochaadm/flashcard-dev-senior/security/advisories/new

Este é um projeto pessoal mantido nas horas vagas: não há SLA de resposta, mas
todo relato legítimo será lido e respondido.

## Versões suportadas

Só a versão publicada mais recente recebe correções. Não há branches de suporte
para versões anteriores.
