library pocket_client.image_data;

import 'dart:convert';

class PocketImageData {

	String itemId;
	String imageId;
	String sourceUrl;
	int width;
	int height;
	String credit;
	String caption;

	PocketImageData(this.itemId, this.imageId, this.sourceUrl,{ this.width, this.height, this.credit, this.caption});

	PocketImageData.fromJSON(String jsonString) {
    Map json = JSON.decode(jsonString);
    _initFromMap(json);
  }

	PocketImageData.fromMap(Map<String, String> map) {
		_initFromMap(map);
	}

	_initFromMap(Map<String, String> map) {
		itemId = map['item_id'];
		imageId = map['image_id'];
		credit = map['credit'];
		caption = map['caption'];
		sourceUrl = map['src'];
		width = map['width'] == null ? null : int.parse(map['width']);
		height = map['height'] != null ? int.parse(map['height']) : null;
	}
}