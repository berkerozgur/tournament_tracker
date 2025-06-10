import 'dart:developer' as dev show log;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// NOTE: This email logic is configured for local development only.
// Emails are captured using smtp4dev running on localhost.
// TODO: Replace this setup with a real SMTP configuration before deploying to production.

class EmailLogic {
  EmailLogic._();

  static Future<void> sendEmail({
    required String subject,
    required String body,
    String? to,
    List<String>? bcc,
  }) async {
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
      ..subject = subject
      ..html = body;

    if (to != null && to.isNotEmpty) {
      message.recipients.add(to);
    } else if (bcc != null && bcc.isNotEmpty) {
      message.bccRecipients.addAll(bcc);
    } else {
      throw ArgumentError('At least one of "to" or "bcc" must be provided');
    }

    try {
      final sendReport = await send(message, smtpServer);
      dev.log('Message sent: $sendReport');
    } on MailerException catch (e) {
      dev.log('Message not sent. Exception: $e');
      for (var p in e.problems) {
        dev.log('Problem: code=${p.code}, message=${p.msg}');
      }
    } catch (e, stack) {
      dev.log('Unexpected error: $e');
      dev.log(stack.toString());
    }
  }
}
