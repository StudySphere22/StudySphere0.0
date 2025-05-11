// Import statements remain unchanged
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Dashboard/Home/view/component/shares/controller/share_controller.dart';
import 'package:reedinook/screens/Dashboard/Home/view/component/shares/view/shares.dart';
import 'package:reedinook/utils/app_assets%20.dart';
import 'package:reedinook/utils/colors.dart';

class ShareSection extends StatelessWidget {
  final String postId;

  const ShareSection({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Get.find to fetch the already initialized controller for this postId
   final ShareController shareController = Get.put(
      ShareController(postId),
      tag: postId, // Use postId as a tag to differentiate instances
    );
    
    return GestureDetector(
      onTap: () {
        
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return ShareScreen(postId: postId);
          },
        );
      },
      child: Row(
        children: [
          SvgPicture.asset(
          AppAssets.share, // Path to your SVG file
          color: AppColor.hinttextcolor,
          width: 20.0, 
          height: 20.0, 
          ),
          const SizedBox(width: 4.0),
          Obx(() => Text(
            '${shareController.sharesCount.value} Shares',
            style: const TextStyle(color: AppColor.unselected),
          )),
        ],
      ),
    );
  }
}
