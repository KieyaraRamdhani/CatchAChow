import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'planning_tools.dart';

String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
String get apiBaseUrl =>
    dotenv.env['CATCHACHOW_API_URL'] ?? 'http://10.0.2.2:8000';
bool get supabaseReady => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

const ink = Color(0xFF24130D);
const green = Color(0xFFD20E22);
const mint = Color(0xFFFFE8A3);
const cream = Color(0xFFFFF9EB);
const orange = Color(0xFFFFC928);
const butterYellow = Color(0xFFFFF0A6);

final ValueNotifier<ThemeMode> catchThemeMode =
    ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint('No .env file found; demo mode will be available.');
  }

  final prefs = await SharedPreferences.getInstance();
  catchThemeMode.value = prefs.getBool('catchachow_dark_mode') == true
      ? ThemeMode.dark
      : ThemeMode.light;

  if (supabaseReady) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (error) {
      debugPrint('Supabase initialisation failed: $error');
    }
  }

  runApp(const CatchAChowApp());
}

class Product {
  final String id;
  final String name;
  final String retailer;
  final String category;
  final String size;
  final double price;
  final String checked;
  final String note;

  const Product(
    this.id,
    this.name,
    this.retailer,
    this.category,
    this.size,
    this.price,
    this.checked,
    this.note,
  );
}

const products = <Product>[
  Product('P001', 'Iwisa No. 1 Super Maize Meal', 'Checkers', 'Staple',
      '2.5 kg', 25.49, '20 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P002', 'Golden Delight Parboiled Rice', 'Checkers', 'Staple', '2 kg',
      29.99, '23 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P003', 'Koo Baked Beans in Tomato Sauce', 'Makro', 'Protein',
      '400 g', 16.95, '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P004', 'Potatoes', 'Shoprite', 'Vegetable', '2 kg', 29.99,
      '23 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P005', 'Onions', 'Checkers', 'Vegetable', '1 kg', 19.98,
      '20 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P006', 'Eggs', 'Shoprite', 'Protein', '18 pack', 49.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P007', 'Long-life milk', 'Pick n Pay', 'Dairy', '1 L', 16.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P008', 'Brown bread', 'Checkers', 'Bakery', '700 g', 17.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P009', 'Chicken portions', 'Boxer', 'Protein', '1 kg', 64.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P010', 'Dry sugar beans', 'Shoprite', 'Protein', '500 g', 24.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P011', 'Tomatoes', 'Food Lover’s Market', 'Vegetable', '1 kg', 24.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P012', 'Carrots', 'SPAR', 'Vegetable', '1 kg', 15.99, '25 Oct 2026',
      'Sample listing; verify at retailer.'),
  Product('P013', 'Cabbage', 'Shoprite', 'Vegetable', '1 head', 18.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P014', 'Peanut butter', 'Checkers', 'Pantry', '400 g', 34.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P015', 'Tinned pilchards', 'Boxer', 'Protein', '400 g', 24.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P016', 'Pasta', 'Makro', 'Staple', '500 g', 14.99, '25 Oct 2026',
      'Sample listing; verify at retailer.'),
  Product('P017', 'Oats', 'Woolworths Food', 'Breakfast', '1 kg', 39.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P018', 'Bananas', 'Food Lover’s Market', 'Fruit', '1 kg', 22.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P019', 'Frozen mixed vegetables', 'Checkers', 'Vegetable', '1 kg',
      34.99, '25 Oct 2026', 'Sample listing; verify at retailer.'),
  Product('P020', 'Boerewors', 'Bluff Meat Supply', 'Protein', '500 g', 49.99,
      '25 Oct 2026', 'Sample listing; verify at retailer.'),
];

class CatchAChowApp extends StatelessWidget {
  const CatchAChowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: catchThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'CatchAChow',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: cream,
            colorScheme: ColorScheme.fromSeed(
              seedColor: green,
              primary: green,
              secondary: orange,
              surface: cream,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: cream,
              foregroundColor: ink,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: green,
              brightness: Brightness.dark,
              primary: const Color(0xFFFFD45A),
              secondary: orange,
            ),
          ),
          home: const CatchSplashScreen(),
        );
      },
    );
  }
}

