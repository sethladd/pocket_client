library pocket_client.response;

import 'dart:convert';
import 'package:pocket_client/src/pocket_data.dart';

class PocketResponse {

	int status;
	int complete;
	Map<String, PocketData> list;
	String error;
	DateTime since;

	PocketResponse.fromJSON(String jsonString) {

		Map json = JSON.decode(jsonString);

		status = json['status'];
		complete = json['complete'];
		list = _convertToPocketDataList(json['list']);
		error = json['error'];
		since = json['since'] != null ? new DateTime.fromMillisecondsSinceEpoch(json['since']) : null;
	}

	Map<String, PocketData> _convertToPocketDataList(list) {
		Map<String, PocketData> result = {};

		list?.forEach((id, item) => result[id] = new PocketData.fromMap(item));

		return result;
	}
}