import 'package:flutter/material.dart';

class ForgetPasswordDialog extends StatefulWidget {
  ForgetPasswordDialog({Key? key}) : super(key: key);

  @override
  _ForgetPasswordDialogState createState() => _ForgetPasswordDialogState();
}

class _ForgetPasswordDialogState extends State<ForgetPasswordDialog> {
  TextEditingController textEditingController = TextEditingController();
  bool isValid = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        height: 250.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hãy nhập email cần cập nhật mật khẩu',
              style: TextStyle(color: Colors.purple),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: textEditingController,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 50.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop("fail");
                    },
                    child: Text(
                      'Hủy!',
                      style: TextStyle(color: Colors.red, fontSize: 18.0),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop("ok");
                    },
                    child: Text(
                      'Gửi!',
                      style: TextStyle(color: Colors.blue, fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