class CatchSplashScreen extends StatefulWidget {
  const CatchSplashScreen({super.key});

  @override
  State<CatchSplashScreen> createState() => _CatchSplashScreenState();
}

class _CatchSplashScreenState extends State<CatchSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: orange,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Image.asset(
                  'assets/images/catchachow_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.soup_kitchen_rounded,
                    color: Colors.white,
                    size: 58,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'CatchAChow',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Good food. Better days.',
                style: TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(color: green),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!supabaseReady) return const AuthScreen();

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (Supabase.instance.client.auth.currentSession != null) {
          return const BasketHome();
        }
        return const AuthScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();

  DateTime? _dob;
  bool _signup = false;
  bool _needsCode = false;
  bool _loading = false;
  String _message = '';

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (_signup &&
        (_name.text.trim().isEmpty ||
            _surname.text.trim().isEmpty ||
            _phone.text.trim().length < 7 ||
            _dob == null)) {
      setState(() {
        _message =
            'Complete your name, surname, date of birth and phone number.';
      });
      return false;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim())) {
      setState(() => _message = 'Enter a valid email address.');
      return false;
    }

    if (_password.text.length <= 6 ||
        !RegExp(r'[^A-Za-z0-9]').hasMatch(_password.text)) {
      setState(() {
        _message =
            'Password must be at least 7 characters and contain a special character.';
      });
      return false;
    }

    return true;
  }

  Future<void> _submit() async {
    if (!supabaseReady) {
      setState(() {
        _message =
            'Supabase is not configured. You can explore the app in demo mode.';
      });
      return;
    }

    if (_needsCode) {
      await _verify();
      return;
    }
    if (!_validateInputs()) return;

    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      if (_signup) {
        await Supabase.instance.client.auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
          data: {
            'name': _name.text.trim(),
            'surname': _surname.text.trim(),
            'phone': _phone.text.trim(),
            'date_of_birth': _dob!.toIso8601String().substring(0, 10),
          },
        );
        if (mounted) {
          setState(() {
            _needsCode = true;
            _message = 'Check your email and enter your confirmation code.';
          });
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BasketHome()),
          );
        }
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } catch (error) {
      if (mounted) {
        setState(
            () => _message = 'Authentication failed. Check your connection.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    if (!supabaseReady) return;
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: _email.text.trim(),
        token: _code.text.trim(),
        type: OtpType.signup,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BasketHome()),
        );
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } catch (_) {
      if (mounted) {
        setState(
            () => _message = 'Verification failed. Check the code and retry.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Image.asset(
                      'assets/images/catchachow_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.soup_kitchen_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'CatchAChow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _needsCode
                        ? 'Verify your email'
                        : _signup
                            ? 'Create your student account'
                            : 'Welcome back',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_needsCode) ...[
                    if (_signup) ...[
                      TextField(
                        controller: _name,
                        decoration: _dec('Name', Icons.person_outline),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _surname,
                        decoration: _dec('Surname', Icons.person_outline),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2005),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) setState(() => _dob = date);
                        },
                        child: InputDecorator(
                          decoration:
                              _dec('Date of birth', Icons.cake_outlined),
                          child: Text(
                            _dob == null
                                ? 'Choose date'
                                : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _dec('Email address', Icons.email_outlined),
                    ),
                    const SizedBox(height: 10),
                    if (_signup) ...[
                      TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: _dec('Phone number', Icons.phone_outlined),
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: _dec('Password', Icons.lock_outline),
                    ),
                    if (_signup)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Use at least 7 characters and include a special character.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ] else
                    TextField(
                      controller: _code,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: _dec(
                        'Email confirmation code',
                        Icons.verified_user_outlined,
                      ),
                    ),
                  const SizedBox(height: 14),
                  if (_message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0D0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_message),
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed:
                        _loading ? null : (_needsCode ? _verify : _submit),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _needsCode
                                ? 'Confirm email'
                                : _signup
                                    ? 'Create account'
                                    : 'Log in',
                          ),
                  ),
                  if (!_needsCode)
                    TextButton(
                      onPressed: () => setState(() {
                        _signup = !_signup;
                        _message = '';
                      }),
                      child: Text(
                        _signup
                            ? 'Already have an account? Log in'
                            : 'New here? Create an account',
                      ),
                    ),
                  if (_needsCode)
                    TextButton(
                      onPressed: () => setState(() {
                        _needsCode = false;
                        _signup = true;
                        _message = '';
                      }),
                      child: const Text('Back to signup'),
                    ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const BasketHome()),
                      );
                    },
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Explore demo without an account'),
                  ),
                  if (!supabaseReady)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Configure Supabase in .env to enable real accounts. Demo mode does not create an account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BasketHome extends StatefulWidget {
  const BasketHome({super.key});

  @override
  State<BasketHome> createState() => _BasketHomeState();
}

