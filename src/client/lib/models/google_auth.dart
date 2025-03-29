import 'package:client/models/user_dto.dart';

import 'acccess_token_dto.dart';

class GoogleAuthResult {
  final String text;
  final UserDTO user;
  final AccessTokenDTO tokens;

  GoogleAuthResult({
    required this.text,
    required this.user,
    required this.tokens,
  });
}
