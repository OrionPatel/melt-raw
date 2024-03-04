import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:melt/services/services.dart';
import 'package:melt/models/movie_model.dart';
import 'package:melt/models/rivemodel.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
//done
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
//done
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  _SearchScreenState createState() => _SearchScreenState();
}
//done
class _SearchScreenState extends State<SearchScreen> {
  Future<searchMovieResults?>? _searchFuture;
  TextEditingController _controller = TextEditingController();

  final List<String> pageKeys = ["/home", "/search", "/details"];
  void navigateToScreen(int index) {
  final String destination = pageKeys[index]; // Get the destination path based on the index
  final currentRoute = GoRouter.of(context).namedLocation; // Get the current route path
  if (currentRoute == destination) {
    // If already on the selected screen, do nothing
    return;
  }
  GoRouter.of(context).go(destination); // Navigate to the selected screen
}

  void _searchMovies(String text) {
    setState(() {
      _searchFuture = getMovieByTitle(text);
    });
  }

 


  List<SMIBool> riveIconInputs = [];
  List<StateMachineController?> controllers = [];
  int selctedNavIndex = 0;

  void riveOnInIt(Artboard artboard, {required String stateMachineName}) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, stateMachineName);

    artboard.addController(controller!);
    controllers.add(controller);

    riveIconInputs.add(controller.findInput<bool>('active') as SMIBool);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      floatingActionButton: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          GoRouter.of(context).go('/home');
        },
      ),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/homescreen.png'), fit: BoxFit.fill),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const SizedBox(height: 50),
            Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 241, 130, 130), width: 3,),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextField(
                    
                    controller: _controller,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                      
                      border: InputBorder.none,
                        hintText: 'Search your movie...',
                        hintStyle: TextStyle(color: Colors.redAccent),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            _searchMovies(_controller.text);
                          },
                        )),
                  ),
                )),
            Expanded(
              child: FutureBuilder<searchMovieResults?>(
                future: _searchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Container(
                        child: Center(
                            child: Text('Error: ${snapshot.error}',
                                style: TextStyle(color: Colors.white))),
                        decoration: BoxDecoration(
                          border: Border.all(width: 3, color: Colors.white),
                        ));
                  } else if (snapshot.hasData) {
                    final results = snapshot.data!;
                    return ListView.builder(
                      itemCount: results.movieResults!.length,
                      itemBuilder: (context, index) {
                        final movie = results.movieResults![index];
                        return ListTile(
                          title: Text(movie.title ?? 'Unknown'),
                          subtitle: Text('Year: ${movie.year ?? 'Unknown'}'),
                          onTap: () {
                            final movieId = movie.imdbId;
                            GoRouter.of(context).go('/details/$movieId');
                          },
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No results found'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // body: Container(
      //   decoration: const BoxDecoration(
      //       image:
      //           DecorationImage(image: AssetImage('assets/detailsscreen.png'))),
      // ),
    );
  }
}

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