class _BasketHomeState extends State<BasketHome> {
  int tab = 0;
  double budget = 80;
  int people = 2;
  final Map<String, int> basket = {};
  List<Product> liveProducts = [];
  bool loadingLiveProducts = false;
  String liveProductMessage =
      'Connect approved retailer feeds on the backend to see live prices.';

  final TextEditingController _aiController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  String _lastAiPrompt = '';
  final List<Map<String, String>> _chat = [
    {
      'role': 'bot',
      'text':
          'Sawubona! I help with meal planning and shopping lists. Tell me your budget, household size and what you want to eat.',
    },
  ];

  List<Product> get allProducts => [...products, ...liveProducts];

  Product? _findProduct(String id) {
    for (final product in allProducts) {
      if (product.id == id) return product;
    }
    return null;
  }

  double get total => basket.entries.fold<double>(
        0,
        (sum, entry) =>
            sum + ((_findProduct(entry.key)?.price ?? 0) * entry.value),
      );

  int get count =>
      basket.values.fold<int>(0, (sum, quantity) => sum + quantity);

  void add(Product product) {
    setState(() {
      basket[product.id] = (basket[product.id] ?? 0) + 1;
    });
  }

  void remove(Product product) {
    setState(() {
      final quantity = basket[product.id] ?? 0;
      if (quantity <= 1) {
        basket.remove(product.id);
      } else {
        basket[product.id] = quantity - 1;
      }
    });
  }

