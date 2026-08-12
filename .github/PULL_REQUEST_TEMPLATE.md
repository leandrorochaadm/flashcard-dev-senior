<!-- Título no formato do histórico: tipo(camada->feature): descrição -->

## O que muda

<!-- Uma ou duas frases, em linguagem de negócio quando possível. -->

## Por quê

<!-- Issue relacionada, ou o caso que motivou. -->

## Como testei

<!-- Testes novos, e o que você conferiu no navegador. -->

## Checklist

- [ ] `flutter analyze` sai limpo
- [ ] `flutter test` passa
- [ ] regra de negócio nova está em `domain/`, com teste sem `WidgetTester`
- [ ] nenhum `DateTime.now()` fora do `Clock`; nenhum `firstWhere` que lança
- [ ] `domain/` e `data/` continuam sem importar `package:flutter/*`
- [ ] modelo `freezed` alterado? `AppDatabase.schemaVersion` incrementado e
      migração escrita
- [ ] código gerado (`.freezed.dart`, `.g.dart`) commitado junto
- [ ] código em inglês americano; texto que o usuário lê em português
