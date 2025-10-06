class AppStrings {
  // App
  static const String appName = 'PuroLácteo';
  static const String appSubtitle = 'Sistema de Gestão de Leite';

  // Auth
  static const String login = 'Entrar';
  static const String logout = 'Sair';
  static const String cpfOrCnpj = 'CPF ou CNPJ';
  static const String password = 'Senha';
  static const String invalidCpf = 'CPF inválido';
  static const String invalidCnpj = 'CNPJ inválido';
  static const String invalidDocument = 'Documento inválido';
  static const String requiredField = 'Campo obrigatório';
  static const String passwordMinLength =
      'Senha deve ter no mínimo 6 caracteres';

  // Collector
  static const String collectorDashboard = 'Dashboard Coletor';
  static const String collectionsToday = 'Coletas Hoje';
  static const String lastCollection = 'Última Coleta';
  static const String newCollection = 'Nova Coleta';
  static const String history = 'Histórico';
  static const String editCollection = 'Editar Coleta';
  static const String saveCollection = 'Salvar Coleta';
  static const String saveChanges = 'Salvar Alterações';
  static const String cancel = 'Cancelar';

  // Producer
  static const String producerDashboard = 'Dashboard Produtor';
  static const String totalCurrentMonth = 'Total Mês Atual';
  static const String dailyAverage = 'Média Diária';
  static const String averageQuality = 'Qualidade Média';
  static const String viewStatement = 'Ver Extrato';
  static const String exportPdf = 'Exportar PDF';
  static const String collectionStatement = 'Extrato de Coletas';
  static const String monthlyComparison = 'Comparativo Mensal';
  static const String collectionDetails = 'Detalhes da Coleta';

  // Collection Fields
  static const String farm = 'Fazenda';
  static const String producer = 'Produtor';
  static const String quantity = 'Quantidade (litros)';
  static const String temperature = 'Temperatura';
  static const String acidity = 'Acidez';
  static const String producerPresent = 'Produtor presente';
  static const String observations = 'Observações';
  static const String collector = 'Coletor';

  // Status
  static const String synced = 'Sincronizado';
  static const String waitingSync = 'Aguardando sincronização';
  static const String approved = 'Aprovado';
  static const String rejected = 'Reprovado';
  static const String total = 'Total';

  // Quality Indicators
  static const String qualityIndicators = 'Indicadores de Qualidade';
  static const String antibiotic = 'Antibiótico';
  static const String fat = 'Gordura';
  static const String negative = 'Negativo';
  static const String positive = 'Positivo';

  // Messages
  static const String collectionSaved = 'Coleta salva com sucesso!';
  static const String changesSaved = 'Alterações salvas com sucesso!';
  static const String exportingPdf = 'Exportando PDF...';
  static const String selectFarm = 'Selecione uma fazenda';
  static const String selectProducer = 'Selecione um produtor';
  static const String invalidValue = 'Valor inválido';

  // Filters
  static const String filterPeriod = 'Filtrar período';
  static const String selectPeriod = 'Selecionar período';
  static const String all = 'Todas';

  // Charts
  static const String last30Days = 'Últimos 30 dias';
  static const String currentMonth = 'Mês Atual';
  static const String previousMonth = 'Mês Anterior';
  static const String variation = 'Variação';
  static const String comparativeChart = 'Gráfico Comparativo';

  // Months
  static const List<String> months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
}
