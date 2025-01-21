import 'package:flutter/material.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context; // Nécessaire pour gérer les redirections

  AuthLoginRequested({
    required this.email,
    required this.password,
    required this.context,
  });
}
