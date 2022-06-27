import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/comments_model.dart';

class BuildComment extends StatelessWidget {
  const BuildComment({Key? key, required this.comments}) : super(key: key);

  final CommentsModel comments;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
          style: const TextStyle(color: CupertinoColors.black)),
      subtitle: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Text(comments.body.toString(),
            style: const TextStyle(color: CupertinoColors.black, fontSize: 19)),
      ),
    );
  }
}
