import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/services/api_service.dart';
import '../bloc/auth_bloc.dart';
import '../../../collector/presentation/pages/collector_dashboard_page.dart';
import '../../../producer/presentation/pages/producer_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final apiService = context.read<ApiService>();
      context.read<AuthBloc>().add(
        LoginRequested(
          document: _documentController.text,
          password: _passwordController.text,
          apiService: apiService,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthCollectorAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => CollectorDashboardPage(user: state.user),
              ),
            );
          } else if (state is AuthProducerAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ProducerDashboardPage(user: state.user),
              ),
            );
          } else if (state is AuthDairyAuthenticated) {
            // Por enquanto, laticínio usa o mesmo dashboard do produtor
            // TODO: Criar dashboard específico para laticínio
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ProducerDashboardPage(user: state.user),
              ),
            );
          } else if (state is AuthAdminAuthenticated) {
            // Por enquanto, admin usa o mesmo dashboard do coletor
            // TODO: Criar dashboard específico para admin
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => CollectorDashboardPage(user: state.user),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.local_drink,
                        size: 80,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'PuroLácteo',
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistema de Gestão de Leite',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _documentController,
                        decoration: const InputDecoration(
                          labelText: 'CPF ou CNPJ',
                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(14),
                        ],
                        onChanged: (value) {
                          final cleanValue = value.replaceAll(
                            RegExp(r'[^\d]'),
                            '',
                          );
                          if (cleanValue.length <= 11) {
                            _cpfMask.updateMask(mask: '###.###.###-##');
                            _documentController.value = _cpfMask
                                .formatEditUpdate(
                                  const TextEditingValue(),
                                  TextEditingValue(text: cleanValue),
                                );
                          } else {
                            _cnpjMask.updateMask(mask: '##.###.###/####-##');
                            _documentController.value = _cnpjMask
                                .formatEditUpdate(
                                  const TextEditingValue(),
                                  TextEditingValue(text: cleanValue),
                                );
                          }
                        },
                        validator: Validators.validateDocument,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 32),
                      state is AuthLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _handleLogin,
                              child: const Text('Entrar'),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
