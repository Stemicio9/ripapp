import 'package:flutter/material.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/MyLocalizations.dart';

class RecoverEmailSentPage extends StatefulWidget {
  @override
  _RecoverEmailSentPageState createState() => _RecoverEmailSentPageState();
}

class _RecoverEmailSentPageState extends State<RecoverEmailSentPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppTheme.baseColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.baseColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),
            Text(
              MyLocalizations.of(context, "recover_email_sent"),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            SizedBox(height: height * 0.05),
            Center(
                child: Image.asset("assets/mail_sent.png", width: width * 0.5, fit: BoxFit.cover)
            ),
            SizedBox(height: height * 0.1),
            Row(
              children: [
                Expanded(
                  child: RoundedButton(MyLocalizations.of(context, "back_to_login"), AppTheme.baseColor, Colors.white, () {
                    Navigator.of(context).pop();
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
