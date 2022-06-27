import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sigma_task/model/comments_model.dart';
import 'package:sigma_task/view/widgets/comments.dart';
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

  bool checkDataIndicator = false;

  bool stopFetch = false;
  final controller = TextEditingController();

  final ValueNotifier<bool> isActive = ValueNotifier(true);
  List<CommentsModel> comments = [];
  final _scrollController = ScrollController();
  final _refreshController = RefreshController();

  @override
  void initState() {
    getData();
    super.initState();

    addListener();
  }

  void addListener() {
    _scrollController.addListener(() async {
      if (_isBottom && stopFetch == false) {
        toggleIndicatorVisibility();
        page += 1;

        final data = await _api.getComments(page);

        setState(() {
          comments = data;
          checkDataIndicator = false;
        });
      }
    });
  }

  bool get _isBottom {
    if (_scrollController.hasClients) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        return true;
      }
    }

    return false;
  }

  void toggleIndicatorVisibility() {
    setState(() {
      checkDataIndicator = !checkDataIndicator;
    });
  }

  Future<void> _refresh() async {
    if (stopFetch == false) {
      toggleIndicatorVisibility();
      _api.results.clear();
      page = 1;

      await getData();
      _refreshController.loadComplete();

      toggleIndicatorVisibility();
    }
    _refreshController.refreshCompleted();
  }

  Future getData() async {
    await _api.getComments().then((value) {
      setState(() {
        comments = value;
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
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            ValueListenableBuilder(
              valueListenable: isActive,
              builder: (context, value, child) {
                return Header(
                  isActive: isActive.value,
                  onpress: () {
                    isActive.value = !isActive.value;
                  },
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: CupertinoSearchTextField(
                controller: controller,
                onSuffixTap: () {
                  setState(() {
                    controller.text = "";
                    stopFetch = false;

                    comments = _api.results;
                  });
                },
                padding: const EdgeInsets.all(15),
                onChanged: searchComment,
              ),
            ),
            _api.results.isEmpty
                ? const CircularProgressIndicator()
                : Expanded(
                    child: Stack(
                      children: [
                        SmartRefresher(
                          controller: _refreshController,
                          scrollController: _scrollController,
                          enablePullUp: false,
                          onRefresh: _refresh,
                          child: GroupedListView<CommentsModel, String>(
                            shrinkWrap: true,
                            elements: comments,
                            sort: false,
                            groupBy: (element) => element.postId.toString(),
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
                                title: Column(
                                  children: [
                                    BuildComment(comments: element),
                                    const Divider(
                                      color: CupertinoColors.systemGrey,
                                    )
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: isActive,
                                      builder: (context, value, child) {
                                        return GestureDetector(
                                            onTap: isActive.value
                                                ? () {
                                                    setState(() {
                                                      comments.remove(element);
                                                      _api.results
                                                          .remove(element);
                                                    });
                                                  }
                                                : null,
                                            child: Icon(
                                                CupertinoIcons.delete_solid,
                                                color: isActive.value
                                                    ? Colors.blue
                                                    : Colors.transparent));
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        checkDataIndicator
                            ? const Align(
                                alignment: Alignment.bottomCenter,
                                child: CircularProgressIndicator())
                            : const SizedBox(),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void searchComment(String query) {
    if (query.isNotEmpty) {
      final comments = _api.results.where((comment) {
        final nameLower = comment.name!.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower);
      }).toList();
      stopFetch = true;
      setState(() {
        this.query = query;
        this.comments = comments;
      });
    } else {
      stopFetch = false;
    }
  }
}
