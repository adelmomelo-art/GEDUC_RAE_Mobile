# Plano de implementação — CIO Lote 2

1. Formalizar o contrato arquitetural e as áreas preservadas.
2. Transformar `DashboardCIOBridge` em fachada analítica executável.
3. Injetar a fachada no `DashboardController`.
4. Processar período principal e comparação pela mesma fachada.
5. Expor ranking, insights, alertas e recomendações.
6. Criar painel responsivo de inteligência operacional.
7. Cobrir bridge, vazio, ordenação e responsividade com testes.
8. Executar formatação, análise estática e testes de regressão.

## Arquivos protegidos nesta entrega

- `lib/app.dart`
- `lib/core/routes/app_routes.dart`
- `firestore.rules`
- `pubspec.yaml`
- fluxo de criação e fechamento do RAE
