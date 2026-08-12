# Screenshots do README

Quatro imagens, nesta ordem de importância:

| Arquivo              | Tela        | O que precisa aparecer                                       |
| -------------------- | ----------- | ------------------------------------------------------------ |
| `dashboard.png`      | `/`         | indicadores preenchidos e o mapa por assunto com cor          |
| `session.png`        | `/sessao`   | um cartão **com a resposta ainda escondida** e os 4 botões    |
| `import.png`         | `/importar` | a prévia separando cartões válidos de inválidos               |
| `mock_interview.png` | `/simulado` | uma pergunta sorteada, com o placar do simulado               |

## Como capturar

1. `flutter run -d chrome` (ou abra a versão publicada).
2. No Chrome, **F12 → ícone de dispositivo → iPhone 14 Pro** (390×844). O alvo é
   um PWA de celular; print de tela larga esconde justamente o layout que os
   testes de widget verificam.
3. Importe um baralho com pelo menos **três assuntos e ~20 cartões**, e responda
   alguns — o painel só fica representativo com histórico.
4. Capture com **Cmd+Shift+P → "Capture screenshot"** no DevTools (sai sem a
   moldura do navegador).
5. Salve com os nomes exatos da tabela acima, em PNG.

Não use dados reais que você não queira publicar: o print do painel mostra os
nomes dos seus assuntos.

Depois de salvar os quatro arquivos, descomente a seção **Screenshots** do
[README](../../README.md).
