import 'dart:convert';
import 'dart:developer';

import 'package:flutter_space_dee/models/response_model.dart';
import 'package:flutter_space_dee/models/social_login_model.dart';
import 'package:flutter_space_dee/models/social_nonce_model.dart';
import 'package:flutter_space_dee/services/configuration.dart';
import 'package:http/http.dart';

class AuthService {
  static Future<ResponseModel<SocialLoginModel>> login({
    required String provider,
    required String token,
    required String nonce,
  }) async {
    log("login");

    final httpString = Configuration.https(
      service: PortConfig.authPort,
      path: 'social/login',
    );

    final uri = Uri.parse(httpString);
    final httpPostResponse = post(
      uri,
      headers: {'Content-Type': 'application/json'},
      // ส่ง provider + token (จาก social SDK) + nonce ให้ backend verify
      body: jsonEncode({'provider': provider, 'token': token, 'nonce': nonce}),
    );

    log("http: $httpString");

    final response = await httpPostResponse;

    log("Response Body (login) : ${response.body}");
    log("Response Status Code (login) : ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseJS = Map.from(jsonDecode(response.body));
      // API ห่อ payload ไว้ใน {success, data:{...}} → ต้องอ่านชั้นใน 'data'
      final ok = responseJS['success'] == true;
      final inner = Map.from(responseJS['data'] ?? {});
      return ResponseModel(
        data: SocialLoginModel(data: inner),
        responseEnum: ok ? ResponseEnum.success : ResponseEnum.fail,
      );
    } else if (response.statusCode == 404) {
      // 404 "account not registered" = ยังไม่ลงทะเบียน → ให้ไปหน้าลงทะเบียน
      return ResponseModel(
        data: SocialLoginModel(data: {}),
        responseEnum: ResponseEnum.accountNotRegistered,
      );
    } else {
      return ResponseModel(
        data: SocialLoginModel(data: {}),
        responseEnum: ResponseEnum.fail,
      );
    }
  }

  static Future<ResponseModel<SocialNonceModel>> nonce() async {
    log("nonce");

    final httpString = Configuration.https(
      service: PortConfig.authPort,
      path: 'social/nonce',
    );

    final uri = Uri.parse(httpString);
    final httpGetResponse = get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    log("http: $httpString");

    final response = await httpGetResponse;

    log("Response Body (nonce) : ${response.body}");
    log("Response Status Code (nonce) : ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseJS = Map.from(jsonDecode(response.body));
      // API ห่อ payload ไว้ใน {success, data:{...}} → ต้องอ่านชั้นใน 'data'
      final ok = responseJS['success'] == true;
      final inner = Map.from(responseJS['data'] ?? {});
      return ResponseModel(
        data: SocialNonceModel(data: inner),
        responseEnum: ok ? ResponseEnum.success : ResponseEnum.fail,
      );
    } else {
      return ResponseModel(
        data: SocialNonceModel(data: {}),
        responseEnum: ResponseEnum.fail,
      );
    }
  }

  static Future<ResponseModel<SocialLoginModel>> register({
    required String provider,
    required String token,
    required String name,
    required String surname,
    required String phone,
    required String email,
  }) async {
    log("register");

    final httpString = Configuration.https(
      service: PortConfig.authPort,
      path: 'social/register',
    );

    final uri = Uri.parse(httpString);
    final httpPostResponse = post(
      uri,
      headers: {'Content-Type': 'application/json'},
      // ส่ง provider + token (จาก social SDK) + nonce ให้ backend verify
      body: jsonEncode({
        'provider': provider,
        'token': token,
        'name': name,
        'surname': surname,
        'phone': phone,
        'email': email,
      }),
    );

    log("http: $httpString");

    final response = await httpPostResponse;

    log("Response Body (register) : ${response.body}");
    log("Response Status Code (register) : ${response.statusCode}");

    if (response.statusCode == 201) {
      final responseJS = Map.from(jsonDecode(response.body));
      // API ห่อ payload ไว้ใน {success, data:{...}} → ต้องอ่านชั้นใน 'data'
      final ok = responseJS['success'] == true;
      final inner = Map.from(responseJS['data'] ?? {});
      return ResponseModel(
        data: SocialLoginModel(data: inner),
        responseEnum: ok ? ResponseEnum.success : ResponseEnum.fail,
      );
    } else {
      return ResponseModel(
        data: SocialLoginModel(data: {}),
        responseEnum: ResponseEnum.fail,
      );
    }
  }

  static Future<ResponseModel> logout({required String refreshToken}) async {
    log("logout");

    final httpString = Configuration.https(
      service: PortConfig.authPort,
      path: 'logout',
    );

    final uri = Uri.parse(httpString);
    final httpPostResponse = post(
      uri,
      headers: {'Content-Type': 'application/json'},
      // backend ใช้ snake_case (เหมือน access_token/refresh_token ใน response)
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    log("http: $httpString");

    final response = await httpPostResponse;

    log("Response Body (logout) : ${response.body}");
    log("Response Status Code (logout) : ${response.statusCode}");

    if (response.statusCode == 200) {
      return ResponseModel(data: {}, responseEnum: ResponseEnum.success);
    } else {
      return ResponseModel(data: {}, responseEnum: ResponseEnum.fail);
    }
  }

  static Future<ResponseModel> refresh({required String refreshToken}) async {
    log("refresh");

    final httpString = Configuration.https(
      service: PortConfig.authPort,
      path: 'refresh',
    );

    final uri = Uri.parse(httpString);
    final httpPostResponse = post(
      uri,
      headers: {'Content-Type': 'application/json'},
      // backend ใช้ snake_case (เหมือน access_token/refresh_token ใน response)
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    log("http: $httpString");

    final response = await httpPostResponse;

    log("Response Body (refresh) : ${response.body}");
    log("Response Status Code (refresh) : ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseJS = Map.from(jsonDecode(response.body));
      // API ห่อ payload ไว้ใน {success, data:{...}} → ต้องอ่านชั้นใน 'data'
      final ok = responseJS['success'] == true;
      final inner = Map.from(responseJS['data'] ?? {});
      return ResponseModel(
        data: inner,
        responseEnum: ok ? ResponseEnum.success : ResponseEnum.fail,
      );
    } else {
      return ResponseModel(data: {}, responseEnum: ResponseEnum.fail);
    }
  }
}
