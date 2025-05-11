import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Home/view/component/comments/controller/comments_controller.dart';
import 'package:reedinook/screens/Dashboard/Home/view/component/comments/view/comments.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';

class CommentSection extends StatelessWidget {
  final String postId;

  const CommentSection({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CommentsController commentsController = Get.put(
      CommentsController(postId),
      tag: postId, // Use postId as a tag to differentiate instances
    );

    return Obx(() {
      return Row(
        children: [
          IconButton(
            icon: SvgPicture.asset(
              AppAssets.comment,
              color: AppColor.hinttextcolor,
              width: 20,
              height: 20,
            ),
            onPressed: () {
              print('Opening comments for post ID: $postId');
              Get.delete<CommentsController>(tag: postId); // Delete the specific instance when done
               Get.delete<CommentsController>();

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => CommentsScreen(
                  postId: postId, // Pass the post ID
                ),
              );
            },
          ),
          // const SizedBox(width: 4.0),
          
          Text(
            '${commentsController.commentsCount.value} Comments', // Unique comment count
            style: const TextStyle(color: AppColor.unselected),
          ),
        ],
      );
    });
  }
}
