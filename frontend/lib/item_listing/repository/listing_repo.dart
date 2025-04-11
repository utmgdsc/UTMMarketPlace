import 'package:dio/dio.dart';
import 'package:utm_marketplace/item_listing/model/filter_options.model.dart';
import 'package:utm_marketplace/item_listing/model/listing.model.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';

class ListingRepo {
  final Map<String, dynamic> _cache = {};

  Future<dynamic> getListings(
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

  Future<ListingModel> getSearchResults(
      {String? searchQuery,
      int limit = 5,
      String? nextPageToken,
      FilterOptions? filterOptions}) async {
    Response response;
    try {
      final queryParams = <String, String>{
        if (searchQuery != null) 'query': searchQuery,
        'limit': limit.toString(),
        if (nextPageToken != null) 'next': nextPageToken,
        if (filterOptions?.priceType != null)
          'price_type': filterOptions!.priceType!,
        if (filterOptions?.lowerPrice != null)
          'lower_price': filterOptions!.lowerPrice!.toString(),
        if (filterOptions?.upperPrice != null)
          'upper_price': filterOptions!.upperPrice!.toString(),
        if (filterOptions?.condition != null)
          'condition': filterOptions!.condition!,
        if (filterOptions?.dateRange != null)
          'date_range': filterOptions!.dateRange!.toIso8601String(),
        if (filterOptions?.campus != null) 'campus': filterOptions!.campus!,
      };

      response = await dio.get('/search', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return ListingModel.fromJson(response.data);
      }
    } catch (e) {
      throw Exception("Failed to load search results: $e");
    }

    throw Exception("Request failed with status code: ${response.statusCode}");
  }
}
