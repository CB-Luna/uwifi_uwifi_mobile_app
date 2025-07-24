import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/presentation/widgets/loading_indicator.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../features/support/presentation/bloc/ticket_category_bloc.dart';
import '../../../../../features/support/presentation/bloc/ticket_category_event.dart';
import '../../../../../features/support/presentation/bloc/ticket_category_state.dart';
import '../../../../../injection_container.dart' as di;

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
    return BlocProvider(
      create: (_) =>
          di.getIt<TicketCategoryBloc>()
            ..add(const LoadTicketCategoriesEvent()),
      child: const SubmitTicketPage(),
    );
  }
}

class _SubmitTicketPageState extends State<SubmitTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  int? _selectedCategoryId;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              label: const Text('Remove', style: TextStyle(color: Colors.red)),
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
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _submitTicket();
                    }
                  },
                  icon: const Icon(Icons.event_note, color: Colors.green),
                  label: const Text(
                    'Submit Ticket',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ],
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
      AppLogger.navError('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }
  
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }
  
  Future<void> _submitTicket() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an issue type')),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      // Simular carga
      await Future.delayed(const Duration(seconds: 1));
      
      // Aquí iría la lógica real de envío del ticket y la imagen
      // Por ejemplo:
      // 1. Subir la imagen a un almacenamiento (si existe)
      // 2. Obtener la URL de la imagen
      // 3. Crear el ticket con la información y la URL de la imagen
      
      AppLogger.navInfo('Ticket submitted with title: ${_titleController.text}');
      if (_selectedImage != null) {
        AppLogger.navInfo('Image attached: ${_selectedImage!.path}');
      }
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket submitted successfully!')),
      );
      
      // Limpiar el formulario
      _titleController.clear();
      _descController.clear();
      setState(() {
        _selectedCategoryId = null;
        _selectedImage = null;
        _isUploading = false;
      });
      
      // Opcional: volver a la pantalla anterior
      // Navigator.of(context).pop();
    } catch (e) {
      AppLogger.navError('Error submitting ticket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting ticket: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
