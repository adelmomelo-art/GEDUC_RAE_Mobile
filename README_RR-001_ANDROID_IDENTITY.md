# PLATAFORMA FENIX
## RR-001 - RELEASE READINESS - IDENTIDADE ANDROID

**Data:** 10/09/2026
**Projeto:** GEDUC_RAE_Mobile / Plataforma Fenix
**Baseline:** 24bdcab7fb9baf12326bfdaaab7db25f0ec1b84f
**Branch:** release/rr-001-android-identity

## 1. Objetivo

Remover o bloqueador REL-BLK-001 por meio da migracao controlada da identidade Android provisoria para a identidade institucional definitiva.

Identidade anterior:

com.example.geduc_rae_mobile

Identidade Android definitiva aprovada:

br.gov.ce.fortaleza.amc.geduc

## 2. Decisao arquitetural

A identidade tecnica Android da Plataforma Fenix sera:

namespace = br.gov.ce.fortaleza.amc.geduc

applicationId = br.gov.ce.fortaleza.amc.geduc

package Kotlin = br.gov.ce.fortaleza.amc.geduc

GEDUC permanece como identidade tecnica estrutural do aplicativo.

Plataforma Fenix permanece como identidade funcional e institucional do produto.

## 3. Escopo da migracao

A intervencao contempla:

- android/app/build.gradle.kts
- MainActivity.kt e sua arvore de package
- registro de novo Android App no projeto Firebase existente
- novo google-services.json obtido oficialmente do Firebase
- reconciliacao do firebase_options.dart
- fingerprints de assinatura quando necessarios
- verificacao da integracao OpenStreetMap + flutter_map
- validacao do App Check sem enforcement produtivo
- builds debug e release
- testes e homologacao funcional Android

## 4. Firebase

O projeto Firebase permanece geduc-rae-mobile.

Novo Android App homologado:

- package: br.gov.ce.fortaleza.amc.geduc
- Firebase App ID: 1:906308539006:android:f3907c8047a7591497be2f

O Android App legado foi preservado para rollback:

- package: com.example.geduc_rae_mobile
- Firebase App ID: 1:906308539006:android:8d2c96fe7cc8c6ee97be2f

O google-services.json oficial fornecido pelo Firebase contem os dois clientes Android.

A referencia ao package legado dentro desse arquivo foi auditada e classificada como metadado legitimo de rollback, nao como identidade Android ativa.

Nenhum package_name, mobilesdk_app_id ou identificador Firebase foi inventado ou alterado manualmente.

## 5. FlutterFire

lib/firebase_options.dart foi reconciliado com o novo Android App.

O Android App ID definitivo esta configurado para br.gov.ce.fortaleza.amc.geduc.

A configuracao Firebase Web existente foi preservada.

A reconciliacao foi realizada por FlutterFire e validada semanticamente contra google-services.json.

## 6. Assinatura

A chave de assinatura release existente foi preservada.

Nenhuma nova keystore foi criada durante RR-001.

O APK release foi assinado e validado com o certificado esperado.

SHA-256 release:

D7:2D:F8:A9:09:50:26:A1:2D:89:D5:B8:D6:34:29:FB:65:61:8E:37:FC:2C:18:A5:8F:31:21:6B:2A:65:BE:58

Os fingerprints debug e release foram registrados no novo Android App Firebase.

android/key.properties permanece local, nao rastreado e ignorado pelo Git.

## 7. App Check

O bootstrap local existente foi preservado.

- Android debug: Debug Provider
- Android release: Play Integrity
- Web debug: Debug Provider
- Web release: reCAPTCHA Enterprise

A execucao release no A05s acionou o fluxo Play Integrity sem crash da Plataforma Fenix.

A configuracao produtiva de App Check / Play Integrity permanece DEFERIDA por dependencia externa administrativa e de governanca institucional.

Nao sera criada conta Google Play Console pessoal como contorno.

O enforcement produtivo permanece DESLIGADO.

RR-001 nao declara App Check produtivo como homologado.

## 8. Cartografia - OpenStreetMap

A Plataforma Fenix utiliza exclusivamente OpenStreetMap + flutter_map no escopo cartografico auditado.

Nao utiliza Google Maps, Maps SDK for Android, google_maps_flutter ou MAPS_API_KEY.

Os residuos legados do Google Maps foram removidos do runtime e da configuracao Android ativa.

O userAgentPackageName dos dois mapas foi atualizado para:

br.gov.ce.fortaleza.amc.geduc

A homologacao funcional no Samsung A05s confirmou:

- abertura do mapa OpenStreetMap
- carregamento dos tiles
- zoom
- arraste
- localizacao
- ausencia de falha de rede ou permissao no processo auditado
- ausencia de crash fatal

Para release produtivo permanece recomendada a observancia da politica publica de tiles do OpenStreetMap, incluindo identificacao adequada do cliente e estrategia de uso/caching compativel.

## 9. Storage

remoteStorageEnabled permanece false.

RR-001 nao autoriza ativacao do Firebase Storage remoto.

Storage continuara condicionado a regras versionadas, testes automatizados e homologacao especifica.

## 10. Migracao historica

A migracao historica permanece SUSPENSA.

RR-001 nao autoriza qualquer retomada da carga historica.

## 11. Fora do escopo

Nao fazem parte desta intervencao:

- identidade Linux
- identidade Windows
- identidade iOS
- identidade macOS
- identidade Web
- reescrita de documentos historicos
- habilitacao do Storage remoto
- App Check enforcement produtivo
- retomada da migracao historica

