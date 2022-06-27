import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:sigma_task/model/comments_model.dart';

class Api {
  static final _api = Api._();

  Api._();

  factory Api() {
    return _api;
  }

  List<CommentsModel> results = [];
  Future<List<CommentsModel>> getComments([int page = 0]) async {
    final response = await http.get(Uri.parse(
        "https://jsonplaceholder.typicode.com/comments?_limit=25&_page=$page"));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      List<CommentsModel> list = jsonResponse
          .map<CommentsModel>((json) => CommentsModel.fromJson(json))
          .toList();

      if (list.isNotEmpty) {
        results.addAll(list);
      }

      return results;
    } else {
      throw Exception("Failed to load data");
    }
  }
}
