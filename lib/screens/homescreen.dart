import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:melt/main.dart';
import 'package:melt/models/movie_model.dart';
import 'package:melt/services/services.dart';
import 'package:melt/models/rivemodel.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import 'package:go_router/go_router.dart';
//rive_model.dart
List<RiveModel> bottomNavItems = [
  RiveModel(
      src: "assets/animated-icons.riv",
      artboard: "HOME",
      stateMachineName: "HOME_Interactivity"),
  RiveModel(
      src: "assets/animated-icons.riv",
      artboard: "SEARCH",
      stateMachineName: "SEARCH_Interactivity"),
  RiveModel(
      src: "assets/animated-icons.riv",
      artboard: "USER",
      stateMachineName: "USER_Interactivity"),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SMIBool> riveIconInputs = [];
  List<StateMachineController?> controllers = [];
  int selctedNavIndex = 0;
  // final List<String> pageKeys = ["/home", "/search", "/details"];

  // 
  
  void navigateToScreen(BuildContext context, int index) {
  final List<String> pageKeys = ['/home', '/search', '/details'];
  final String destination = pageKeys[index];

  // Get the current route path
  final currentRoute = GoRouter.of(context).namedLocation;

  // If already on the selected screen, do nothing
  if (currentRoute == destination) {
    return;
  }

  // Navigate to the selected screen
  GoRouter.of(context).go(destination);
}

  void animateTheIcon(int index) {
    riveIconInputs[index].change(true);
    Future.delayed(
      const Duration(seconds: 1),
      () {
        riveIconInputs[index].change(false);
      },
    );
  }

  void riveOnInIt(Artboard artboard, {required String stateMachineName}) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, stateMachineName);

    artboard.addController(controller!);
    controllers.add(controller);

    riveIconInputs.add(controller.findInput<bool>('active') as SMIBool);
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NavIndexProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 30, 0, 0),
        title: const Text(
          'MELT',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          // height: 56, //TODO: in future remove height
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/navbar.png'),
              fit: BoxFit.fill,),),
          child: Consumer<NavIndexProvider>(
            builder: (context, provider, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(bottomNavItems.length, (index) {
                final riveIcon = bottomNavItems[index];
                return GestureDetector(
                  onTap: () {
                    animateTheIcon(index);
                    provider.setIndex(index);
                    navigateToScreen(context, index);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBar(isActive: provider.selectedIndex == index),
                      SizedBox(
                        height: 36,
                        width: 36,
                        child: Opacity(
                          opacity: provider.selectedIndex == index ? 1 : 0.5,
                          child: RiveAnimation.asset(
                            riveIcon.src,
                            artboard: riveIcon.artboard,
                            onInit: (artboard) {
                              riveOnInIt(artboard,
                                  stateMachineName: riveIcon.stateMachineName);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/homescreen.png'),fit: BoxFit.fill)),
        child: FutureBuilder<List<String>?>(
          future: getNowPlaying(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final movieIds = snapshot.data!;
              final likeButtonStates =
                  List.generate(movieIds.length, (index) => false);
              return MovieGrid(
                  movieIds: snapshot.data!, likeButtonStates: likeButtonStates);
            } else {
              return Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(56, 0, 0, 0).withOpacity(0.7),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          offset: const Offset(0, 25),
                          blurRadius: 20),
                    ]),
                child: const Center(
                    child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.amber),
                )),
              );
            }
          },
        ),
      ),
    );
  }
}

//logic.dart
class LikeButtonColorProvider extends ChangeNotifier {
  bool _isLiked = false;

  bool get isLiked => _isLiked;

  void toggleLiked() {
    _isLiked = !_isLiked;
    notifyListeners();
  }
}
//ui_components.dart
class MovieGrid extends StatelessWidget {
  final List<String> movieIds;
  final List<bool> likeButtonStates;

  const MovieGrid(
      {Key? key, required this.movieIds, required this.likeButtonStates})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 8,
      ),
      itemCount: movieIds.length,
      itemBuilder: (context, index) {
        return FutureBuilder<Movie?>(
          future: getMovieByID(movieIds[index]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final movie = snapshot.data!;

              return ChangeNotifierProvider(
                create: (_) => LikeButtonColorProvider(),
                child: Consumer<LikeButtonColorProvider>(
                    builder: (context, likebuttonProvider, _) {
                  return GridTile(
                    child: GestureDetector(
                      onTap: () {
                        final movieId = movie.imdbId;
                        GoRouter.of(context).go('/details/$movieId');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(138, 63, 63, 63)
                                .withOpacity(0.7),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.45),
                                  offset: const Offset(0, 25),
                                  blurRadius: 20),
                            ]),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Image.network(movie.imagesUrl!.first,
                                      fit: BoxFit.cover
                                      // Ensure the image fits within the constraints
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(movie.title ?? 'Title not available',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                    textAlign: TextAlign.left),
                                SizedBox(height: 4),
                                Text(movie.year ?? 'Year not available',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center),
                                SizedBox(height: 4),
                              ],
                            ),
                            Positioned(
                                top: 8, // Adjust top position as needed
                                right: 8, // Adjust right position as needed
                                child: Consumer<LikeButtonColorProvider>(
                                  builder: (context, likeButtonProvider, _) {
                                    return IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                         color: likeButtonProvider.isLiked ? Colors.red : Colors.white,
                                  ),
                                  onPressed: () {
                                    likeButtonProvider.toggleLiked();
                                      },
                                    );
                                  },
                                ),),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}
//ui_components.dart
class AnimatedBar extends StatelessWidget {
  const AnimatedBar({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 2),
      height: 4,
      width: isActive ? 20 : 0,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
