import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/ad_model.dart';
import 'videos_local_data_source.dart';

const cachedVideos = 'CACHED_VIDEOS';

class VideosLocalDataSourceImpl implements VideosLocalDataSource {
  final SharedPreferences sharedPreferences;

  VideosLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<AdModel>> getLastVideos() async {
    final jsonString = sharedPreferences.getString(cachedVideos);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => AdModel.fromJson(json)).toList();
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheVideos(List<AdModel> videos) async {
    final jsonList = videos.map((video) => video.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(cachedVideos, jsonString);
  }

  @override
  Future<AdModel> getVideo(String id) async {
    final videos = await getLastVideos();
    final video = videos.firstWhere(
      (video) => video.id == id,
      orElse: () => throw CacheException(),
    );
    return video;
  }
}
