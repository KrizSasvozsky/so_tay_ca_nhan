// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:so_tay_mon_an/Services/Validation.dart';

class LoginViewModel {
  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _btnEnter = BehaviorSubject<bool>();

  var emailValidation = StreamTransformer<String, String?>.fromHandlers(
      handleData: (email, sink) {
    sink.add(Validation.validateEmail(email));
  });

  var passValidation = StreamTransformer<String, String?>.fromHandlers(
      handleData: (String? pass, sink) {
    sink.add(Validation.validatePass(pass));
  });

  Stream<String?> get emailStream => _email.stream.transform(emailValidation);
  Sink<String> get emailSink => _email.sink;

  Stream<String?> get passwordStream =>
      _password.stream.transform(passValidation);
  Sink<String> get passwordSink => _password.sink;

  Stream<bool> get btnEnterStream => _btnEnter.stream;
  Sink<bool> get btnEnterSink => _btnEnter.sink;

  LoginViewModel() {
    Rx.combineLatest2(_email, _password, (String email, String password) {
      return Validation.validateEmail(email) == null &&
          Validation.validatePass(password) == null;
    }).listen((enable) {
      btnEnterSink.add(enable);
    });
  }

  dispose() {
    _email.close(); 
    _password.close();
    _btnEnter.close();
  }
}
