import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:instagram_clone/controller/theme/cubit/theme_config.dart';
import 'package:instagram_clone/controller/theme/cubit/theme_cubit.dart';
import 'package:instagram_clone/controller/theme/cubit/theme_state.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/views/FeedPost.dart';
import 'package:instagram_clone/views/OnBoarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  Supabase.initialize(
    url: "https://odszgjegdhuwimkhkbib.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kc3pnamVnZGh1d2lta2hrYmliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MjA4NTEsImV4cCI6MjA1MzM5Njg1MX0.s4H8kg7LT9tOqLOyHxEYbsaxUQ38IZAx3BxR24Rl8XA",
  );
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    Phoenix(
      child: BlocProvider(
        create: (context) => ThemeCubit(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  Locale _currentLocale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
    WidgetsBinding.instance.addObserver(this);
    
    _auth.authStateChanges().listen((firebase_auth.User? user) {
      if (user == null) {
        print('========================User is currently signed out!');
      } else {
        print('========================User is signed in!');
        _updateUserOnlineStatus(true);
      }
    });

    if (_auth.currentUser != null) {
      _updateUserOnlineStatus(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_auth.currentUser != null) {
      _updateUserOnlineStatus(false);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final user = _auth.currentUser;
    if (user == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _updateUserOnlineStatus(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _updateUserOnlineStatus(false);
        break;
      default:
        break;
    }
  }

  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error updating online status: $e');
      }
    }
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('language_code') ?? 'en';
    setState(() {
      _currentLocale = Locale(savedLanguageCode);
    });
  }

  // Add this method to handle language changes globally
  static void changeLanguage(BuildContext context, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    Phoenix.rebirth(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          locale: _currentLocale,
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          builder: (context, child) {
            return Directionality(
              textDirection: _currentLocale.languageCode == 'ar' 
                  ? TextDirection.rtl 
                  : TextDirection.ltr,
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          themeMode: state.themeMode,
          home: _auth.currentUser == null ? OnBoarding() : FeedPost(),
        );
      }
    );
  }
}