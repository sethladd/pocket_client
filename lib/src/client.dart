// Copyright (c) 2015, Ne4istb. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

library pocket_client.client;

import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:pocket_client/src/client_base.dart';

import 'package:pocket_client/src/retrieve_options.dart';
import 'package:pocket_client/src/item_to_add.dart';
import 'package:pocket_client/src/pocket_response.dart';
import 'package:pocket_client/src/pocket_data.dart';
import 'package:pocket_client/src/actions.dart';

class Client extends ClientBase {

	static const addSubUrl = '/v3/add';
	static const sendSubUrl = '/v3/send';
	static const getSubUrl = '/v3/get';

	String accessToken;

	Client(String consumerKey, this.accessToken, [http.Client httpClient = null]) : super(consumerKey, httpClient);

	Future<PocketResponse> getData({RetrieveOptions options}) {
		return _post(getSubUrl, options?.toMap())
		.then((http.Response response) => new PocketResponse.fromJSON(response.body));
	}

	Future<PocketData> addItem(ItemToAdd newItem) {
		return _post(addSubUrl, newItem.toMap())
		.then((http.Response response) => new PocketData.fromMap(JSON.decode(response.body)['item']));
	}

	Future<PocketData> addUrl(String newUrl) {
		return _post(addSubUrl, {'url': Uri.encodeFull(newUrl)})
		.then((http.Response response) => new PocketData.fromMap(JSON.decode(response.body)['item']));
	}

	Future<http.Response> _post(String subUrl, Map<String, String> options) {
		var url = '${ClientBase.rootUrl}$subUrl';

		Map<String, String> body = {
			'consumer_key': consumerKey,
			'access_token': accessToken
		};

		if (options != null)
			body.addAll(options);

		var bodyJson = JSON.encode(body);

		return httpPost(url, bodyJson);
	}

	Future<ActionResults> modify(List<Action> actions) {
		var url = '${ClientBase.rootUrl}$sendSubUrl';

		Map body = {
			'consumer_key': consumerKey,
			'access_token': accessToken
		};

		List<Map<String, String>> actionList = [];

		actions.forEach((Action action) => actionList.add(action.toMap()));

		body['actions'] = actionList;

		var bodyJson = JSON.encode(body);

		return httpPost(url, bodyJson).then((http.Response response) => new ActionResults.fromJSON(response.body));
	}

	Future<ActionResults> archive(int itemId, {DateTime time}) {
		return modify([new ArchiveAction(itemId, time: time)]);
	}

	Future<ActionResults> delete(int itemId, {DateTime time}) {
		return modify([new DeleteAction(itemId, time: time)]);
	}

	Future<ActionResults> favorite(int itemId, {DateTime time}) {
		return modify([new FavoriteAction(itemId, time: time)]);
	}

	Future<ActionResults> unFavorite(int itemId, {DateTime time}) {
		return modify([new UnFavoriteAction(itemId, time: time)]);
	}

	Future<ActionResults> reAdd(int itemId, {DateTime time}) {
		return modify([new ReAddAction(itemId, time: time)]);
	}

	Future<ActionResults> clearTags(int itemId, {DateTime time}) {
		return modify([new ClearTagsAction(itemId, time: time)]);
	}

	Future<ActionResults> addTags(int itemId, List<String> tags, {DateTime time}) {
		return modify([new AddTagsAction(itemId, tags, time: time)]);
	}

	Future<ActionResults> removeTags(int itemId, List<String> tags, {DateTime time}) {
		return modify([new RemoveTagsAction(itemId, tags, time: time)]);
	}

	Future<ActionResults> replaceTags(int itemId, List<String> tags, {DateTime time}) {
		return modify([new ReplaceTagsAction(itemId, tags, time: time)]);
	}

	Future<ActionResults> renameTag(int itemId, String oldTag, String newTag, {DateTime time}) {
		return modify([new RenameTagAction(itemId, oldTag, newTag, time: time)]);
	}
}
