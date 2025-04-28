import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/chat_message.dart';
import '../../services/gemini_service.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());
final chatBoxProvider = FutureProvider<Box<ChatMessage>>((ref) async {
  return await Hive.openBox<ChatMessage>('chat_messages');
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  Box<ChatMessage>? _chatBox;
  bool _isInitializing = true;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _initChat();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _isKeyboardVisible = _focusNode.hasFocus;
    });
  }

  Future<void> _initChat() async {
    try {
      _chatBox = await Hive.openBox<ChatMessage>('chat_messages');
      if (_chatBox!.isEmpty) {
        _addWelcomeMessage();
      }
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _addWelcomeMessage() async {
    if (_chatBox == null) return;
    const welcomeText =
        '👋 Hi! I\'m Bizzy Bot, your AI assistant. I can help you with:\n\n'
        '• Business analytics and insights\n'
        '• Sustainability tips and tracking\n'
        '• Product management advice\n'
        '• General business queries\n\n'
        'How can I assist you today?';

    final welcomeMessage = ChatMessage.bot(welcomeText);
    _chatBox!.add(welcomeMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatBox == null) return;

    final message = _messageController.text;
    _messageController.clear();
    _focusNode.unfocus();

    final userMessage = ChatMessage.user(message);
    _chatBox!.add(userMessage);
    setState(() {
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response =
          await ref.read(geminiServiceProvider).sendMessage(message);
      final botMessage = ChatMessage.bot(response);
      _chatBox!.add(botMessage);
    } catch (e) {
      final errorMessage =
          ChatMessage.bot('Sorry, something went wrong. Please try again.');
      _chatBox!.add(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LoadingSpinner(size: 48),
              SizedBox(height: 16),
              Text('Initializing chat...'),
            ],
          ),
        ),
      );
    }

    if (_chatBox == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to initialize chat'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initChat,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Bizzy Bot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat history',
            onPressed: () async {
              await _chatBox?.clear();
              _addWelcomeMessage();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<Box<ChatMessage>>(
                valueListenable: _chatBox!.listenable(),
                builder: (context, box, _) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final message = box.getAt(index)!;
                      return _ChatMessageWidget(message: message);
                    },
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _LoadingSpinner(size: 16),
                    SizedBox(width: 8),
                    Text('Bizzy Bot is typing...'),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: _isKeyboardVisible ? 8 : 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      key: ValueKey(message.id),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isUser
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _LoadingSpinner extends StatelessWidget {
  final double size;

  const _LoadingSpinner({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
