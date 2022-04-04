import 'package:flutter/material.dart';
import 'package:flutter_music_app/Screens/chat_overview_screen.dart';
import './Screens/chat_page.dart';
import './Providers/explore.dart';
import './Screens/artist_settings.dart';
import './Screens/instrument_settings.dart';
import './Screens/settings_screen.dart';
import './Screens/explore_page.dart';
import 'package:provider/provider.dart';
import './Providers/auth.dart';
import './Providers/settings.dart';
import './Providers/chat.dart';
import './Screens/auth_screen.dart';
import './Screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Settings(),
        ),
        ChangeNotifierProvider.value(
          value: Explore(),
        ),
        ChangeNotifierProvider.value(
          value: Chat(),
        ),
      ],
      child: Consumer2<Settings, Auth>(
        builder: (ctx, settings, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BandWith',
          theme: !settings.theme
              ? ThemeData(
                  accentColor: Colors.black,
                  brightness: Brightness.light,
                  fontFamily: 'Montserrat',
                )
              : ThemeData(
                  accentColor: Colors.black,
                  brightness: Brightness.dark,
                  fontFamily: 'Montserrat',
                ),
          home: auth.isAuth
              ? ExploreScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ExploreScreen.routeName: (ctx) => ExploreScreen(),
            SettingsScreen.routeName: (ctx) => SettingsScreen(),
            InstrumentSettings.routeName: (ctx) => InstrumentSettings(),
            ArtistSettings.routeName: (ctx) => ArtistSettings(),
            ChatOverviewScreen.routeName: (ctx) => ChatOverviewScreen(),
            ChatPage.routeName: (ctx) => ChatPage(),
          },
        ),
      ),
    );
  }
}