  Future<void> loadLiveProducts() async {
    setState(() {
      loadingLiveProducts = true;
      liveProductMessage = 'Checking configured retailer feeds…';
    });

    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/api/products'))
          .timeout(const Duration(seconds: 18));
      if (response.statusCode != 200) {
        throw Exception('Product API returned ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (data['products'] as List? ?? []).whereType<Map>().toList();
      final converted = <Product>[];

      for (var index = 0; index < items.length; index++) {
        final item = Map<String, dynamic>.from(items[index]);
        final price = (item['price'] as num?)?.toDouble();
        if (price == null) continue;

        converted.add(
          Product(
            'LIVE_$index',
            (item['name'] ?? item['title'] ?? 'Product').toString(),
            (item['retailer'] ?? 'Retailer').toString(),
            (item['category'] ?? 'Grocery').toString(),
            (item['size'] ?? 'Size not supplied').toString(),
            price,
            (item['checked_at'] ?? 'Feed result').toString(),
            (item['product_url'] ?? '').toString(),
          ),
        );
      }

      if (mounted) {
        setState(() {
          liveProducts = converted;
          liveProductMessage = converted.isEmpty
              ? 'No products were returned by the configured feeds.'
              : 'Loaded ${converted.length} products. Confirm local branch prices and stock.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          liveProductMessage =
              'Could not reach the product API. Check the backend URL and feed permissions. Sample prices are not live prices.';
        });
      }
    } finally {
      if (mounted) setState(() => loadingLiveProducts = false);
    }
  }

  @override
  void dispose() {
    _aiController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      homePage(),
      shopPage(),
      mealsPage(),
      aiPage(),
      basketPage(),
      morePage(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: butterYellow,
                child: const Text(
                  'CatchAChow 🇿🇦\nGood food. Better days.',
                  style: TextStyle(
                    color: ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _drawerItem(Icons.home_outlined, 'Home', 0),
              _drawerItem(Icons.storefront_outlined, 'Grocery prices', 1),
              _drawerItem(Icons.restaurant_menu, 'South African meals', 2),
              _drawerItem(Icons.smart_toy_outlined, 'AI Chow', 3),
              _drawerItem(Icons.shopping_cart_outlined, 'My basket', 4),
              _drawerItem(Icons.grid_view_rounded, 'More features', 5),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('App settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppSettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Open navigation',
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'CatchAChow 🇿🇦',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppSettingsPage()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        height: 66,
        selectedIndex: tab > 3 ? 0 : tab,
        onDestinationSelected: (index) => setState(() => tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Prices',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy_rounded),
            label: 'AI Chow',
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int destination) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: tab == destination,
      selectedTileColor: butterYellow.withOpacity(.65),
      onTap: () {
        setState(() => tab = destination);
        Navigator.pop(context);
      },
    );
  }

  Widget homePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: ink,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🇿🇦 SOUTH AFRICAN FLAVOUR. SMART SPENDING.',
                style: TextStyle(
                  color: Color(0xFFBCE4C4),
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Good food.\nBetter days.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Plan kasi-inspired meals, stretch your budget, and shop smarter.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _stat(
                          'WEEKLY BUDGET', 'R${budget.toStringAsFixed(0)}')),
                  Expanded(
                      child: _stat(
                          'BASKET TOTAL', 'R${total.toStringAsFixed(2)}')),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value:
                      budget == 0 ? 0 : (total / budget).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: total > budget ? Colors.redAccent : orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'R${(budget - total).toStringAsFixed(2)} ${total > budget ? 'over budget' : 'left to spend'}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Set up your plan', 'Keep your budget realistic.'),
        _card(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Weekly food budget')),
                  Text(
                    'R${budget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: green,
                    ),
                  ),
                ],
              ),
              Slider(
                value: budget,
                min: 40,
                max: 1000,
                divisions: 96,
                onChanged: (value) => setState(() => budget = value),
              ),
              Row(
                children: [
                  const Expanded(child: Text('People eating')),
                  IconButton(
                    onPressed:
                        people > 1 ? () => setState(() => people--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$people'),
                  IconButton(
                    onPressed:
                        people < 12 ? () => setState(() => people++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MealPlanBuilderPage()),
          ),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Build a budget-to-meal plan'),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Catch a chow, not a bill', 'Sample listed prices.'),
        ...products.take(4).map(productTile),
        _notice(
          'Price transparency',
          'These are sample listing prices, not guaranteed live prices. Check local branch prices and availability before purchasing.',
        ),
      ],
    );
  }

  Widget shopPage() {
    final shownProducts = liveProducts.isEmpty ? products : liveProducts;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Grocery price check',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text('Compare package sizes, sample prices and retailers.'),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: loadingLiveProducts ? null : loadLiveProducts,
          icon: loadingLiveProducts
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: const Text('Refresh connected live prices'),
        ),
        const SizedBox(height: 10),
        _notice(
          liveProducts.isEmpty ? 'Sample listings' : 'Connected feed results',
          liveProductMessage,
        ),
        const SizedBox(height: 12),
        ...shownProducts.map(productTile),
      ],
    );
  }

  Widget mealsPage() {
    const meals = <List<String>>[
      [
        '🍚',
        'Rice with baked beans',
        'Rice and a tin of baked beans',
        'Cook rice according to its package. Heat the beans separately and serve together.'
      ],
      [
        '🥣',
        'Maize meal porridge (pap)',
        'Maize meal and water',
        'Follow the cooking instructions on the maize meal package.'
      ],
      [
        '🍲',
        'Samp and beans',
        'Samp, sugar beans, onion and seasoning',
        'Soak and cook samp and beans according to their package instructions until tender.'
      ],
      [
        '🍛',
        'Chicken stew with pap',
        'Chicken, onion, tomato and maize meal',
        'Simmer chicken with onion and tomato until thoroughly cooked. Serve with pap.'
      ],
      [
        '🥘',
        'Cabbage and carrot stir-fry',
        'Cabbage, carrots and onion',
        'Slice vegetables and stir-fry until tender. Add beans or egg for protein if available.'
      ],
      [
        '🍳',
        'Tomato and onion eggs',
        'Eggs, tomatoes, onion and bread or pap',
        'Cook onion and tomato until soft, add eggs and cook until fully set.'
      ],
      [
        '🐟',
        'Pilchard tomato stew',
        'Tinned pilchards, tomato and onion',
        'Soften onion and tomato, fold in pilchards, heat thoroughly and serve with rice or pap.'
      ],
      [
        '🍝',
        'Tomato pasta',
        'Pasta, tomatoes and onion',
        'Boil pasta and simmer tomatoes and onion into a simple sauce.'
      ],
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Kasi-style meal ideas 🇿🇦',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
            'Simple ideas using familiar and budget-friendly ingredients.'),
        const SizedBox(height: 14),
        ...meals.map(
          (meal) => _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${meal[0]}  ${meal[1]}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meal[2],
                  style: const TextStyle(
                    color: green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(meal[3]),
              ],
            ),
          ),
        ),
        _notice(
          'Nutrition note',
          'These are meal ideas, not personalised medical or nutrition advice. Portions and costs vary.',
        ),
      ],
    );
  }

  Widget aiPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'AI Chow Planner',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        _notice(
          'Food-only assistant',
          'Ask about meals, recipes, food budgets, ingredients and shopping lists. The backend must be configured for AI replies.',
        ),
        const SizedBox(height: 12),
        ..._chat.map(
          (message) => Align(
            alignment: message['role'] == 'user'
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: message['role'] == 'user'
                    ? green
                    : butterYellow.withOpacity(.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message['text'] ?? '',
                style: TextStyle(
                  color: message['role'] == 'user' ? Colors.white : ink,
                ),
              ),
            ),
          ),
        ),
        _card(
          child: Column(
            children: [
              TextField(
                controller: _calorieController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Daily calorie target (optional)',
                  helperText: 'AI estimates are not medical advice.',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _aiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ask about meals, food prep or your budget…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sendMealRequest,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Build my meal plan'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendMealRequest() async {
    final prompt = _aiController.text.trim();
    if (prompt.isEmpty) return;

    _lastAiPrompt = prompt;
    final calorieTarget = int.tryParse(_calorieController.text.trim());
    _aiController.clear();
    setState(() => _chat.add({'role': 'user', 'text': prompt}));

    const foodWords = [
      'eat',
      'meal',
      'food',
      'recipe',
      'budget',
      'rand',
      'shopping',
      'ingredient',
      'cook',
      'breakfast',
      'lunch',
      'dinner',
      'people',
      'days',
      'pap',
      'rice',
      'chicken',
      'beans',
      'vegetable',
      'grocery',
      'under',
      'calorie',
      'nutrition',
      'restaurant',
      'catchachow'
    ];

    if (!foodWords.any(prompt.toLowerCase().contains)) {
      setState(() {
        _chat.add({
          'role': 'bot',
          'text':
              'I can help with food, meal preparation, recipes, grocery budgeting and shopping lists.',
        });
      });
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': prompt,
              'budget_zar': budget,
              'people': people,
              'days': 7,
              'dietary_preferences': <String>[],
              'daily_calorie_target': calorieTarget,
              'known_products': products
                  .map(
                    (product) => {
                      'name': product.name,
                      'retailer': product.retailer,
                      'size': product.size,
                      'sample_price_zar': product.price,
                      'price_is_live': false,
                    },
                  )
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 28));

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _chat.add({
            'role': 'bot',
            'text': (data['answer'] ?? 'No answer was returned.').toString(),
          });
        });
      } else {
        setState(() {
          _chat.add({
            'role': 'bot',
            'text':
                'The AI service could not complete this request. Check your backend and try again.',
          });
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _chat.add({
            'role': 'bot',
            'text':
                'Could not reach the AI service. Check your backend URL and connection.',
          });
        });
      }
    }
  }

  Widget basketPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'My chow basket',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text('$count packages · Budget R${budget.toStringAsFixed(2)}'),
        const SizedBox(height: 14),
        if (basket.isEmpty)
          _card(
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 42, color: green),
                  SizedBox(height: 10),
                  Text(
                    'Your basket is empty',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text('Add products from Grocery prices to start planning.'),
                ],
              ),
            ),
          )
        else
          ...basket.entries.map((entry) {
            final product = _findProduct(entry.key);
            if (product == null) return const SizedBox.shrink();
            return _card(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${product.retailer} · R${product.price.toStringAsFixed(2)} each',
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => remove(product),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('${entry.value}'),
                  IconButton(
                    onPressed: () => add(product),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            );
          }),
        _card(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Estimated basket total')),
                  Text(
                    'R${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: green,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  const Expanded(child: Text('Budget remaining')),
                  Text(
                    'R${(budget - total).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: total > budget ? Colors.red : green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: basket.isEmpty ? null : () => setState(basket.clear),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear basket'),
        ),
        _notice(
          'Before checkout',
          'This is an estimate based on sample listings. Local prices, delivery and transport are not included.',
        ),
      ],
    );
  }

  Widget morePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Your CatchAChow',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        _featureCard(
          Icons.workspace_premium,
          'Free & Premium',
          'Free core budgeting; premium tools can be enabled after payment integration.',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionPage()),
          ),
        ),
        _featureCard(
          Icons.soup_kitchen,
          'Budget-to-meal planner',
          'Build a meal plan based on your budget and household size.',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MealPlanBuilderPage()),
          ),
        ),
        _featureCard(
          Icons.restaurant,
          'Cheat day planner',
          'Track a restaurant allowance inside or separately from your food budget.',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CheatDayPage()),
          ),
        ),
        _featureCard(
          Icons.cake,
          'Birthday specials',
          'Check offers directly with each business; offers are not live-verified.',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OffersPage(
                title: 'Birthday specials',
                birthday: true,
              ),
            ),
          ),
        ),
        _featureCard(
          Icons.local_offer,
          'Black Friday deals',
          'Compare advertised deals with normal prices and check offer terms.',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OffersPage(
                title: 'Black Friday deals',
                birthday: false,
              ),
            ),
          ),
        ),
        _featureCard(
          Icons.settings,
          'App settings',
          'Change the app appearance.',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AppSettingsPage()),
          ),
        ),
        _featureCard(
          Icons.logout,
          'Sign out',
          'Sign out of your configured Supabase account.',
          () async {
            if (supabaseReady) {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                  (_) => false,
                );
              }
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Demo mode: no account is signed in.')),
              );
            }
          },
        ),
        _notice(
          'Subscription status',
          'Payment processing is not connected. Selecting a plan does not take payment or grant paid access.',
        ),
      ],
    );
  }

  Widget _featureCard(
    IconData icon,
    String title,
    String body,
    VoidCallback action,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: green, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(body),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: action,
                      child: const Text('Open'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productTile(Product product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _card(
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                product.category == 'Protein'
                    ? Icons.lunch_dining
                    : product.category == 'Vegetable'
                        ? Icons.eco
                        : Icons.grain,
                color: green,
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text('${product.retailer} · ${product.size}'),
                  Text(
                    'Listed ${product.checked}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: green,
                  ),
                ),
                const SizedBox(height: 5),
                FilledButton(
                  onPressed: () {
                    add(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to basket'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEDE6)),
      ),
      child: child,
    );
  }

  Widget _notice(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2D9),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF8C5B16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    height: 1.4,
                    fontSize: 12,
                    color: Color(0xFF5F523B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool darkMode = catchThemeMode.value == ThemeMode.dark;

  Future<void> _setDarkMode(bool value) async {
    setState(() => darkMode = value);
    catchThemeMode.value = value ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('catchachow_dark_mode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: SwitchListTile(
              value: darkMode,
              onChanged: _setDarkMode,
              secondary: Icon(
                darkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Dark mode'),
              subtitle:
                  const Text('Save your appearance preference on this device.'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.flag_outlined),
              title: Text('Proudly South African'),
              subtitle: Text('Meal ideas focus on familiar local ingredients.'),
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selected = 'monthly';
  bool demoSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Choose your plan',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
              'Core budgeting remains free. Premium payment is not connected.'),
          const SizedBox(height: 16),
          _planCard('Free', 'R0',
              'Budget calculator\nBasic meal ideas\nShopping list', 'free'),
          _planCard(
              'Premium Monthly',
              'R50 / month',
              'Expanded meal plans\nSaved weekly plans\nAdvanced household planning',
              'monthly'),
          _planCard('Premium Yearly', 'R100 / year',
              'All monthly premium features\nOne yearly renewal', 'yearly'),
          if (demoSelected)
            const Text(
              'Demo selection only. No payment was taken and no premium access was granted.',
              style: TextStyle(
                  color: Colors.deepOrange, fontWeight: FontWeight.w700),
            ),
          FilledButton(
            onPressed: () => setState(() => demoSelected = true),
            child: Text(selected == 'free'
                ? 'Continue with Free'
                : 'Continue with $selected'),
          ),
        ],
      ),
    );
  }

  Widget _planCard(String title, String price, String features, String value) {
    final active = selected == value;
    return Card(
      color: active ? butterYellow : null,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(features),
        trailing: Text(
          price,
          style: const TextStyle(color: green, fontWeight: FontWeight.w900),
        ),
        onTap: () => setState(() {
          selected = value;
          demoSelected = false;
        }),
      ),
    );
  }
}

