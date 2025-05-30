import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// NOTE: This email logic is configured for local development only.
// Emails are captured using smtp4dev running on localhost.
// TODO: Replace this setup with a real SMTP configuration before deploying to production.

class EmailLogic {
  EmailLogic._();

  static void sendEmail(
    String body,
    String recipient,
    String subject,
  ) async {
    final username = dotenv.get('EMAIL');
    // final password = dotenv.get('PASSWORD');

    // final smtpServer = gmail(username, password);
    final smtpServer = SmtpServer(
      'localhost',
      port: 25,
      ssl: false,
      allowInsecure: true,
      // TODO: Replace 'localhost' with real SMTP host and configure auth for production.
    );

    final message = Message()
      ..from = Address(username, 'Tournament Tracker')
      ..recipients.add(recipient)
      ..subject = subject
      ..html = body;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent. Exception: $e');
      for (var p in e.problems) {
        print('Problem: code=${p.code}, message=${p.msg}');
      }
    } catch (e, stack) {
      print('Unexpected error: $e');
      print(stack);
    }
  }
}
