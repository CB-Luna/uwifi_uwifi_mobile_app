import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:uwifiapp/features/home/presentation/bloc/connection_bloc.dart';
import 'package:uwifiapp/features/home/presentation/bloc/connection_event.dart';
import 'package:uwifiapp/features/home/presentation/bloc/connection_state.dart'
    as connection_state;

import 'speedtest/speed_test_page.dart';

class WifiSettingsPage extends StatefulWidget {
  const WifiSettingsPage({super.key});

  @override
  State<WifiSettingsPage> createState() => _WifiSettingsPageState();
}

class _WifiSettingsPageState extends State<WifiSettingsPage> {
  // Controladores para los campos de texto en los diálogos
  final TextEditingController _newSsidController = TextEditingController();
  final TextEditingController _confirmSsidController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Variables para controlar la visibilidad de las contraseñas
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _showWifi24GPassword = false;
  bool _showWifi5GPassword = false;

  @override
  void dispose() {
    _newSsidController.dispose();
    _confirmSsidController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadConnectionInfo();
  }

  void _loadConnectionInfo() {
    // Obtener el ID del cliente desde el estado de autenticación
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.customerId != null) {
      // GetConnectionInfoEvent espera un int no nulo
      final customerId = authState.user.customerId!;
      context.read<ConnectionBloc>().add(GetConnectionInfoEvent(customerId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Settings'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                'assets/images/homeimage/realGateway.png',
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            // Mostrar tarjetas WiFi con datos dinámicos
            BlocBuilder<ConnectionBloc, connection_state.ConnectionState>(
              builder: (context, state) {
                String wifi24GName = 'Loading...';
                String wifi5GName = 'Loading...';
                String wifi24GPassword = 'Loading...';
                String wifi5GPassword = 'Loading...';

                if (state is connection_state.ConnectionLoaded) {
                  wifi24GName = state.gatewayInfo.wifi24GName;
                  wifi5GName = state.gatewayInfo.wifi5GName;
                  wifi24GPassword =
                      state.gatewayInfo.wifi24GPassword ?? 'Password';
                  wifi5GPassword =
                      state.gatewayInfo.wifi5GPassword ?? 'Password';
                } else if (state is connection_state.ConnectionLoading &&
                    state.previousInfo != null) {
                  wifi24GName = state.previousInfo!.wifi24GName;
                  wifi5GName = state.previousInfo!.wifi5GName;
                  wifi24GPassword =
                      state.previousInfo!.wifi24GPassword ?? 'Password';
                  wifi5GPassword =
                      state.previousInfo!.wifi5GPassword ?? 'Password';
                } else if (state is connection_state.ConnectionError) {
                  wifi24GName = 'Error loading network name';
                  wifi5GName = 'Error loading network name';
                  wifi24GPassword = 'Error loading password';
                  wifi5GPassword = 'Error loading password';
                }

                return Column(
                  children: [
                    // 2.4 GHz
                    _wifiCard(
                      context,
                      title: '2.4 GHz',
                      networkName: wifi24GName,
                      password: wifi24GPassword,
                    ),
                    const SizedBox(height: 16),
                    // 5 GHz
                    _wifiCard(
                      context,
                      title: '5 GHz',
                      networkName: wifi5GName,
                      password: wifi5GPassword,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SpeedTestPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.speed, color: Colors.green),
                      label: const Text('Speed Test'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.restart_alt, color: Colors.purple),
                      label: const Text('Reboot Gateway'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Método para copiar al portapapeles
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  // Diálogo para editar el nombre de la red
  void _showEditNetworkNameDialog(
    BuildContext context,
    String title,
    String currentName,
  ) {
    _newSsidController.text = currentName;
    _confirmSsidController.text = '';

    // Obtener el número de serie del gateway antes de abrir el diálogo
    String serialNumber = '';
    final state = context.read<ConnectionBloc>().state;
    if (state is connection_state.ConnectionLoaded) {
      // Aquí asumimos que el número de serie está disponible en el estado
      // Si no está disponible, habría que obtenerlo de otra manera
      serialNumber = state.gatewayInfo.serialNumber ?? '';
    } else if (state is connection_state.ConnectionLoading &&
        state.previousInfo != null) {
      serialNumber = state.previousInfo!.serialNumber ?? '';
    }

    if (serialNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The serial number of the gateway could not be obtained',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit $title Network Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _newSsidController,
              decoration: const InputDecoration(
                labelText: 'New SSID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmSsidController,
              decoration: const InputDecoration(
                labelText: 'Confirm SSID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_newSsidController.text == _confirmSsidController.text) {
                final newName = _newSsidController.text;
                final isNetwork24G = title == '2.4 GHz';

                // Enviar el evento para actualizar el nombre de la red
                context.read<ConnectionBloc>().add(
                  UpdateWifiNetworkNameEvent(
                    serialNumber: serialNumber,
                    newName: newName,
                    isNetwork24G: isNetwork24G,
                  ),
                );

                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Actualizando nombre de red $title...'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SSID confirmation does not match'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // Diálogo para editar la contraseña
  void _showEditPasswordDialog(
    BuildContext context,
    String title,
    String currentPassword,
  ) {
    _newPasswordController.text = '';
    _confirmPasswordController.text = '';

    // Obtener el nombre de la red actual y el número de serie antes de abrir el diálogo
    String networkName = title == '2.4 GHz' ? 'Loading...' : 'Loading...';
    String serialNumber = '';

    // Obtener el estado actual del bloc fuera del builder del diálogo
    final state = context.read<ConnectionBloc>().state;
    if (state is connection_state.ConnectionLoaded) {
      networkName = title == '2.4 GHz'
          ? state.gatewayInfo.wifi24GName
          : state.gatewayInfo.wifi5GName;
      serialNumber = state.gatewayInfo.serialNumber ?? '';
    } else if (state is connection_state.ConnectionLoading &&
        state.previousInfo != null) {
      networkName = title == '2.4 GHz'
          ? state.previousInfo!.wifi24GName
          : state.previousInfo!.wifi5GName;
      serialNumber = state.previousInfo!.serialNumber ?? '';
    }

    if (serialNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The serial number of the gateway could not be obtained',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit $title Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Network Name', style: TextStyle(color: Colors.grey.shade600)),
            Text(
              networkName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: !_showNewPassword,
              decoration: InputDecoration(
                labelText: 'New password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_newPasswordController.text ==
                  _confirmPasswordController.text) {
                final newPassword = _newPasswordController.text;
                final isNetwork24G = title == '2.4 GHz';

                // Enviar el evento para actualizar la contraseña
                context.read<ConnectionBloc>().add(
                  UpdateWifiPasswordEvent(
                    serialNumber: serialNumber,
                    newPassword: newPassword,
                    isNetwork24G: isNetwork24G,
                  ),
                );

                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Actualizando contraseña de red $title...'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password confirmation does not match'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _wifiCard(
    BuildContext context, {
    required String title,
    required String networkName,
    required String password,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi, color: Colors.black),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.grey.shade400),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        title == '2.4 GHz'
                            ? '2.4 GHz Network'
                            : '5 GHz Network',
                      ),
                      content: Text(
                        title == '2.4 GHz'
                            ? "This network covers a larger area and goes through walls better, but it's a bit slower. It's great for older devices or when you're farther from the router."
                            : "This one is faster but has a shorter range. It's perfect for streaming, gaming, or using the internet near the router.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Ok'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Network Name', style: TextStyle(color: Colors.grey.shade600)),
          Row(
            children: [
              Expanded(
                child: Text(
                  networkName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  _copyToClipboard(context, networkName);
                },
                icon: const Icon(Icons.copy, size: 18),
              ),
              IconButton(
                onPressed: () {
                  _showEditNetworkNameDialog(context, title, networkName);
                },
                icon: const Icon(Icons.edit, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Password', style: TextStyle(color: Colors.grey.shade600)),
          Row(
            children: [
              Expanded(
                child: Text(
                  (title == '2.4 GHz' && !_showWifi24GPassword) ||
                          (title == '5 GHz' && !_showWifi5GPassword)
                      ? '••••••••'
                      : password,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (title == '2.4 GHz') {
                      _showWifi24GPassword = !_showWifi24GPassword;
                    } else {
                      _showWifi5GPassword = !_showWifi5GPassword;
                    }
                  });
                },
                icon: Icon(
                  title == '2.4 GHz'
                      ? (_showWifi24GPassword
                            ? Icons.visibility
                            : Icons.visibility_off)
                      : (_showWifi5GPassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                  size: 18,
                ),
              ),
              IconButton(
                onPressed: () {
                  _copyToClipboard(context, password);
                },
                icon: const Icon(Icons.copy, size: 18),
              ),
              IconButton(
                onPressed: () {
                  _showEditPasswordDialog(context, title, password);
                },
                icon: const Icon(Icons.edit, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
