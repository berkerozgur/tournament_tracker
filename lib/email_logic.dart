import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailLogic {
  EmailLogic._();

  static void sendEmail(
    String body,
    String recipient,
    String subject,
  ) async {
    final username = dotenv.get('EMAIL');
    final password = dotenv.get('PASSWORD');

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Tournament Tracker')
      ..recipients.add(recipient)
      ..subject = subject
      ..html = body;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
