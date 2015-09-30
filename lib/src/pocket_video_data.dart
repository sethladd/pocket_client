library pocket_client.video_data;

import 'dart:convert';

class PocketVideoData {

	String itemId;
	String videoId;
	String sourceUrl;
	int width;
	int height;
	int type;
	String vId;

	PocketVideoData(this.itemId, this.videoId, this.sourceUrl, {this.width, this.height, this.type, this.vId});

	PocketVideoData.fromJSON(String jsonString) {
    Map json = JSON.decode(jsonString);
    _initFromMap(json);
  }

	PocketVideoData.fromMap(Map<String, String> map) {
		_initFromMap(map);
	}

	_initFromMap(Map<String, String> map) {
		itemId = map['item_id'];
		videoId = map['video_id'];
		vId = map['vid'];
		sourceUrl = map['src'];
		width = map['width'] == null ? null : int.parse(map['width']);
		height = map['height'] != null ? int.parse(map['height']) : null;
		type = map['type'] != null ? int.parse(map['type']) : null;
	}
}