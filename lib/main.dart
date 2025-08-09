import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lynk_an/presentation/modules/authen_module/splash/src/ui/splash_screen.dart';
import 'package:overlay_support/overlay_support.dart';

import 'common/config.dart';
import 'common/globals.dart';
import 'common/localization/localizations_config.dart';
import 'common/theme.dart';
import 'common/utils/utility.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Config.getPreferences().then((_) {
    Utility.changeStatusBarColor(Colors.transparent, false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]).then((_) {
      Globals.myApp = GlobalKey<MyAppState>();
      runApp(MyApp(
        key: Globals.myApp,
      ));
    });
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Widget? child;

  GlobalKey _key = GlobalKey();
  GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    child = SplashScreen();
  }

  onRestart() async {
    await Config.getPreferences();
    _key = GlobalKey();
    _childKey = GlobalKey();
    child = SplashScreen();
    setState(() {});
  }

  onRefresh() {
    _childKey = GlobalKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        key: _key,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getLightTheme(),
        themeMode: ThemeMode.light,
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Container();
          };
          AppSizes.init(context);
          return MediaQuery(
              key: _childKey,
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.noScaling),
              child: GestureDetector(
                onTap: Utility.hideKeyboard,
                child: child,
              ));
        },
        locale: LocalizationsConfig.getCurrentLocale(),
        supportedLocales: LocalizationsConfig.supportedLocales,
        localizationsDelegates: LocalizationsConfig.localizationsDelegates,
        localeResolutionCallback: (locale, supportedLocales) =>
            LocalizationsConfig.localeResolutionCallback(
                locale, supportedLocales as List<Locale>),
        home: child,
      ),
    ));
  }
}
