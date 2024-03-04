import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:melt/main.dart';
import 'package:melt/models/movie_model.dart';
import 'package:melt/screens/homescreen.dart';
// import 'package:melt/screens/searchscreen1.dart';
import 'package:melt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:rive/rive.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Future<searchMovieResults?>? _searchFuture;
  final TextEditingController _controller = TextEditingController();
  List<SMIBool> riveIconInputs = [];
  List<StateMachineController?> controllers = [];
  int selctedNavIndex = 0;

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

  void _searchMovies(String text) {
    setState(() {
      _searchFuture = getMovieByTitle(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
          
          // height: 56, //TODO: in future remove height
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/navbar.png'), fit: BoxFit.fill),
          ),
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
      ),
      floatingActionButton: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          GoRouter.of(context).go('/home');
        },
      ),
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/searchscreen.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/search.png'),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '...',
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _searchMovies(_controller.text);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<searchMovieResults?>(
                future: _searchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 3, color: Colors.white),
                        ),
                        child: Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white))));
                  } else if (snapshot.hasData) {
                    final results = snapshot.data!;
                    return ListView.builder(
                      itemCount: results.movieResults!.length,
                      itemBuilder: (context, index) {
                        final movie = results.movieResults![index];
                        return ListTile(
                          tileColor: Colors.grey[900],
                          title: Text(movie.title ?? 'Unknown',style: const TextStyle(color: Colors.white),),
                          subtitle: Text('Year: ${movie.year ?? 'Unknown'}', style: const TextStyle(color: Colors.white),),
                          onTap: () {
                            final movieId = movie.imdbId;
                            GoRouter.of(context).go('/details/$movieId');
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('Nothing to look here ;)'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