## 12. Homologacao executada

Resultados locais homologados em 10/09/2026:

- namespace definitivo: PASS
- applicationId definitivo: PASS
- MainActivity no package definitivo: PASS
- novo Firebase Android App: PASS
- google-services.json oficial: PASS
- FlutterFire reconciliado: PASS
- configuracao Web preservada: PASS
- fingerprints Firebase registrados: PASS
- flutter analyze: 0 issues
- flutter test: todos aprovados
- APK debug: PASS
- APK release: PASS
- assinatura release: PASS
- package interno do APK: br.gov.ce.fortaleza.amc.geduc
- package legado no DEX: AUSENTE
- minSdk: 24
- targetSdk: 36
- instalacao release no Samsung SM_A057M: PASS
- inicializacao Firebase: PASS
- Login: PASS
- Home autenticada: PASS
- persistencia da sessao: PASS
- Firestore: nenhuma falha explicita observada no smoke test; baseline de regras preservada
- OpenStreetMap: PASS
- tiles OSM: PASS
- zoom e arraste: PASS
- localizacao: PASS
- crash fatal da Plataforma Fenix: NAO ENCONTRADO
- App Check local: PRESERVADO
- App Check produtivo / enforcement: DEFERIDO

Os Quality Gates locais foram aprovados.

Os Quality Gates GitHub da branch/PR permanecem pendentes ate commit, push e abertura do PR.

## 13. Regra de rollback

Nenhum Android App Firebase legado foi excluido durante RR-001.

O cliente com.example.geduc_rae_mobile permanece registrado no Firebase para rollback controlado.

O google-services.json oficial mantem metadado desse cliente legado, auditado como referencia de rollback.

O runtime Android e o APK release usam exclusivamente br.gov.ce.fortaleza.amc.geduc.

A MainActivity antiga foi removida da arvore ativa e substituida pela MainActivity no package definitivo.

## 14. Estado

RR-001A - Auditoria de identidade Android: CONCLUIDA.

RR-001B - Blueprint: APROVADO.

RR-001C - Implementacao e homologacao local: CONCLUIDAS ate RR-001C.14.

RR-001C.15A - Preflight de fechamento Git: PASS.

RR-001C.15B - Reconciliacao documental: CONCLUIDA.

Identidade Android definitiva:

br.gov.ce.fortaleza.amc.geduc

REL-BLK-001 encontra-se tecnicamente resolvido e homologado localmente.

O fechamento formal depende ainda de CPB/ZIP, staging controlado, commit, push, PR, Quality Gates GitHub, merge e validacao pos-merge.

RR-001 NAO constitui autorizacao de producao.

Pendencias transferidas / preservadas:

- SEC-NEXT-001: Firebase Storage remoto permanece desabilitado; regras produtivas ainda pendentes
- SEC-NEXT-002: App Check produtivo / Play Integrity / enforcement permanece deferido
- OBS-REL-001: validacao visual Unicode do PDF permanece pendente
- compatibilidade futura Built-in Kotlin/KGP deve ser tratada em frente propria
- build release apresentou aviso relacionado a CupertinoIcons; avaliar separadamente sem ampliar RR-001
- migracao historica permanece SUSPENSA

Fluxo de fechamento PF-ENG:

CPB / ZIP -> revisao -> staging controlado -> commit -> push -> PR -> Quality Gates -> merge -> pos-merge.


## 15. Reconciliacao final FlutterFire e CPB

A auditoria independente do primeiro CPB identificou que firebase.json ainda referenciava o Firebase Android App legado.

A reconciliacao foi executada oficialmente com FlutterFire CLI 1.4.1.

Estado final validado:

- Android default App ID: 1:906308539006:android:f3907c8047a7591497be2f
- Dart Android App ID: 1:906308539006:android:f3907c8047a7591497be2f
- Web App ID preservado: 1:906308539006:web:c332bfc83131398b97be2f
- Firestore preservado
- emuladores preservados
- Storage nao habilitado
- firebase_options.dart homologado preservado byte a byte
- google-services.json homologado preservado byte a byte

O primeiro CPB:

EC6073E934B388BC1D8FCD0FC089E710AE0E4C8817F2A12830CD39A5DB4F8E25

foi classificado como SUPERSEDIDO e NAO DEVE SER UTILIZADO.

O manifesto CPB definitivo passa a incluir evidence_storage_policy.dart e remote_evidence_transport_test.dart como evidencias da preservacao de remoteStorageEnabled=false.

## 16. Auditoria independente final do CPB

O segundo CPB foi submetido a auditoria independente do arquivo ZIP real.

A auditoria confirmou identidade Android, Firebase, OpenStreetMap, App Check local, Storage desabilitado, manifesto, branch, baseline e ausencia de segredos/keystore.

Foram identificados apenas residuos de higiene de fechamento: formatacao do firebase.json, comentario residual firebase_options_candidate.dart e linha inicial vazia em android/build.gradle.kts.

Esses itens nao representam falha funcional ou de seguranca, mas foram corrigidos antes do staging.

CPB auditado nesta etapa:

D981DD1D8FB65E8B857B5874062D86E32711C9D3EA7052F832D6D1A02848B8BA

Status: SUPERSEDIDO POR LIMPEZA DE FECHAMENTO.

O CPB final valido deve ser gerado somente apos esta limpeza e submetido a verificacao independente antes do staging. O SHA256 do ZIP e registrado no fechamento externo do RR-001, evitando autorreferencia do proprio pacote.
