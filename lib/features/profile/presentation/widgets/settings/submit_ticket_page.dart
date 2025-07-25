import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/presentation/widgets/loading_indicator.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../injection_container.dart' as di;
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../customer/presentation/bloc/customer_details_bloc.dart' as customer_bloc;
import '../../../../support/domain/entities/support_ticket.dart';
import '../../../../support/presentation/bloc/support_ticket_bloc.dart';
import '../../../../support/presentation/bloc/support_ticket_event.dart';
import '../../../../support/presentation/bloc/support_ticket_state.dart';
import '../../../../support/presentation/bloc/ticket_category_bloc.dart';
import '../../../../support/presentation/bloc/ticket_category_event.dart';
import '../../../../support/presentation/bloc/ticket_category_state.dart';

// Usamos alias para los tipos del CustomerDetailsBloc
typedef CustomerDetailsBloc = customer_bloc.CustomerDetailsBloc;
typedef CustomerDetailsState = customer_bloc.CustomerDetailsState;
typedef CustomerDetailsLoaded = customer_bloc.CustomerDetailsLoaded;
typedef CustomerDetailsLoading = customer_bloc.CustomerDetailsLoading;
typedef CustomerDetailsInitial = customer_bloc.CustomerDetailsInitial;
typedef CustomerDetailsError = customer_bloc.CustomerDetailsError;
typedef FetchCustomerDetails = customer_bloc.FetchCustomerDetails;

class SubmitTicketPage extends StatefulWidget {
  const SubmitTicketPage({super.key});

  @override
  State<SubmitTicketPage> createState() => _SubmitTicketPageState();
}

// Widget para proporcionar el BLoC
class SubmitTicketPageProvider extends StatelessWidget {
  const SubmitTicketPageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // Intentamos obtener el AuthBloc del contexto actual primero
    // Si no está disponible, usamos la instancia del contenedor de inyección
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    
    AppLogger.navInfo('SubmitTicketPageProvider: Estado de AuthBloc: ${authBloc.state.runtimeType}');
    
    return MultiBlocProvider(
      providers: [
        // Usamos el AuthBloc del contexto actual para mantener el estado de autenticación
        BlocProvider.value(value: authBloc),
        // Añadimos el CustomerDetailsBloc para obtener información detallada del cliente
        BlocProvider(create: (_) => di.getIt<CustomerDetailsBloc>()),
        BlocProvider(
          create: (_) =>
              di.getIt<TicketCategoryBloc>()
                ..add(const LoadTicketCategoriesEvent()),
        ),
        BlocProvider(create: (_) => di.getIt<SupportTicketBloc>()),
      ],
      child: const SubmitTicketPage(),
    );
  }
}

