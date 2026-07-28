# CE-032A-2 — Centralização da lógica dos widgets de domínio

## Situação

Pacote de implementação da CE-032A-2. Esta etapa deve ser homologada antes do início da CE-032B.

## Arquivos

Novo:

- `lib/shared/widgets/domain/domain_loader_mixin.dart`

Substituir:

- `lib/shared/widgets/domain/domain_dropdown.dart`
- `lib/shared/widgets/domain/domain_radio_group.dart`
- `lib/shared/widgets/domain/domain_checkbox_group.dart`

## Alterações

- ciclo de carregamento centralizado;
- leitura e observação do `DomainProvider` centralizadas;
- recarga centralizada;
- montagem de opções e fallback de valor ausente centralizados;
- preservação de valores legados centralizada;
- sincronização de valores legados recebidos após a primeira construção;
- APIs públicas e construtores preservados;
- layout e mensagens dos widgets preservados.

## Instalação

Extraia o conteúdo do ZIP na raiz:

`C:\Projetos\GEDUC_RAE_Mobile`

Confirme a criação/substituição dos quatro arquivos.

## Validação técnica

```powershell
dart format lib/shared/widgets/domain/domain_loader_mixin.dart lib/shared/widgets/domain/domain_dropdown.dart lib/shared/widgets/domain/domain_radio_group.dart lib/shared/widgets/domain/domain_checkbox_group.dart

flutter analyze
```

Resultado esperado:

```text
No issues found!
```

## Homologação funcional posterior

Tela principal:

`Ações → Nova Ação → Caracterização da Ação`

Validar:

- Formação (`DomainDropdown`);
- Público (`DomainDropdown`);
- Sexo predominante (`DomainDropdown`);
- Mudança de comportamento (`DomainDropdown`);
- campos de múltipla escolha implementados com `DomainCheckboxGroup`;
- campos implementados com `DomainRadioGroup`, caso estejam acessíveis no fluxo;
- retorno à tela sem perda de seleção;
- ausência de loading infinito e erros.
