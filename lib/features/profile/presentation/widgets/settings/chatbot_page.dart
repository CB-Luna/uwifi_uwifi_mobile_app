import 'package:flutter/material.dart';
import 'package:uwifiapp/core/utils/responsive_font_sizes_screen.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          senderInitials:
              'LN', // Puedes obtener las iniciales del usuario autenticado
        ),
      );
      _messageController.clear();
      _isTyping = true;
    });

    // Scroll al final de la lista
    _scrollToBottom();

    // Simular respuesta del chatbot (esto se reemplazará con la llamada a la API)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isTyping = false;
        // Ejemplo de respuesta basada en el mensaje del usuario
        String botResponse = '';

        if (userMessage.toLowerCase().contains('internet') ||
            userMessage.toLowerCase().contains('conexión')) {
          botResponse =
              "If you have problems with your internet, try restarting your modem and check that your bill is up to date. If the problem persists, contact support for assistance.";
        } else if (userMessage.toLowerCase() == 'hi' ||
            userMessage.toLowerCase() == 'hello') {
          botResponse = "Hello! How can I help you today?";
        } else {
          botResponse =
              "Sorry, I couldn't process that. Could you provide more details?";
        }

        _messages.add(ChatMessage(text: botResponse, isUser: false));
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    // Dar tiempo para que se actualice la UI
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'U- Chatbot',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // Ocultar teclado al tocar fuera
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Conversation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (_messages.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _messages.clear();
                          });
                        },
                        child: const Text(
                          'Clear History',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _messages.isEmpty
                    ? const Center(
                        child:
                            SizedBox(), // Espacio vacío cuando no hay mensajes
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: message.isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message.isUser) ...[
                                  Flexible(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.7,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        message.text,
                                        style: TextStyle(
                                          fontSize: responsiveFontSizesScreen
                                              .bodyMedium(context),
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey.shade400,
                                    child: Text(
                                      message.senderInitials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.green.shade100,
                                    child: Image.asset(
                                      'assets/images/homeimage/launcher.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.7,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        message.text,
                                        style: TextStyle(
                                          fontSize: responsiveFontSizesScreen
                                              .bodyMedium(context),
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.green.shade100,
                        child: Image.asset(
                          'assets/images/homeimage/launcher.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Writing...",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 24,
                ), // Aumentado el padding inferior
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Bot generated responses maybe inaccurate or misleading, Be sure to double check responses.',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Ask a question',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String senderInitials;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.senderInitials = '',
  });
}
