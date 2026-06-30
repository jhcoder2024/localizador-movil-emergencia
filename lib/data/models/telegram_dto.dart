class SendMessageRequest {
  final String chatId;
  final String text;
  final String parseMode;

  const SendMessageRequest({
    required this.chatId,
    required this.text,
    this.parseMode = 'Markdown',
  });

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'text': text,
        'parse_mode': parseMode,
      };
}

class SendMessageResponse {
  final bool ok;
  final MessageResult? result;
  final String? description;

  const SendMessageResponse({
    required this.ok,
    this.result,
    this.description,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) =>
      SendMessageResponse(
        ok: json['ok'] as bool,
        result: json['result'] != null
            ? MessageResult.fromJson(json['result'] as Map<String, dynamic>)
            : null,
        description: json['description'] as String?,
      );
}

class MessageResult {
  final int messageId;

  const MessageResult({required this.messageId});

  factory MessageResult.fromJson(Map<String, dynamic> json) =>
      MessageResult(messageId: json['message_id'] as int);
}