class CheatDayPage extends StatefulWidget {
  const CheatDayPage({super.key});

  @override
  State<CheatDayPage> createState() => _CheatDayPageState();
}

class _CheatDayPageState extends State<CheatDayPage> {
  final _budget = TextEditingController(text: '250');
  final _restaurant = TextEditingController(text: '150');
  bool includeInTotal = true;

  @override
  void dispose() {
    _budget.dispose();
    _restaurant.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetValue = double.tryParse(_budget.text) ?? 0;
    final restaurantValue = double.tryParse(_restaurant.text) ?? 0;
    final remaining = budgetValue - (includeInTotal ? restaurantValue : 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Cheat day planner')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Enjoy a meal out without losing track',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track a restaurant meal inside your food budget or separately.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _budget,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Available food budget (R)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _restaurant,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Restaurant allowance (R)',
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            value: includeInTotal,
            onChanged: (value) => setState(() => includeInTotal = value),
            title: const Text('Count restaurant meal in this budget'),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Remaining: R${remaining.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: remaining < 0 ? Colors.red : green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OffersPage extends StatelessWidget {
  final String title;
  final bool birthday;

  const OffersPage({
    super.key,
    required this.title,
    required this.birthday,
  });

  @override
  Widget build(BuildContext context) {
    final offers = birthday
        ? [
            'Spur — check current birthday-club terms',
            'RocoMamas — check current loyalty terms',
            'Krispy Kreme — check local store promotions',
            'Local cafés — ask about birthday rewards',
          ]
        : [
            'Checkers — verify offers in the official app/site',
            'Pick n Pay — verify offers in the official app/site',
            'Makro — verify online promotions and dates',
            'Game — compare the normal and advertised prices',
            'Woolworths Food — check product-specific promotions',
          ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            birthday ? 'Birthday rewards' : 'Black Friday watchlist',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            'These are suggestions to check, not verified live offers. Confirm eligibility and terms directly with each business.',
          ),
          const SizedBox(height: 14),
          ...offers.map(
            (offer) => Card(
              child: ListTile(
                leading: const Icon(Icons.local_offer_outlined, color: green),
                title: Text(offer),
                subtitle: const Text('Confirm availability and terms.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
