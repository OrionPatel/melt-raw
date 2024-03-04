import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/homescreen.dart';
import 'screens/splashscreen.dart';
import 'screens/detailsscreen.dart';
import 'services/services.dart';
import 'screens/searchscreen.dart';
import 'models/movie_model.dart';
//done
class MyAppRoutes {
  final GoRouter _router = GoRouter(
      initialLocation: '/splash',
      errorPageBuilder: (BuildContext context, state) => MaterialPage(
            key: state.pageKey,
            child: Scaffold(
              body: Center(
                child: Text(
                  'Error: ${state.error}',
                ),
              ),
            ),
          ),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => SplashScreen(),
        ),
        GoRoute(
          path: '/splash',
          builder: (BuildContext context, state) => SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (BuildContext context, state) => HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (BuildContext context, state) => SearchScreen(),
        ),
        GoRoute(
          path: '/details/:id',
          builder: (BuildContext context, state) {
            final movieId = state.pathParameters['id'];
            return DetailsScreen(movieID: movieId!);
          },
        )
      ]);
}
//done
Future<void> testAsyncFunction() async {
  // Movie? inception = await getMovieByID('tt1375666');
  //   print(inception?.title);

  print('Testing asynchronous function called!');
  print('calling the getMovieByTitle');
  searchMovieResults? searchResults = await getMovieByTitle('Harry Potter');
  print('fucntion called successfully');
  List<MovieResults>? movieResults = searchResults?.movieResults;
  print(movieResults);
  // Example: Await an asynchronous operation
  await Future.delayed(Duration(seconds: 1));
  print('Async operation completed!');
}
//done
class NavIndexProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
//done
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavIndexProvider()),
        ChangeNotifierProvider(create: (_) => LikeButtonColorProvider()),
      ],
      child: MyApp(),
    ),
  );
  //testAsyncFunction();
}
//done
class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: MyAppRoutes()._router,
    );
  }
}
