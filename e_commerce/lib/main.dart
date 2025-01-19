import 'package:flutter/material.dart';
import 'view/home.dart';
import 'package:firebase_core/firebase_core.dart';

const firebaseConfig = FirebaseOptions(
      apiKey: "AIzaSyCX1vurbIT0fNku7Xyv6YmGUx2SW1OkvXs",
      authDomain: "e-commerce-delmontero.firebaseapp.com",
      projectId: "e-commerce-delmontero",
      storageBucket: "e-commerce-delmontero.firebasestorage.app",
      messagingSenderId: "588642871945",
      appId: "1:588642871945:web:ce6c19325bfe2f28ccf458",
      measurementId: "G-EPV29JBYWE"
);

void main()   async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: firebaseConfig,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), 
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Redirection après 5 secondes
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800, 
      body: Center(
        child: Text(
          'SUNU DIABA',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white, 
          ),
        ),
      ),
    );
  }
}