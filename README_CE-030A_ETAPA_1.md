# CE-030A — Etapa 1: Infraestrutura do Google Maps

## Arquivos para substituir

1. `pubspec.yaml`
2. `android/build.gradle.kts`
3. `android/app/build.gradle.kts`
4. `android/app/src/main/AndroidManifest.xml`
5. Criar `android/local.defaults.properties`

## Chave do Google Maps

1. No Google Cloud, habilite **Maps SDK for Android** no projeto correto.
2. Crie/restrinja uma chave para aplicativo Android.
3. Use o package atual: `com.example.geduc_rae_mobile`.
4. Copie `android/secrets.properties.example` para:

   `android/secrets.properties`

5. Substitua o texto de exemplo pela chave real:

   `MAPS_API_KEY=SUA_CHAVE_REAL`

6. Acrescente ao `.gitignore`:

   `/android/secrets.properties`

Não envie a chave pelo chat e não faça commit do arquivo `secrets.properties`.

## Comandos de validação

Execute na raiz do projeto:

```bash
flutter clean
flutter pub get
flutter analyze
```

Depois, com o tablet conectado:

```bash
flutter devices
flutter run -d <ID_DO_TABLET>
```

## Resultado esperado nesta etapa

- dependência do Google Maps resolvida;
- projeto Android compilando com SDK mínimo 24;
- permissões de internet e localização declaradas;
- chave lida fora do código-fonte;
- ainda não há mapa visível, pois a `LocalizacaoPage` será modificada na etapa da tela.
