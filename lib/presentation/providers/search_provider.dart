import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:localizador_movil_emergencia/domain/entities/sms_message.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_inbox_repository.dart';

class SearchProvider extends ChangeNotifier {
  final SmsInboxRepository _smsInboxRepository;

  List<SmsMessage> _results = [];
  bool _isSearching = false;
  String _query = '';
  Timer? _debounce;

  SearchProvider({required SmsInboxRepository smsInboxRepository})
      : _smsInboxRepository = smsInboxRepository;

  List<SmsMessage> get results => _results;
  bool get isSearching => _isSearching;
  String get query => _query;

  void search(String query) {
    _query = query;
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      _results = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      _isSearching = true;
      notifyListeners();

      _results = await _smsInboxRepository.searchMessages(query);
      _isSearching = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
