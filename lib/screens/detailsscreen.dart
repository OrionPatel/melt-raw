import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:melt/main.dart';
import 'package:melt/models/movie_model.dart';
import 'package:melt/screens/homescreen.dart';
import 'package:melt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rive/rive.dart';

class DetailsScreen extends StatefulWidget {
  final String movieID;
  const DetailsScreen({super.key, required this.movieID});
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Future<Movie?> _movieDetails;
  bool isDescriptionExpanded = false;
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

 // Function to launch the YouTube trailer
void _launchTrailer(String trailerKey) async {
  // Construct the YouTube URL using the trailer key
  String youtubeUrl = 'https://www.youtube.com/watch?v=$trailerKey';
  
  // Check if the URL can be launched
  if (await canLaunchUrl(youtubeUrl as Uri)) {
    // Launch the URL in a web browser
    await launchUrl(youtubeUrl as Uri);
  } else {
    throw 'Could not launch $youtubeUrl';
  }
}

  @override
  void dispose() {
    for (var controller in controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _movieDetails = getMovieByID(widget.movieID);
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
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          navigateToScreen(context, 0);
        },
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<Movie?>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final movie = snapshot.data!;
            return Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/detailsscreen.png'))),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    CarouselSlider.builder(
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                        ),
                        itemCount: movie.imagesUrl!.length,
                        itemBuilder: (BuildContext context, int itemIndex,
                            int pageViewIndex) {
                          return Image.network(movie.imagesUrl![itemIndex],
                              fit: BoxFit.cover);
                        }),
                    SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          movie.title ?? 'Title not available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          movie.tagline?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        SizedBox(height: 20),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16)
                        ,child: Text(
                            'Age Rating: ${movie.rated ?? 'Rating not available'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Year: ${movie.year}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                          Text(
                            'Rating: ${movie.imdbRating ?? 'Rating not available'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isDescriptionExpanded = !isDescriptionExpanded;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                color: Colors.red[900],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              isDescriptionExpanded
                                  ? movie.description ??
                                      'Description not available'
                                  : (movie.description ??
                                              'Description not available')
                                          .substring(0, 100) +
                                      '...', // Show only the first 100 characters initially
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _launchTrailer('${movie.youtubeTrailerKey}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 51, 50, 50), // Set button color to grey
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_filled,
                              color:
                                  Colors.red, // Set YouTube icon color to red
                            ),
                            SizedBox(
                                width: 8), // Add space between icon and text
                            Text(
                              'Watch Trailer',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
// class DetailsScreen extends StatefulWidget {
//   final String movieID;
//   const DetailsScreen({super.key, required this.movieID});
//   @override
//   _DetailsScreenState createState() => _DetailsScreenState();
// }
// class _DetailsScreenState extends State<DetailsScreen> {
//   late Future<Movie?> _movieDetails;

//   List<SMIBool> riveIconInputs = [];
//   List<StateMachineController?> controllers = [];
//   int selctedNavIndex = 0;

//   void navigateToScreen(BuildContext context, int index) {
//     final List<String> pageKeys = ['/home', '/search', '/details'];
//     final String destination = pageKeys[index];

//     // Get the current route path
//     final currentRoute = GoRouter.of(context).namedLocation;

//     // If already on the selected screen, do nothing
//     if (currentRoute == destination) {
//       return;
//     }

//     // Navigate to the selected screen
//     GoRouter.of(context).go(destination);
//   }

//   void animateTheIcon(int index) {
//     riveIconInputs[index].change(true);
//     Future.delayed(
//       const Duration(seconds: 1),
//       () {
//         riveIconInputs[index].change(false);
//       },
//     );
//   }

//   void riveOnInIt(Artboard artboard, {required String stateMachineName}) {
//     StateMachineController? controller =
//         StateMachineController.fromArtboard(artboard, stateMachineName);

//     artboard.addController(controller!);
//     controllers.add(controller);

//     riveIconInputs.add(controller.findInput<bool>('active') as SMIBool);
//   }

//   @override
//   void dispose() {
//     for (var controller in controllers) {
//       controller?.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _movieDetails = getMovieByID(widget.movieID);
//   }

//    @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: SafeArea(
//         child: Container(
//           // height: 56, //TODO: in future remove height
//           padding: const EdgeInsets.all(12),
//           margin: const EdgeInsets.symmetric(horizontal: 24),
//           decoration: BoxDecoration(
//             color: Colors.redAccent.withOpacity(0.8),
//             borderRadius: const BorderRadius.all(Radius.circular(24)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.redAccent.withOpacity(0.3),
//                 offset: const Offset(0, 20),
//                 blurRadius: 20,
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: List.generate(bottomNavItems.length, (index) {
//               final riveIcon = bottomNavItems[index];
//               return GestureDetector(
//                 onTap: () {
//                   animateTheIcon(index);
                  
//                   navigateToScreen(context, index);
//                 },
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     AnimatedBar(isActive: selctedNavIndex == index),
//                     SizedBox(
//                       height: 36,
//                       width: 36,
//                       child: Opacity(
//                         opacity: selctedNavIndex == index ? 1 : 0.5,
//                         child: RiveAnimation.asset(
//                           riveIcon.src,
//                           artboard: riveIcon.artboard,
//                           onInit: (artboard) {
//                             riveOnInIt(artboard,
//                                 stateMachineName: riveIcon.stateMachineName);
//                           },
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//       floatingActionButton: IconButton(
//         icon: Icon(
//           Icons.arrow_back,
//           color: Colors.white,
//         ),
//         onPressed: () {
//           navigateToScreen(context, 0);
//         },
//       ),
//       backgroundColor: Colors.black,
//       body: FutureBuilder<Movie?>(
//         future: _movieDetails,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             final movie = snapshot.data!;
//             return Container(
//               decoration: const BoxDecoration(
//                   image: DecorationImage(
//                       fit: BoxFit.fill,
//                       image: AssetImage('assets/detailsscreen.png'))),
//             );
//           } else {
//             return Center(child: Text('No data available'));
//           }
//         },
//       ),
//     );
//   }

//}