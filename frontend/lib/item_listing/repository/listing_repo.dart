import 'package:utm_marketplace/shared/dio/dio.dart';

class ListingRepo {
  final Map<String, dynamic> _cache = {};

  Future<dynamic> fetchData(
      {int limit = 6, String? nextPageToken, String? query}) async {
    final cacheKey = '$limit-$nextPageToken-$query';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final queryParameters = <String, dynamic>{
        'limit': limit.toString(),
      };

      if (nextPageToken != null) {
        queryParameters['next'] = nextPageToken;
      }

      if (query != null) {
        queryParameters['query'] = query;
      }

      final response =
          await dio.get('/listings', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        _cache[cacheKey] = response.data;
        return response.data;
      } else {
        throw Exception('Failed to load listings');
      }
    } catch (e) {
      throw Exception('Failed to load listings: $e');
    }
  }
}
