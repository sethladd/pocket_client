// Copyright (c) 2015, Ne4istb. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

library pocket_client.authorization;

import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart';

import 'package:pocket_client/src/pocket_client_base.dart';
import 'package:pocket_client/src/pocket_user.dart';

class PocketClientAuthorization extends PocketClientBase {

	static const oauthRequestUrl = '/v3/oauth/request';
	static const oauthTokenUrl = '/auth/authorize';
	static const oauthAccessUrl = '/v3/oauth/authorize';

	PocketClientAuthorization(String consumerKey, [Client httpClient = null]) : super(consumerKey, httpClient);

	Future<String> getRequestToken(String redirectUri) {
		var url = '${PocketClientBase.rootUrl}$oauthRequestUrl';

		Map<String, String> body = {
			'consumer_key': consumerKey,
			'redirect_uri': redirectUri
		};

		var bodyJson = JSON.encode(body);

		return httpPost(url, bodyJson).then((Response response) => JSON.decode(response.body)['code']);
	}

	Future<PocketUser> getAccessToken(String requestToken) {
		var url = '${PocketClientBase.rootUrl}$oauthAccessUrl';

		Map<String, String> body = {
			'consumer_key': consumerKey,
			'code': requestToken
		};

		var bodyJson = JSON.encode(body);

		return httpPost(url, bodyJson).then((Response response) => new PocketUser.fromJSON(response.body));
	}

	static String getAuthorizeUrl(String requestToken, String redirectUri) {
		var encodedRedirectUrl = Uri.encodeQueryComponent(redirectUri);
		return '${PocketClientBase.rootUrl}$oauthTokenUrl?request_token=$requestToken&redirect_uri=$encodedRedirectUrl';
	}
}