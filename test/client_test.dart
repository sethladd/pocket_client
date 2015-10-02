library pocket_client.client_test;

import 'package:pocket_client/pocket_client.dart';
import 'package:test/test.dart';

import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'mocks.dart';

class ClientTests {

	static run() {
		const consumerKey = '1234-abcd1234abcd1234abcd1234';
		const accessToken = '5678defg-5678-defg-5678-defg56';

		const responseJson = '''
				{
				  "status": 1,
				  "complete": 0,
				  "error": "Some error",
				  "since": 1443547195
				}''';

		assertResponse(PocketResponse result) {
			expect(result.status, 1);
			expect(result.complete, 0);
			expect(result.error, 'Some error');
			expect(result.status, 1);
			expect(result.list, {});
		}

		var response = new Response(responseJson, 200);

		const actionResultsJson = '{"status": 0, "action_results":[true, false,true]}';

		assertActionResults(PocketActionResults result) {
			expect(result.hasErrors, true);
			expect(result.results, [true, false, true]);
		}

		var actionResultsResponse = new Response(actionResultsJson, 200);

		group('Get data.', () {
			final url = '${PocketClientBase.rootUrl}${PocketClient.getSubUrl}';

			test('should return data (without request options)', () {
				var client = Mocks.httpClient(response, url, (String body) {
					Map json = JSON.decode(body);
					expect(json.length, 2);
					expect(json['consumer_key'], consumerKey);
					expect(json['access_token'], accessToken);
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.getPocketData().then(assertResponse);
			});

			test('should return data (with options)', () {
				var options = new PocketRetrieveOptions()
					..since = new DateTime(2015, 5, 4)
					..contentType = PocketContentType.video
					..count = 100
					..offset = 10
					..detailType = PocketDetailType.complete
					..domain = 'http://domain.test'
					..search = 'Some search query'
					..isFavorite = true
					..sortType = PocketSortType.site
					..state = PocketState.archive
					..tag = 'cats';

				var client = Mocks.httpClient(response, url, (String body) {
					Map json = JSON.decode(body);

					expect(json.length, 13);
					expect(json['consumer_key'], consumerKey, reason: 'consumer_key');
					expect(json['access_token'], accessToken, reason: 'access_token');
					expect(json['state'], 'archive', reason: 'state');
					expect(json['favorite'], '1', reason: 'favorite');
					expect(json['tag'], 'cats', reason: 'tag');
					expect(json['contentType'], 'video', reason: 'contentType');
					expect(json['sort'], 'site', reason: 'sort');
					expect(json['detailType'], 'complete', reason: 'detailType');
					expect(json['search'], 'Some search query', reason: 'search');
					expect(json['domain'], 'http://domain.test', reason: 'domain');
					expect(json['count'], '100', reason: 'count');
					expect(json['offset'], '10', reason: 'offset');
					expect(json['since'], '1430686800000', reason: 'domain');
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.getPocketData(options: options).then(assertResponse);
			});
		});

		group('Add item.', () {
			final url = '${PocketClientBase.rootUrl}${PocketClient.addSubUrl}';

			test('should add url and return created item', () {
				var newUrl = 'http://test.com/';

				var client = Mocks.httpClient(response, url, (String body) {
					Map json = JSON.decode(body);

					expect(json.length, 3);
					expect(json['consumer_key'], consumerKey, reason: 'consumer_key');
					expect(json['access_token'], accessToken, reason: 'access_token');
					expect(json['url'], 'http://test.com/', reason: 'url');
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.addUrl(newUrl).then(assertResponse);
			});

			test('should add item and return created item', () {
				var newItem = new PocketItemToAdd('http://test.com/')
					..title = 'Test title'
					..tweetId = '123456'
					..tags = ['first', 'second', 'last'];

				var client = Mocks.httpClient(response, url, (String body) {
					Map json = JSON.decode(body);

					expect(json.length, 6);
					expect(json['consumer_key'], consumerKey, reason: 'consumer_key');
					expect(json['access_token'], accessToken, reason: 'access_token');

					expect(json['url'], 'http://test.com/', reason: 'url');
					expect(json['title'], 'Test%20title', reason: 'title');
					expect(json['tweet_id'], '123456', reason: 'tweet_id');
					expect(json['tags'], 'first, second, last', reason: 'tags');
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.addItem(newItem).then(assertResponse);
			});
		});

		group('Actions.', () {
			final url = '${PocketClientBase.rootUrl}${PocketClient.sendSubUrl}';

			test('should send actions', () {
				var actions = [
					new PocketDeleteAction(12340, time: new DateTime.fromMillisecondsSinceEpoch(1430686800000)),
					new PocketArchiveAction(12341, time: new DateTime.fromMillisecondsSinceEpoch(1430686800001)),
					new PocketFavoriteAction(12342, time: new DateTime.fromMillisecondsSinceEpoch(1430686800002))
				];

				var client = Mocks.httpClient(actionResultsResponse, url, (String body) {
					Map json = JSON.decode(body);

					expect(json.length, 3);
					expect(json['consumer_key'], consumerKey, reason: 'consumer_key');
					expect(json['access_token'], accessToken, reason: 'access_token');

					var actionsJson = json['actions'];
					expect(actionsJson.length, 3, reason: 'actions length');
					expect(actionsJson[0]['action'], 'delete', reason: 'actions delete');
					expect(actionsJson[0]['item_id'], '12340', reason: 'actions delete');
					expect(actionsJson[0]['time'], '1430686800000', reason: 'actions delete');

					expect(actionsJson[1]['action'], 'archive', reason: 'actions archive');
					expect(actionsJson[1]['item_id'], '12341', reason: 'actions archive');
					expect(actionsJson[1]['time'], '1430686800001', reason: 'actions archive');

					expect(actionsJson[2]['action'], 'favorite', reason: 'actions favorite');
					expect(actionsJson[2]['item_id'], '12342', reason: 'actions favorite');
					expect(actionsJson[2]['time'], '1430686800002', reason: 'actions favorite');
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.modify(actions).then(assertActionResults);
			});

			test('should archive item', () {

				var client = Mocks.httpClient(actionResultsResponse, url, (String body) {

					Map json = JSON.decode(body);

					expect(json.length, 3);
					expect(json['consumer_key'], consumerKey, reason: 'consumer_key');
					expect(json['access_token'], accessToken, reason: 'access_token');

					var actionsJson = json['actions'];

					expect(actionsJson.length, 1, reason: 'actions length');
					expect(actionsJson[0]['action'], 'archive', reason: 'actions archive');
					expect(actionsJson[0]['item_id'], '12341', reason: 'actions archive');
					expect(actionsJson[0]['time'], '1430686800001', reason: 'actions archive');
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.archive(12341, time: new DateTime.fromMillisecondsSinceEpoch(1430686800001)).then(assertActionResults);
			});

			test('should delete item', () {

				var client = Mocks.httpClient(actionResultsResponse, url, (String body) {

					Map json = JSON.decode(body);

					expect(json.length, 3);
					expect(json['consumer_key'], consumerKey, reason: 'consumer_key');
					expect(json['access_token'], accessToken, reason: 'access_token');

					var actionsJson = json['actions'];

					expect(actionsJson.length, 1, reason: 'actions length');
					expect(actionsJson[0]['action'], 'delete', reason: 'actions delete');
					expect(actionsJson[0]['item_id'], '12342', reason: 'actions delete');
					expect(actionsJson[0]['time'], '1430686800002', reason: 'actions delete');
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.delete(12342, time: new DateTime.fromMillisecondsSinceEpoch(1430686800002)).then(assertActionResults);
			});

			test('should favorite item', () {

				var client = Mocks.httpClient(actionResultsResponse, url, (String body) {

					Map json = JSON.decode(body);

					expect(json.length, 3);
					expect(json['consumer_key'], consumerKey, reason: 'consumer_key');
					expect(json['access_token'], accessToken, reason: 'access_token');

					var actionsJson = json['actions'];

					expect(actionsJson.length, 1, reason: 'actions length');
					expect(actionsJson[0]['action'], 'favorite', reason: 'actions favorite');
					expect(actionsJson[0]['item_id'], '12343', reason: 'actions favorite');
					expect(actionsJson[0]['time'], '1430686800003', reason: 'actions favorite');
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.favorite(12343, time: new DateTime.fromMillisecondsSinceEpoch(1430686800003)).then(assertActionResults);
			});

			test('should unfavorite item', () {

				var client = Mocks.httpClient(actionResultsResponse, url, (String body) {

					Map json = JSON.decode(body);

					expect(json.length, 3);
					expect(json['consumer_key'], consumerKey, reason: 'consumer_key');
					expect(json['access_token'], accessToken, reason: 'access_token');

					var actionsJson = json['actions'];

					expect(actionsJson.length, 1, reason: 'actions length');
					expect(actionsJson[0]['action'], 'unfavorite', reason: 'actions unfavorite');
					expect(actionsJson[0]['item_id'], '12344', reason: 'actions unfavorite');
					expect(actionsJson[0]['time'], '1430686800004', reason: 'actions unfavorite');
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.unFavorite(12344, time: new DateTime.fromMillisecondsSinceEpoch(1430686800004)).then(assertActionResults);
			});

			test('should readd item', () {

				var client = Mocks.httpClient(actionResultsResponse, url, (String body) {

					Map json = JSON.decode(body);

					expect(json.length, 3);
					expect(json['consumer_key'], consumerKey, reason: 'consumer_key');
					expect(json['access_token'], accessToken, reason: 'access_token');

					var actionsJson = json['actions'];

					expect(actionsJson.length, 1, reason: 'actions length');
					expect(actionsJson[0]['action'], 'readd', reason: 'actions readd');
					expect(actionsJson[0]['item_id'], '12345', reason: 'actions readd');
					expect(actionsJson[0]['time'], '1430686800005', reason: 'actions readd');
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.reAdd(12345, time: new DateTime.fromMillisecondsSinceEpoch(1430686800005)).then(assertActionResults);
			});

			test('should tags clear item', () {

				var client = Mocks.httpClient(actionResultsResponse, url, (String body) {

					Map json = JSON.decode(body);

					expect(json.length, 3);
					expect(json['consumer_key'], consumerKey, reason: 'consumer_key');
					expect(json['access_token'], accessToken, reason: 'access_token');

					var actionsJson = json['actions'];

					expect(actionsJson.length, 1, reason: 'actions length');
					expect(actionsJson[0]['action'], 'tags_clear', reason: 'actions tags_clear');
					expect(actionsJson[0]['item_id'], '12346', reason: 'actions tags_clear');
					expect(actionsJson[0]['time'], '1430686800006', reason: 'actions tags_clear');
				});

				var pocket = new PocketClient(consumerKey, accessToken, client);
				pocket.clearTags(12346, time: new DateTime.fromMillisecondsSinceEpoch(1430686800006)).then(assertActionResults);
			});
		});
	}
}

void main() {
	ClientTests.run();
}