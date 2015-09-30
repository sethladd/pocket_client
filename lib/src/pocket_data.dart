library pocket_client.data;

import 'dart:convert';
import 'package:pocket_client/src/pocket_status.dart';
import 'package:pocket_client/src/pocket_tag.dart';
import 'package:pocket_client/src/pocket_author.dart';
import 'package:pocket_client/src/pocket_video_data.dart';
import 'package:pocket_client/src/pocket_image_data.dart';

class PocketData {

	String itemId;
	String resolvedId;
	String givenUrl;
	String resolvedUrl;
	String givenTitle;
	String resolvedTitle;
	bool isFavorite;
	PocketStatus status;
	String excerpt;
	bool isArticle;
	bool isImage;
	bool isVideo;
	bool hasImages;
	bool hasVideos;
	int wordCount;
	List<PocketTag> tags;
	List<PocketAuthor> authors;
	List<PocketImageData> images;
	List<PocketVideoData> videos;


	PocketData(this.itemId, {this.resolvedId, this.givenUrl, this.resolvedUrl, this.givenTitle, this.resolvedTitle,
		this.isFavorite, this.status, this.excerpt, this.isArticle, this.isImage, this.isVideo, this.hasImages,
		this.hasVideos, this.wordCount, this.tags, this.authors, this.images, this.videos});

	PocketData.fromJSON(String jsonString) {

		Map json = JSON.decode(jsonString);

		itemId = json['item_id'];
		resolvedId = json['resolved_id'];
		givenUrl = json['given_url'];
		resolvedUrl = json['resolved_url'];
		givenTitle = json['given_title'];
		resolvedTitle = json['resolved_title'];
		isFavorite = json['favorite'] == '1';
		status = _convertToPocketStatus(json['status']);
		excerpt = json['excerpt'];
		isArticle = json['is_article'] == '1';
		isImage = json['has_image'] == '2';
		isVideo = json['has_video'] == '2';
		hasImages = json['has_image'] == '1';
		hasVideos = json['has_video'] == '1';
		wordCount = json['word_count'] != null ? int.parse(json['word_count']) : null;
		tags = _convertToTags(json['tags']);
		authors = _convertToAuthors(json['authors']);
		images = _convertToImages(json['images']);
		videos = _convertToVideos(json['videos']);
	}

	List<PocketTag> _convertToTags(data) {
		List<PocketTag> result = [];

		data?.forEach((id, item) => result.add(new PocketTag.fromMap(item)));

		return result;
	}

	List<PocketAuthor> _convertToAuthors(data) {
		List<PocketAuthor> result = [];

		data?.forEach((id, item) => result.add(new PocketAuthor.fromMap(item)));

		return result;
	}

	List<PocketVideoData> _convertToVideos(data) {
		List<PocketVideoData> result = [];

		data?.forEach((id, item) => result.add(new PocketVideoData.fromMap(item)));

		return result;
	}

	List<PocketImageData> _convertToImages(data) {
		List<PocketImageData> result = [];

		data?.forEach((id, item) => result.add(new PocketImageData.fromMap(item)));

		return result;
	}


	PocketStatus _convertToPocketStatus(String statusString) {
		if (statusString == null || statusString.isEmpty)
			return null;

		switch (statusString) {
			case '0':
				return PocketStatus.Normal;
			case '1':
				return PocketStatus.Archived;
			case '2':
				return PocketStatus.ToBeDeleted;
			default:
				throw new ArgumentError('Unknown pocket data status $statusString');
		}
	}
}