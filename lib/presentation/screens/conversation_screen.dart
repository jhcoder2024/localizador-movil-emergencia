import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:localizador_movil_emergencia/domain/entities/sms_message.dart';
import 'package:localizador_movil_emergencia/presentation/providers/conversation_provider.dart';
import 'package:localizador_movil_emergencia/app/di/presentation_module.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;
  const ConversationScreen({super.key, required this.conversationId});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ConversationProvider _provider;
  bool _emojisVisible = false;

  @override
  void initState() {
    super.initState();
    _provider = ConversationProvider(
      smsInboxRepository: getIt(),
      conversationId: widget.conversationId,
    );
    _provider.addListener(_onProviderChange);
    _provider.init();
  }

  void _onProviderChange() {
    if (_provider.messages.isNotEmpty) {
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
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChange);
    _provider.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<ConversationProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.primaries[
                        widget.conversationId.length % Colors.primaries.length],
                    child: Text(
                      widget.conversationId.isNotEmpty
                          ? widget.conversationId[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.conversationId,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: provider.cargando
                      ? const Center(child: CircularProgressIndicator())
                      : provider.messages.isEmpty
                          ? _buildEmptyState()
                          : _buildMessagesList(provider),
                ),
                _buildInputBar(provider),
                if (_emojisVisible) _buildEmojiPicker(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay mensajes',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Envía un mensaje para comenzar',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ConversationProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final msg = provider.messages[index];
        return _buildMessageBubble(msg);
      },
    );
  }

  Widget _buildMessageBubble(SmsMessage msg) {
    final isSent = msg.tipo == MensajeType.sent;
    final hora = '${msg.fecha.hour.toString().padLeft(2, '0')}:${msg.fecha.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isSent
              ? const Color(0xFFD32F2F).withValues(alpha: 0.85)
              : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isSent
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isSent
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.cuerpo,
              style: TextStyle(
                fontSize: 15,
                color: isSent ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hora,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSent
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.grey[500],
                  ),
                ),
                if (isSent) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.estadoEnvio == 'failed'
                        ? Icons.error
                        : Icons.check,
                    size: 14,
                    color: msg.estadoEnvio == 'failed'
                        ? Colors.red[300]
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ConversationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _emojisVisible ? Icons.keyboard : Icons.emoji_emotions_outlined,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _emojisVisible = !_emojisVisible;
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 4),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textController,
            builder: (context, value, _) {
              final isEmpty = value.text.trim().isEmpty;
              return IconButton(
                icon: Icon(
                  Icons.send,
                  color: isEmpty ? Colors.grey[400] : const Color(0xFFD32F2F),
                ),
                onPressed: isEmpty
                    ? null
                    : () async {
                        await provider.enviarMensaje(_textController.text);
                        _textController.clear();
                      },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 300,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          final text = _textController.text;
          final selection = _textController.selection;
          final newText = text.replaceRange(
            selection.start,
            selection.end,
            emoji.emoji,
          );
          _textController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(
              offset: selection.start + emoji.emoji.length,
            ),
          );
        },
        onBackspacePressed: () {
          final text = _textController.text;
          final selection = _textController.selection;
          if (selection.start > 0 && selection.start == selection.end) {
            final newText = text.substring(0, selection.start - 1) +
                text.substring(selection.end);
            _textController.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(
                offset: selection.start - 1,
              ),
            );
          }
        },
        config: Config(
          emojiViewConfig: EmojiViewConfig(
            columns: 7,
            emojiSizeMax: 32,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(
            showSearchViewButton: false,
          ),
        ),
      ),
    );
  }
}
