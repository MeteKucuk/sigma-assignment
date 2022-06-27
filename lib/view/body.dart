import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:sigma_task/model/comments_model.dart';
import 'package:sigma_task/view/widgets/header.dart';

import '../data/api.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _api = Api();
  int page = 1;
  String query = '';
  bool _isLoading = false;

  bool _isFirstLoading = true;
  final ValueNotifier<bool> _isActive = ValueNotifier(true);
  List<CommentsModel> comments = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    getData();
    super.initState();

    _scrollController = ScrollController();

    addListener();
  }

  void addListener() {
    _scrollController.addListener(() async {
      if (_isBottom) {
        page += 1;
        setState(() {
          _isLoading = true;
        });
        final data = await _api.getComments(page);

        setState(() {
          comments = data;
          _isLoading = false;
        });
      }
    });
  }

  bool get _isBottom {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) return true;

    return false;
  }

  Future getData() async {
    await _api.getComments().then((value) {
      setState(() {
        comments = value;
        _isFirstLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Header(isActive: _isActive),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: CupertinoSearchTextField(
                    padding: const EdgeInsets.all(15),
                    onChanged: searchComment,
                  ),
                ),
                _isFirstLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: GroupedListView<CommentsModel, String>(
                          shrinkWrap: true,
                          controller: _scrollController,
                          elements: comments,
                          sort: false,
                          groupBy: (element) => element.postId.toString(),
                          groupComparator: (value1, value2) =>
                              value2.compareTo(value1),
                          itemComparator: (item1, item2) =>
                              item2.id!.compareTo(item1.id!.toInt()),
                          order: GroupedListOrder.DESC,
                          useStickyGroupSeparators: true,
                          groupSeparatorBuilder: (String value) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Post $value",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          itemBuilder: (c, element) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              title: Column(
                                children: [
                                  buildComment(element),
                                  const Divider(
                                    color: CupertinoColors.systemGrey,
                                  )
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ValueListenableBuilder(
                                    valueListenable: _isActive,
                                    builder: (context, value, child) {
                                      return GestureDetector(
                                          onTap: _isActive.value
                                              ? () {
                                                  setState(() {
                                                    comments.remove(element);
                                                    _api.results
                                                        .remove(element);
                                                  });
                                                }
                                              : null,
                                          child: const Icon(
                                              CupertinoIcons.delete_solid,
                                              color: Colors.blue));
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
            _isLoading
                ? const Align(
                    alignment: Alignment.bottomCenter,
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget buildComment(CommentsModel comments) => ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text("Name:${comments.name.toString()}",
                  style:
                      TextStyle(color: CupertinoColors.black.withOpacity(0.7))),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text("E-mail: ${comments.email.toString()}",
                  style:
                      TextStyle(color: CupertinoColors.black.withOpacity(0.7))),
            ),
          ],
        ),
        leading: Text(comments.id.toString(),
            style: TextStyle(color: CupertinoColors.black)),
        subtitle: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Text("${comments.body.toString()}",
              style: TextStyle(color: CupertinoColors.black, fontSize: 19)),
        ),
      );

  void searchComment(String query) {
    final comments = _api.results.where((comment) {
      final nameLower = comment.name!.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower);
    }).toList();

    setState(() {
      this.query = query;
      this.comments = comments;
    });
  }
}
