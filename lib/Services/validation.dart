// ignore_for_file: file_names, unnecessary_null_comparison

class Validation {
  static String? validatePass(String? pass) {
    if (pass == null) {
      return 'Pass không đúng định dạng!';
    }
    if (pass.length < 6) {
      return "Pass phải có ít nhất 6 ký tự";
    } else {
      return null;
    }
  }

  static String? validateEmail(String? email) {
    if (email == null) {
      return 'Email không đúng định dạng!';
    }
    var isValid =
        RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if (!isValid) {
      return "Email không đúng định dạng";
    } else {
      return null;
    }
  }
  
}
