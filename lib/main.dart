/// File: main.dart
/// Purpose: Entry point of the Tailoring Shop Management System Flutter application
/// Functionality: Initializes Firebase, sets up provider architecture, manages app theme, handles authentication wrapper, and defines main app structure
/// Dependencies: Firebase Core, Provider package for state management, various custom services and providers
/// Usage: Automatically runs when the app starts, bootstraps all necessary components and displays the appropriate screen based on authentication status
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/product_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/service_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/review_provider.dart';
import 'providers/global_navigation_provider.dart';
import 'core/injection_container.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/ai/ai_assistance_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/wishlist_screen.dart';
import 'widgets/theme_toggle_widget.dart';
import 'widgets/loading_splash_screen.dart';

// Initialization provider to manage app startup state
class InitializationProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  String? _errorDetails;
  double _progress = 0.0;
  String? _currentStep;

  bool get isInitialized => _isInitialized;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  String? get errorDetails => _errorDetails;
  double get progress => _progress;
  String? get currentStep => _currentStep;

  void updateProgress(double progress, String step) {
    _progress = progress;
    _currentStep = step;
    notifyListeners();
  }

  void setError(String message, String? details) {
    _hasError = true;
    _errorMessage = message;
    _errorDetails = details;
    notifyListeners();
  }

  void setInitialized() {
    _isInitialized = true;
    notifyListeners();
  }

  void retry() {
    _hasError = false;
    _errorMessage = null;
    _errorDetails = null;
    _progress = 0.0;
    _currentStep = null;
    notifyListeners();
  }
}

