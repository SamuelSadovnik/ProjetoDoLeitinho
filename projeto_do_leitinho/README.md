# PuroLácteo - Sistema de Gestão de Leite

Aplicativo mobile Flutter para gestão de coleta de leite entre produtores e laticínios.

## Arquitetura

- **Pattern:** BLoC (Business Logic Component)
- **State Management:** flutter_bloc
- **Estrutura:** Feature-first (Clean Architecture adaptada)

## Estrutura de Pastas

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── validators.dart
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── bloc/auth_bloc.dart
│   │       └── pages/login_page.dart
│   ├── collector/
│   │   └── presentation/pages/
│   │       ├── collector_dashboard_page.dart
│   │       ├── new_collection_page.dart
│   │       ├── collection_history_page.dart
│   │       └── edit_collection_page.dart
│   └── producer/
│       └── presentation/pages/
│           ├── producer_dashboard_page.dart
│           ├── collection_statement_page.dart
│           ├── monthly_comparison_page.dart
│           └── collection_details_page.dart
└── main.dart
```

## Funcionalidades

### Coletor (Login com CPF)

- Dashboard com estatísticas do dia
- Cadastro de nova coleta (offline-ready)
- Histórico de coletas com filtros
- Edição de coletas

### Produtor (Login com CNPJ)

- Dashboard com métricas e gráficos
- Extrato de coletas com totalizadores
- Comparativo mensal
- Detalhes de cada coleta
- Exportação PDF

## Instalação

```bash
# Instalar dependências
flutter pub get

# Executar
flutter run
```

## Credenciais de Teste

**Coletor:**

- CPF: 123.456.789-09 (qualquer CPF válido)
- Senha: 123456

**Produtor:**

- CNPJ: 12.345.678/0001-90 (qualquer CNPJ válido)
- Senha: 123456

## Validações

- CPF: Validação com dígitos verificadores
- CNPJ: Validação com dígitos verificadores
- Auto-formatação de campos (CPF/CNPJ)
- Máscara dinâmica conforme tipo de documento

## Paleta de Cores

- Primary Green: `#4C9A6A`
- Soft Green: `#A8D5BA`
- Light Blue: `#B3DDF2`
- Snow White: `#FFFFFF`
- Light Gray: `#6E7F80`
- Dark Blue: `#2C3E50`

## Tipografia

- **Títulos:** Montserrat
- **Textos:** Merriweather
- **Subtítulos:** Raleway Light

## Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## Próximos Passos

- [ ] Integração API REST
- [ ] Persistência local (Hive/Isar)
- [ ] Sincronização offline
- [ ] Geração PDF
- [ ] Push notifications
- [ ] Deep linking
