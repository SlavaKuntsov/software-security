class AccessTokenDTO {
  final String accessToken;
  final String refreshToken;

  AccessTokenDTO({required this.accessToken, required this.refreshToken});

  factory AccessTokenDTO.fromJson(Map<String, dynamic> json) {
    return AccessTokenDTO(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
