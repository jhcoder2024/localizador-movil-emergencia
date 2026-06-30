abstract class WhatsappRepository {
  Future<bool> abrirWhatsApp(String telefono, String mensaje);
  Future<bool> estaInstalado();
}
