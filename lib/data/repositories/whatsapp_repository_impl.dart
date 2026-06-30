import 'package:url_launcher/url_launcher.dart';
import 'package:localizador_movil_emergencia/domain/repositories/whatsapp_repository.dart';

class WhatsappRepositoryImpl implements WhatsappRepository {
  @override
  Future<bool> abrirWhatsApp(String telefono, String mensaje) async {
    final telefonoLimpio = telefono.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    final url = 'https://wa.me/$telefonoLimpio?text=${Uri.encodeComponent(mensaje)}';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> estaInstalado() async {
    try {
      final url = 'https://wa.me/0000000000';
      return await canLaunchUrl(Uri.parse(url));
    } catch (_) {
      return false;
    }
  }
}