class _SubmitTicketPageState extends State<SubmitTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  int? _selectedCategoryId;
  late ImagePicker _imagePicker;
  XFile? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    
    // Cargar los detalles del cliente si el usuario está autenticado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      
      if (authState is AuthAuthenticated && authState.user.customerId != null) {
        AppLogger.navInfo('Solicitando detalles del cliente al iniciar la página');
        final customerId = authState.user.customerId!;
        
        // Creamos una instancia directa del evento FetchCustomerDetails
        final fetchEvent = FetchCustomerDetails(customerId);
        context.read<CustomerDetailsBloc>().add(fetchEvent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CustomerDetailsBloc, CustomerDetailsState>(
          listener: (context, state) {
            // No necesitamos hacer nada aquí, solo nos aseguramos de que
            // el CustomerDetailsBloc esté disponible para ser usado
          },
        ),
        BlocListener<SupportTicketBloc, SupportTicketState>(
          listener: (context, state) {
            if (state is FilesUploading) {
              setState(() {
                _isUploading = true;
              });
            } else if (state is FilesUploaded) {
              // Cuando los archivos se han subido correctamente, crear el ticket
              try {
                // 1. Obtener información del usuario autenticado
                final authBloc = context.read<AuthBloc>();
                if (authBloc.state is! AuthAuthenticated) {
                  throw Exception('Usuario no autenticado');
                }

                final user = (authBloc.state as AuthAuthenticated).user;
                final customerId = user.customerId ?? 0;

                if (customerId == 0) {
                  throw Exception(
                    'No se encontró ID de cliente en el usuario autenticado',
                  );
                }

                // Determinar el nombre a mostrar
                String customerName;
                final customerDetailsBloc = context.read<CustomerDetailsBloc>();
                final customerState = customerDetailsBloc.state;
                
                if (customerState is CustomerDetailsLoaded) {
                  customerName = customerState.customerDetails.fullName;
                  AppLogger.navInfo('Usando nombre del cliente: $customerName');
                } else {
                  customerName = user.name ?? user.email;
                  AppLogger.navInfo('Usando nombre del usuario autenticado: $customerName');
                  
                  // Solicitar los detalles del cliente si no están cargados
                  if (customerState is! CustomerDetailsLoading) {
                    // Creamos una instancia directa del evento FetchCustomerDetails
                    final fetchEvent = FetchCustomerDetails(customerId);
                    customerDetailsBloc.add(fetchEvent);
                  }
                }

                // 2. Obtener el nombre de la categoría seleccionada
                String categoryName;
                final categoryState = context.read<TicketCategoryBloc>().state;
                if (categoryState is TicketCategoryLoaded) {
                  final categories = categoryState.categories;
                  final selectedCategory = categories.firstWhere(
                    (category) => category.id == _selectedCategoryId,
                    orElse: () => throw Exception('Category not found'),
                  );
                  categoryName = selectedCategory.issueName;
                } else {
                  throw Exception('Categories not loaded');
                }

                // 3. Crear el ticket con las URLs de los archivos subidos
                final ticket = SupportTicket(
                  customerName: customerName,
                  category: categoryName,
                  type: 'Support', // Tipo por defecto
                  description: _descController.text,
                  customerId: customerId,
                  files: state.fileUrls,
                );

                // 4. Enviar evento para crear el ticket
                context.read<SupportTicketBloc>().add(
                  CreateSupportTicketEvent(ticket),
                );
              } catch (e) {
                AppLogger.navError('Error creating ticket after file upload: $e');
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                setState(() {
                  _isUploading = false;
                });
              }
            } else if (state is SupportTicketCreated) {
              setState(() {
                _isUploading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket submitted successfully')),
              );

              // Limpiar el formulario
              _titleController.clear();
              _descController.clear();
              setState(() {
                _selectedCategoryId = null;
                _selectedImage = null;
              });

              // Volver a la pantalla anterior después de enviar el ticket
              Navigator.of(context).pop();
            } else if (state is SupportTicketError) {
              setState(() {
                _isUploading = false;
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Submit Ticket',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Submit a Ticket',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Ticket Title',
                    filled: true,
                    fillColor: const Color(0xFFF1F3F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                BlocBuilder<TicketCategoryBloc, TicketCategoryState>(
                  builder: (context, state) {
                    if (state is TicketCategoryLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: LoadingIndicator()),
                      );
                    } else if (state is TicketCategoryError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => context
                                  .read<TicketCategoryBloc>()
                                  .add(const LoadTicketCategoriesEvent()),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else if (state is TicketCategoryLoaded) {
                      final categories = state.categories.toList();

                      return DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        items: categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.issueName),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategoryId = val),
                        decoration: InputDecoration(
                          hintText: 'Issue type',
                          filled: true,
                          fillColor: const Color(0xFFF1F3F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (v) =>
                            v == null ? 'Please select an issue type' : null,
                      );
                    } else {
                      // Estado inicial, mostrar un dropdown vacío
                      return DropdownButtonFormField<int>(
                        items: const [],
                        onChanged: null,
                        decoration: InputDecoration(
                          hintText: 'Loading issue types...',
                          filled: true,
                          fillColor: const Color(0xFFF1F3F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    filled: true,
                    fillColor: const Color(0xFFF1F3F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter a description'
                      : null,
                ),
                const SizedBox(height: 18),
                const Text('Have a picture or screenshot? Upload it here!'),
                const SizedBox(height: 8),
                _selectedImage != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_selectedImage!.path),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: _removeImage,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Gallery'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 18,
                                ),
                                foregroundColor: Colors.black87,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.add_a_photo_outlined),
                              label: const Text('Camera'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 18,
                                ),
                                foregroundColor: Colors.black87,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isUploading ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Submit Ticket'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedImage = pickedImage;
        });
        AppLogger.navInfo('Image selected: ${pickedImage.path}');
      }
    } catch (e) {
      if (!mounted) return;
      AppLogger.navError('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _submitTicket() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    try {
      // 1. Obtener información del usuario autenticado
      AppLogger.navInfo('Verificando estado de autenticación');
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      
      // Registrar el estado actual para depuración
      AppLogger.navInfo('Estado actual de AuthBloc: ${authState.runtimeType}');
      
      if (authState is! AuthAuthenticated) {
        AppLogger.navError('Usuario no autenticado: ${authState.runtimeType}');
        throw Exception('Usuario no autenticado');
      }

      final user = (authBloc.state as AuthAuthenticated).user;
      final customerId = user.customerId ?? 0;

      if (customerId == 0) {
        throw Exception(
          'No se encontró ID de cliente en el usuario autenticado',
        );
      }

      // Solicitar los detalles del cliente si no están cargados
      final customerDetailsBloc = context.read<CustomerDetailsBloc>();
      if (customerDetailsBloc.state is! CustomerDetailsLoaded) {
        customerDetailsBloc.add(FetchCustomerDetails(customerId));
        // Continuamos con la información básica del usuario mientras se cargan los detalles
      }
      
      // Determinar el nombre a mostrar (igual que en profile_page.dart)
      String customerName;
      final customerState = customerDetailsBloc.state;
      if (customerState is CustomerDetailsLoaded) {
        customerName = customerState.customerDetails.fullName;
        AppLogger.navInfo('Usando nombre del cliente: $customerName');
      } else {
        customerName = user.name ?? user.email;
        AppLogger.navInfo('Usando nombre del usuario autenticado: $customerName');
      }

      // 2. Obtener el nombre de la categoría seleccionada
      String categoryName;
      final categoryState = context.read<TicketCategoryBloc>().state;
      if (categoryState is TicketCategoryLoaded) {
        final categories = categoryState.categories;
        final selectedCategory = categories.firstWhere(
          (category) => category.id == _selectedCategoryId,
          orElse: () => throw Exception('Category not found'),
        );
        categoryName = selectedCategory.issueName;
      } else {
        throw Exception('Categories not loaded');
      }

      setState(() {
        _isUploading = true;
      });

      // 3. Subir las imágenes si existen
      if (_selectedImage != null) {
        context.read<SupportTicketBloc>().add(
          UploadTicketFilesEvent([File(_selectedImage!.path)]),
        );
      } else {
        // 4. Si no hay imágenes, crear directamente el ticket
        final ticket = SupportTicket(
          customerName: customerName,
          category: categoryName,
          type: 'Support', // Tipo por defecto
          description: _descController.text,
          customerId: customerId,
          files: const [], // Sin archivos
        );

        context.read<SupportTicketBloc>().add(CreateSupportTicketEvent(ticket));
      }

      // El BlocListener se encargará de manejar los estados y mostrar los mensajes
    } catch (e) {
      AppLogger.navError('Error preparing ticket submission: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      setState(() {
        _isUploading = false;
      });
    }
  }
}