Future<void> initializeApp(InitializationProvider initProvider) async {
  try {
    // Start initialization
    initProvider.updateProgress(0.1, 'Initializing Flutter...');

    // Initialize Firebase
    initProvider.updateProgress(0.3, 'Connecting to Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize FirebaseService - skip connection test for fast startup
    initProvider.updateProgress(0.5, 'Initializing Firebase Service...');
    final firebaseService = FirebaseService();
    await firebaseService.initializeFirebase(skipConnectionTest: true);

    // Initialize dependency injection container (parallelize with Firebase)
    initProvider.updateProgress(0.7, 'Initializing Services...');

    // Use Future.wait to parallelize initialization where possible
    await Future.wait([
      injectionContainer.initialize(),
      // Add any other parallel initialization here
    ]);

    // Note: Demo accounts can be created via User Management screen
    // No automatic setup - keeps it simple for development

    // Mark as initialized
    initProvider.updateProgress(1.0, 'Ready!');
    initProvider.setInitialized();
  } catch (error, stackTrace) {
    // Handle initialization errors
    initProvider.setError(
      'Failed to initialize application',
      'Error: $error\n\nStack trace: $stackTrace',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error boundary for Flutter framework errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Error: ${details.exception}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  runApp(const MyApp());
                },
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Create initialization provider
  final initProvider = InitializationProvider();

  // Start initialization
  await initializeApp(initProvider);

  runApp(MyApp(initializationProvider: initProvider));
}

class MyApp extends StatefulWidget {
  final InitializationProvider? initializationProvider;

  const MyApp({super.key, this.initializationProvider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeProvider _themeProvider;
  late final InitializationProvider _initProvider;
  bool _isThemeInitialized = false;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    _initProvider = widget.initializationProvider ?? InitializationProvider();
    // Defer theme initialization to avoid blocking app start
    _initializeThemeLater();
  }

  // Initialize theme after app loads to avoid blocking startup
  void _initializeThemeLater() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      await _themeProvider.initializeTheme();
      setState(() => _isThemeInitialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _initProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            injectionContainer.productBloc,
          ),
        ),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => GlobalNavigationProvider()),
        ChangeNotifierProvider.value(value: _themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Tailoring Shop Management System',
            theme: themeProvider.currentThemeData,
            themeMode: themeProvider.currentTheme,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/wishlist': (context) => const WishlistScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => const Scaffold(
                  body: Center(child: Text('Settings - Coming Soon'))),
              '/catalog': (context) => Scaffold(
                  appBar: AppBar(title: Text('Product Catalog')),
                  body: Center(child: Text('Product Catalog - Coming Soon'))),
              // '/new-products': (context) => const NewProductsScreen(),
            },
            onGenerateRoute: (settings) {
              // Handle dynamic routes
              if (settings.name?.startsWith('/product/') == true) {
                final productId = settings.name!.split('/').last;
                debugPrint(
                    '[DEBUG] Main: Navigating to product detail for ID: $productId');
                return MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Product Detail')),
                    body: Center(
                        child:
                            Text('Product Detail: $productId - Coming Soon')),
                  ),
                );
              }
              if (settings.name?.startsWith('/service/') == true) {
                final serviceId = settings.name!.split('/').last;
                debugPrint(
                    '[DEBUG] Main: Navigating to service detail for ID: $serviceId');
                return MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Service Detail')),
                    body: Center(
                        child:
                            Text('Service Detail: $serviceId - Coming Soon')),
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auto theme detection and web theme listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      if (themeProvider.isAutoDetectEnabled) {
        themeProvider.initializeAutoTheme(context);
        themeProvider.setupThemeListener(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<InitializationProvider, AuthProvider>(
      builder: (context, initProvider, authProvider, child) {
        // Show initialization splash screen if not initialized or has error
        if (!initProvider.isInitialized || initProvider.hasError) {
          return LoadingSplashScreen(
            progress: initProvider.progress,
            currentStep: initProvider.currentStep,
            errorMessage: initProvider.errorMessage,
            errorDetails: initProvider.errorDetails,
            onRetry: initProvider.hasError
                ? () async {
                    initProvider.retry();
                    // Restart initialization
                    await initializeApp(initProvider);
                  }
                : null,
          );
        }

        // Fast auth state check - avoid loading screen
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tailoring Shop Management'),
        toolbarHeight: kToolbarHeight + 5,
        actions: [
          const ThemeToggleWidget(),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => _showChatbot(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.design_services,
                    size: 64,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Welcome to Your',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Tailoring Shop Management System',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Complete AI-Enabled Solution for Modern Tailoring Businesses',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Features Grid
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: const [
                _FeatureCard(
                  icon: Icons.people,
                  title: 'Customer Management',
                  description: 'Manage customer profiles and measurements',
                  color: Colors.blue,
                ),
                _FeatureCard(
                  icon: Icons.inventory,
                  title: 'Product Catalog',
                  description: 'Browse and manage tailoring services',
                  color: Colors.green,
                ),
                _FeatureCard(
                  icon: Icons.receipt_long,
                  title: 'Order Tracking',
                  description: 'Real-time order status and progress',
                  color: Colors.orange,
                ),
                _FeatureCard(
                  icon: Icons.smart_toy,
                  title: 'AI Chatbot',
                  description: '24/7 intelligent customer support',
                  color: Colors.purple,
                ),
                _FeatureCard(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  description: 'Analytics and business insights',
                  color: Colors.teal,
                ),
                _FeatureCard(
                  icon: Icons.cloud_upload,
                  title: 'Cloud Sync',
                  description: 'Real-time data synchronization',
                  color: Colors.indigo,
                ),
              ],
            ),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Column(
              children: [
                _ActionButton(
                  title: 'Browse Products',
                  subtitle: 'View our catalog',
                  icon: Icons.shopping_bag,
                  onPressed: () => _showMessage(
                      context, 'Product catalog feature coming soon!'),
                ),
                _ActionButton(
                  title: 'View Orders',
                  subtitle: 'Track your orders',
                  icon: Icons.receipt,
                  onPressed: () => _showMessage(
                      context, 'Order management feature coming soon!'),
                ),
                _ActionButton(
                  title: 'AI Assistant',
                  subtitle: 'Get help instantly',
                  icon: Icons.chat,
                  onPressed: () => _showChatbot(context),
                ),
                _ActionButton(
                  title: 'Dashboard',
                  subtitle: 'View analytics',
                  icon: Icons.dashboard,
                  onPressed: () =>
                      _showMessage(context, 'Dashboard feature coming soon!'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showChatbot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AIAssistanceScreen(),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        onTap: onPressed,
      ),
    );
  }
}
