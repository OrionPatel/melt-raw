import 'rivemodel.dart';

class NavItemModel {
  final String title;
  final RiveModel rive;

  NavItemModel({required this.title, required this.rive});
}

List<NavItemModel> _bottomNavItems = [
    NavItemModel(title: "Home", 
    rive: RiveModel(
      src: "assets/animated-icons.riv",
      artboard: "HOME",
      stateMachineName: "HOME_Interactivity"),
    ),
    NavItemModel(
      title: "Search",
      rive: RiveModel(
      src: "assets/animated-icons.riv",
      artboard: "SEARCH",
      stateMachineName: "SEARCH_Interactivity"
      ),
    ),
    NavItemModel(
      title: "User",
      rive: RiveModel(
      src: "assets/animated-icons.riv",
      artboard: "USER",
      stateMachineName: "USER_Interactivity"),
    ),
  // RiveModel(
  //     src: "assets/animated-icons.riv",
  //     artboard: "CHAT",
  //     stateMachineName: "CHAT_Interactivity"),
  // RiveModel(
  //     src: "assets/animated-icons.riv",
  //     artboard: "SEARCH",
  //     stateMachineName: "SEARCH_Interactivity"),
  
  //     ,
  // RiveModel(
  //     src: "assets/animated-icons.riv",
  //     artboard: "BELL",
  //     stateMachineName: "BELL_Interactivity"),
  
];

