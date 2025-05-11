import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:reedinook/screens/Authentication/Forget/view/forget.dart';
import 'package:reedinook/screens/Authentication/Login/view/login.dart';
import 'package:reedinook/screens/Authentication/Register/view/register.dart';
import 'package:reedinook/screens/ChatList/view/chat_lists.dart';
import 'package:reedinook/screens/Chats/view/Chatting.dart';
import 'package:reedinook/screens/Dashboard/Home/view/home.dart';
import 'package:reedinook/screens/Dashboard/Notifications/view/notifications.dart';
import 'package:reedinook/screens/Dashboard/Profiles/my_profile/view/component/edit_profile/view/edit_proifle.dart';
import 'package:reedinook/screens/Dashboard/Searchfriend/view/searchfriend.dart';
import 'package:reedinook/screens/Friendreq/view/friendreq.dart';
import 'package:reedinook/screens/Post/view/posts.dart';
import 'package:reedinook/screens/Splash_screen/splash_screen.dart';
import 'package:reedinook/screens/firebase_options.dart';

import 'Dashboard/Profiles/my_profile/view/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'SplashScreen',
    routes: {
      'login': (context) => const MyLogin(),
      'register': (context) => const MyRegister(),
      'home': (context) => const Home(),
      'forget': (context) => Forget(),
      'friendreq': (context) => const Friendreq(),
      'profile': (context) => const Profile(),
      'searchfriend': (context) => SearchFriend(),
      'notifications': (context) => const Notifications(),
      'friendlist': (context) => ChatLists(friendId: ''),
      'chatting': (context) => Chatting(
          friendId: '', friendName: '', profilePicUrl: '', chatRoomId: '', status: '',),
      'posts': (context) => const Posts(
            username: null,
          ),
          'editprofile': (context) => const EditProfile(),
    },
       home: const SplashScreen(),
  ));
}
