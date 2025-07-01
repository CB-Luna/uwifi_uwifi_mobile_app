import 'package:flutter/material.dart';

class SubmitTicketPage extends StatefulWidget {
  const SubmitTicketPage({super.key});

  @override
  State<SubmitTicketPage> createState() => _SubmitTicketPageState();
}

class _SubmitTicketPageState extends State<SubmitTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _selectedIssueType;
  // String? _uploadedPhotoPath; // Aquí iría la lógica real de subida de foto

  final List<String> _issueTypes = [
    'WiFi Connection',
    'Equipment',
    'Coverage',
    'Incorrect Billing',
    'Unauthorized Changes to Service Plan',
    'Promos and Offers',
    'Unsatisfactory Customer Services',
    'RMA',
    'U-app points',
    'Free-U Questions',
  ];

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
              DropdownButtonFormField<String>(
                value: _selectedIssueType,
                items: _issueTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedIssueType = val),
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
                validator: (v) => v == null || v.isEmpty
                    ? 'Please select an issue type'
                    : null,
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
