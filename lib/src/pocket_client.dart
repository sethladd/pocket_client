// Copyright (c) 2015, Ne4istb. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

library pocket_client.client;

import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart';

import 'package:pocket_client/src/pocket_client_base.dart';

import 'package:pocket_client/src/pocket_retrieve_options.dart';
import 'package:pocket_client/src/pocket_item_to_add.dart';
import 'package:pocket_client/src/pocket_response.dart';
import 'package:pocket_client/src/pocket_actions.dart';

class PocketClient extends PocketClientBase {

	static const addSubUrl = '/v3/add';
	static const sendSubUrl = '/v3/send';
	static const getSubUrl = '/v3/get';

	String accessToken;

	PocketClient(String consumerKey, this.accessToken, [Client httpClient = null]) : super(consumerKey, httpClient);

	Future<PocketResponse> getPocketData({PocketRetrieveOptions options}) {
		return _post(getSubUrl, options?.toMap());
	}

	Future<PocketResponse> addItem(PocketItemToAdd newItem) {
		return _post(addSubUrl, newItem.toMap());
	}

	Future<PocketResponse> addUrl(String newUrl) {
		return _post(addSubUrl, {'url': Uri.encodeFull(newUrl)});
	}

	Future<PocketResponse> _post(String subUrl, Map<String, String> options) {
		var url = '${PocketClientBase.rootUrl}$subUrl';

		Map<String, String> body = {
			'consumer_key': consumerKey,
			'access_token': accessToken
		};

		if (options != null)
			body.addAll(options);

		var bodyJson = JSON.encode(body);

		return httpPost(url, bodyJson).then((Response response) => new PocketResponse.fromJSON(response.body));
	}

	Future<PocketActionResults> modify(List<PocketAction> actions) {
		var url = '${PocketClientBase.rootUrl}$sendSubUrl';

		Map body = {
			'consumer_key': consumerKey,
			'access_token': accessToken
		};

		List<Map<String, String>> actionList = [];

		actions.forEach((PocketAction action) => actionList.add(action.toMap()));

		body['actions'] = actionList;

		var bodyJson = JSON.encode(body);

		return httpPost(url, bodyJson).then((Response response) => new PocketActionResults.fromJSON(response.body));
	}

	Future<PocketActionResults> archive(int itemId, {DateTime time}) {
		return modify([new PocketArchiveAction(itemId, time: time)]);
	}

	Future<PocketActionResults> delete(int itemId, {DateTime time}) {
		return modify([new PocketDeleteAction(itemId, time: time)]);
	}

	Future<PocketActionResults> favorite(int itemId, {DateTime time}) {
		return modify([new PocketFavoriteAction(itemId, time: time)]);
	}

	Future<PocketActionResults> unFavorite(int itemId, {DateTime time}) {
		return modify([new PocketUnFavoriteAction(itemId, time: time)]);
	}

	Future<PocketActionResults> reAdd(int itemId, {DateTime time}) {
		return modify([new PocketReAddAction(itemId, time: time)]);
	}

	Future<PocketActionResults> clearTags(int itemId, {DateTime time}) {
		return modify([new PocketClearTagsAction(itemId, time: time)]);
	}
}
