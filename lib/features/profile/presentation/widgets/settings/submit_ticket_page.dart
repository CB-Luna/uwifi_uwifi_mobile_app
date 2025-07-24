import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/widgets/loading_indicator.dart';
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
  // String? _uploadedPhotoPath; // Aquí iría la lógica real de subida de foto

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
              const Text('Have a  pictures or screenshot? Upload it here!'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {}, // Aquí iría la lógica de subir foto
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Upload Photo'),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Aquí iría la lógica de envío
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ticket submitted!')),
                      );
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
}
