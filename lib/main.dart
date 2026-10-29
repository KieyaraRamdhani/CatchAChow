import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'planning_tools.dart';
import 'dart:convert';

String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
String get apiBaseUrl =>
    dotenv.env['CATCHACHOW_API_URL'] ?? 'http://10.0.2.2:8000';
bool get supabaseReady => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();
  catchThemeMode.value = prefs.getBool('catchachow_dark_mode') == true
      ? ThemeMode.dark
      : ThemeMode.light;
  if (supabaseReady) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
  runApp(const CatchAChowApp());
}

const ink = Color(0xFF24130D);
const green = Color(0xFFD20E22);
const mint = Color(0xFFFFE8A3);
const cream = Color(0xFFFFF9EB);
const orange = Color(0xFFFFC928);
const butterYellow = Color(0xFFFFF0A6);
final ValueNotifier<ThemeMode> catchThemeMode =
    ValueNotifier<ThemeMode>(ThemeMode.light);

class CatchSplashScreen extends StatefulWidget {
  const CatchSplashScreen({super.key});
  @override
  State<CatchSplashScreen> createState() => _CatchSplashScreenState();
}

class _CatchSplashScreenState extends State<CatchSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted)
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthGate()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: const Color(0xFFFFC928),
      body: SafeArea(
          child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _SunrisePainter())),
        Center(
            child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                              color: const Color(0xFFD20E22),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x55A30B19),
                                    blurRadius: 18,
                                    offset: Offset(0, 8))
                              ]),
                          child: Image.asset(
                              'assets/images/catchachow_logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.soup_kitchen_rounded,
                                      color: Colors.white, size: 62))),
                      const SizedBox(height: 22),
                      const Text('CatchAChow',
                          style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD20E22),
                              letterSpacing: -1.3)),
                      const SizedBox(height: 8),
                      const Text('Good food. Better days.',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF24130D))),
                      const SizedBox(height: 34),
                      const SizedBox(
                          width: 34,
                          height: 34,
                          child: CircularProgressIndicator(
                              strokeWidth: 4, color: Color(0xFFD20E22))),
                      const SizedBox(height: 12),
                      const Text('Getting your chow ready…',
                          style: TextStyle(
                              color: Color(0xFF6B2B18),
                              fontWeight: FontWeight.w600))
                    ])))
      ])));
}

class _SunrisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFFFE57A);
    canvas.drawCircle(
        Offset(size.width * .5, size.height * .73), size.width * .56, p);
    final ridge = Path()
      ..moveTo(0, size.height * .77)
      ..lineTo(size.width * .24, size.height * .65)
      ..lineTo(size.width * .43, size.height * .75)
      ..lineTo(size.width * .67, size.height * .59)
      ..lineTo(size.width, size.height * .73)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(ridge, Paint()..color = const Color(0xFFFFEAA8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Product {
  final String id, name, retailer, category, size, checked, note;
  final double price;
  const Product(this.id, this.name, this.retailer, this.category, this.size,
      this.price, this.checked, this.note);
}

const products = <Product>[
  Product(
      'P001',
      'Iwisa No. 1 Super Maize Meal',
      'Checkers',
      'Staple',
      '2.5 kg',
      25.49,
      '20 Oct 2026',
      'Online listing; branch stock and in-store price not confirmed.'),
  Product(
      'P002',
      'Golden Delight Parboiled Rice',
      'Checkers',
      'Staple',
      '2 kg',
      29.99,
      '23 Oct 2026',
      'Online listing; branch stock and in-store price not confirmed.'),
  Product(
      'P003',
      'Koo Baked Beans in Tomato Sauce',
      'Makro',
      'Protein',
      '400 g',
      16.95,
      '25 Oct 2026',
      'Listing does not confirm availability at a specific branch.'),
  Product('P004', 'Potatoes', 'Shoprite', 'Vegetable', '2 kg', 29.99,
      '23 Oct 2026', 'Online listing; package or offer may vary by location.'),
  Product(
      'P005',
      'Onions',
      'Checkers',
      'Vegetable',
      '1 kg',
      19.98,
      '20 Oct 2026',
      'Online listing; branch stock and in-store price not confirmed.'),
  Product('P006', 'Eggs', 'Shoprite', 'Protein', '18 pack', 49.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P007', 'Long-life milk', 'Pick n Pay', 'Dairy', '1 L', 16.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P008', 'Brown bread', 'Checkers', 'Bakery', '700 g', 17.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P009', 'Chicken portions', 'Boxer', 'Protein', '1 kg', 64.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P010', 'Dry sugar beans', 'Shoprite', 'Protein', '500 g', 24.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P011', 'Tomatoes', 'Food Lover’s Market', 'Vegetable', '1 kg', 24.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P012', 'Carrots', 'SPAR', 'Vegetable', '1 kg', 15.99, '25 Oct 2026',
      'Illustrative sample price; verify at retailer.'),
  Product('P013', 'Cabbage', 'Shoprite', 'Vegetable', '1 head', 18.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P014', 'Peanut butter', 'Checkers', 'Pantry', '400 g', 34.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P015', 'Tinned pilchards', 'Boxer', 'Protein', '400 g', 24.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P016', 'Pasta', 'Makro', 'Staple', '500 g', 14.99, '25 Oct 2026',
      'Illustrative sample price; verify at retailer.'),
  Product('P017', 'Oats', 'Woolworths Food', 'Breakfast', '1 kg', 39.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P018', 'Bananas', 'Food Lover’s Market', 'Fruit', '1 kg', 22.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P019', 'Frozen mixed vegetables', 'Checkers', 'Vegetable', '1 kg',
      34.99, '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
  Product('P020', 'Boerewors', 'Bluff Meat Supply', 'Protein', '500 g', 49.99,
      '25 Oct 2026', 'Illustrative sample price; verify at retailer.'),
];

class CatchAChowApp extends StatelessWidget {
  const CatchAChowApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
        valueListenable: catchThemeMode,
        builder: (context, mode, _) => MaterialApp(
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
                  surface: cream),
              appBarTheme: const AppBarTheme(
                  backgroundColor: cream, foregroundColor: ink, elevation: 0),
              fontFamily: 'Roboto'),
          darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                  seedColor: green,
                  brightness: Brightness.dark,
                  primary: const Color(0xFFFFD45A),
                  secondary: orange),
              appBarTheme: const AppBarTheme(elevation: 0),
              fontFamily: 'Roboto'),
          home: const CatchSplashScreen(),
        ),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    if (!supabaseReady) return const AuthScreen();
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (Supabase.instance.client.auth.currentSession != null)
          return const BasketHome();
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
  final _form = GlobalKey<FormState>();
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

  bool get _passwordValid {
    final v = _password.text;
    return v.length > 6 && RegExp(r'[^A-Za-z0-9]').hasMatch(v);
  }

  bool _validateInputs() {
    if (_signup &&
        (_name.text.trim().isEmpty ||
            _surname.text.trim().isEmpty ||
            _phone.text.trim().length < 7 ||
            _dob == null)) {
      setState(() => _message =
          'Complete your name, surname, date of birth and phone number.');
      return false;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim())) {
      setState(() => _message = 'Enter a valid email address.');
      return false;
    }
    if (_password.text.length <= 6 ||
        !RegExp(r'[^A-Za-z0-9]').hasMatch(_password.text)) {
      setState(() => _message =
          'Password must be longer than 6 characters and contain a special character.');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!supabaseReady) {
      setState(() => _message =
          'Authentication is not configured yet. Add your Supabase URL and anon key using --dart-define. You can use Demo mode to explore the prototype.');
      return;
    }
    if (_needsCode) {
      await _verify();
      return;
    }
    if (!_validateInputs()) return;
    if (_signup && _dob == null) {
      setState(() => _message = 'Please choose your date of birth.');
      return;
    }
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
            'date_of_birth': _dob!.toIso8601String().substring(0, 10)
          },
        );
        setState(() {
          _needsCode = true;
          _message =
              'Check your email for the confirmation code. Enter it below to verify your account.';
        });
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
            email: _email.text.trim(), password: _password.text);
        if (mounted)
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BasketHome()));
      }
    } on AuthException catch (e) {
      setState(() => _message = e.message);
    } catch (e) {
      setState(() => _message =
          'Could not complete authentication. Check your connection and Supabase setup.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _message = '';
    });
    try {
      await Supabase.instance.client.auth.verifyOTP(
          email: _email.text.trim(),
          token: _code.text.trim(),
          type: OtpType.signup);
      if (mounted)
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BasketHome()));
    } on AuthException catch (e) {
      setState(() => _message = e.message);
    } catch (_) {
      setState(() =>
          _message = 'Verification failed. Check the code and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none));
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: cream,
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
                                    borderRadius: BorderRadius.circular(23)),
                                child: Image.asset(
                                    'assets/images/catchachow_logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stack) =>
                                        const Icon(Icons.soup_kitchen_rounded,
                                            size: 44, color: Colors.white))),
                            const SizedBox(height: 14),
                            const Text('CatchAChow',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: green)),
                            const SizedBox(height: 5),
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
                                    color: ink)),
                            const SizedBox(height: 20),
                            if (!_needsCode) ...[
                              if (_signup) ...[
                                TextFormField(
                                    controller: _name,
                                    decoration:
                                        _dec('Name', Icons.person_outline),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Enter your name'
                                            : null),
                                const SizedBox(height: 10),
                                TextFormField(
                                    controller: _surname,
                                    decoration:
                                        _dec('Surname', Icons.person_outline),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Enter your surname'
                                            : null),
                                const SizedBox(height: 10),
                                InkWell(
                                    onTap: () async {
                                      final d = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime(2005),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now());
                                      if (d != null) setState(() => _dob = d);
                                    },
                                    child: InputDecorator(
                                        decoration: _dec('Date of birth',
                                            Icons.cake_outlined),
                                        child: Text(_dob == null
                                            ? 'Choose date'
                                            : '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}'))),
                                const SizedBox(height: 10),
                              ],
                              TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _dec(
                                      'Email address', Icons.email_outlined),
                                  validator: (v) => v != null &&
                                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                              .hasMatch(v.trim())
                                      ? null
                                      : 'Enter a valid email'),
                              const SizedBox(height: 10),
                              if (_signup) ...[
                                TextFormField(
                                    controller: _phone,
                                    keyboardType: TextInputType.phone,
                                    decoration: _dec(
                                        'Phone number', Icons.phone_outlined),
                                    validator: (v) =>
                                        v != null && v.trim().length >= 7
                                            ? null
                                            : 'Enter a valid phone number'),
                                const SizedBox(height: 10)
                              ],
                              TextFormField(
                                  controller: _password,
                                  obscureText: true,
                                  onChanged: (_) => setState(() {}),
                                  decoration:
                                      _dec('Password', Icons.lock_outline),
                                  validator: (v) {
                                    if (v == null || v.length <= 6)
                                      return 'Use more than 6 characters';
                                    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v))
                                      return 'Include at least one special character';
                                    return null;
                                  }),
                              if (_signup)
                                const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text(
                                        'Password must be at least 7 characters and contain a special character.',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54))),
                            ] else
                              TextField(
                                  controller: _code,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: _dec('Email confirmation code',
                                      Icons.verified_user_outlined)),
                            const SizedBox(height: 14),
                            if (_message.isNotEmpty)
                              Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0D0),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text(_message,
                                      style: const TextStyle(fontSize: 13))),
                            const SizedBox(height: 12),
                            FilledButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        if (_needsCode) {
                                          _verify();
                                        } else {
                                          _submit();
                                        }
                                      },
                                style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.all(15)),
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : Text(_needsCode
                                        ? 'Confirm email'
                                        : _signup
                                            ? 'Create account'
                                            : 'Log in')),
                            if (!_needsCode)
                              TextButton(
                                  onPressed: () => setState(() {
                                        _signup = !_signup;
                                        _message = '';
                                      }),
                                  child: Text(_signup
                                      ? 'Already have an account? Log in'
                                      : 'New here? Create an account')),
                            if (_needsCode)
                              TextButton(
                                  onPressed: () => setState(() {
                                        _needsCode = false;
                                        _signup = true;
                                      }),
                                  child: const Text('Back to signup')),
                            const SizedBox(height: 6),
                            OutlinedButton.icon(
                                onPressed: () => Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                        builder: (_) => const BasketHome())),
                                icon: const Icon(Icons.explore_outlined),
                                label: const Text(
                                    'Explore demo without an account')),
                            if (!supabaseReady)
                              const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Text(
                                      'Setup required for real accounts: configure Supabase URL/key and enable email OTP confirmation. Demo mode does not create an account.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54))),
                          ]))))));
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

  Future<void> loadLiveProducts() async {
    setState(() {
      loadingLiveProducts = true;
      liveProductMessage = 'Checking configured retailer feeds…';
    });
    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/api/products'))
          .timeout(const Duration(seconds: 18));
      if (response.statusCode != 200) throw Exception('feed error');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (data['products'] as List? ?? []).whereType<Map>().toList();
      final converted = <Product>[];
      for (var i = 0; i < items.length; i++) {
        final m = Map<String, dynamic>.from(items[i]);
        final price = (m['price'] as num?)?.toDouble();
        if (price == null) continue;
        converted.add(Product(
            'LIVE_$i',
            (m['name'] ?? m['title'] ?? 'Product').toString(),
            (m['retailer'] ?? 'Retailer').toString(),
            (m['category'] ?? 'Grocery').toString(),
            (m['size'] ?? 'Size not supplied').toString(),
            price,
            (m['checked_at'] ?? 'Live feed').toString(),
            (m['product_url'] ?? '').toString()));
      }
      if (mounted)
        setState(() {
          liveProducts = converted;
          liveProductMessage = converted.isEmpty
              ? 'No live products returned. No approved retailer feeds may be configured yet.'
              : 'Loaded ${converted.length} products from configured feeds. Verify branch availability and checkout price.';
        });
    } catch (_) {
      if (mounted)
        setState(() => liveProductMessage =
            'Could not reach the product API. Check backend URL and configured feed permissions. Sample prices remain separate from live data.');
    } finally {
      if (mounted) setState(() => loadingLiveProducts = false);
    }
  }

  List<Product> get allProducts => [...products, ...liveProducts];
  Product? _findProduct(String id) {
    for (final p in allProducts) {
      if (p.id == id) return p;
    }
    return null;
  }

  double get total => basket.entries.fold(
      0.0,
      (sum, entry) =>
          sum + ((_findProduct(entry.key)?.price ?? 0) * entry.value));
  int get count => basket.values.fold(0, (a, b) => a + b);
  void add(Product p) => setState(() => basket[p.id] = (basket[p.id] ?? 0) + 1);
  void remove(Product p) => setState(() {
        final n = basket[p.id] ?? 0;
        if (n <= 1) {
          basket.remove(p.id);
        } else {
          basket[p.id] = n - 1;
        }
      });

  @override
  Widget build(BuildContext context) {
    final pages = [
      homePage(),
      shopPage(),
      mealsPage(),
      aiPage(),
      basketPage(),
      morePage()
    ];
    return Scaffold(
      drawer: Drawer(
          child: SafeArea(
              child: ListView(padding: EdgeInsets.zero, children: [
        Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            color: butterYellow,
            child: Row(children: [
              Image.asset('assets/images/catchachow_logo.png',
                  width: 56, height: 56),
              const SizedBox(width: 12),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('CatchAChow',
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: ink)),
                    Text('Good food. Better days. 🇿🇦',
                        style: TextStyle(color: ink))
                  ]))
            ])),
        _drawerItem(Icons.home_outlined, 'Home', 0),
        _drawerItem(Icons.storefront_outlined, 'Grocery prices', 1),
        _drawerItem(Icons.restaurant_menu_outlined, 'South African meals', 2),
        _drawerItem(Icons.smart_toy_outlined, 'AI Chow', 3),
        _drawerItem(Icons.shopping_cart_outlined, 'My basket', 4),
        _drawerItem(Icons.grid_view_rounded, 'More features', 5),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('App settings'),
            subtitle: const Text('Theme and display'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AppSettingsPage()));
            }),
        ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About CatchAChow'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                  context: context,
                  applicationName: 'CatchAChow',
                  applicationVersion: 'Prototype 1.2');
            }),
      ]))),
      appBar: AppBar(
        leading: Builder(
            builder: (context) => IconButton(
                tooltip: 'Open navigation',
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(context).openDrawer())),
        title: Row(children: [
          Image.asset('assets/images/catchachow_logo.png',
              width: 34, height: 34),
          const SizedBox(width: 9),
          const Text('CatchAChow',
              style:
                  TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.5)),
          const SizedBox(width: 7),
          const Text('🇿🇦', style: TextStyle(fontSize: 17))
        ]),
        actions: [
          IconButton(
              tooltip: 'Settings',
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AppSettingsPage())),
              icon: const Icon(Icons.settings_outlined))
        ],
      ),
      body:
          SafeArea(child: Scrollbar(thumbVisibility: true, child: pages[tab])),
      bottomNavigationBar: NavigationBar(
        height: 66,
        selectedIndex: tab > 3 ? 0 : tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        backgroundColor: Colors.white,
        indicatorColor: butterYellow,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Prices'),
          NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu_rounded),
              label: 'Meals'),
          NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy_rounded),
              label: 'AI Chow'),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int destination) => ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: tab == destination,
      selectedTileColor: butterYellow.withOpacity(.65),
      onTap: () {
        setState(() => tab = destination);
        Navigator.pop(context);
      });

  final TextEditingController _aiController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  @override
  void dispose() {
    _aiController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  String _lastAiPrompt = '';
  final List<Map<String, String>> _chat = [
    {
      'role': 'bot',
      'text':
          'Sawubona! I only help with meal planning and shopping lists. Tell me what you want to eat, your budget, how many people, and how many days.'
    }
  ];

  Widget aiPage() => ListView(padding: const EdgeInsets.all(18), children: [
        Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFD42A), Color(0xFFFFF0B0)]),
                borderRadius: BorderRadius.circular(24)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.smart_toy_rounded,
                      size: 38, color: Color(0xFFD20E22)),
                  SizedBox(height: 8),
                  Text('AI Chow Planner',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF24130D))),
                  SizedBox(height: 6),
                  Text(
                      'Meals in your budget. Ingredients for your people. A shopping list that makes sense.',
                      style: TextStyle(height: 1.4))
                ])),
        const SizedBox(height: 12),
        _notice('Food-only assistant',
            'This chat only accepts meal requests and questions about food budgets, recipes, ingredients, quantities, and shopping lists. Other topics are not supported.'),
        const SizedBox(height: 12),
        ..._chat.map((m) => Align(
            alignment: m['role'] == 'user'
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                constraints: const BoxConstraints(maxWidth: 330),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: m['role'] == 'user'
                        ? const Color(0xFFD20E22)
                        : butterYellow.withOpacity(.55),
                    borderRadius: BorderRadius.circular(18)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['text']!,
                          style: TextStyle(
                              color: m['role'] == 'user' ? Colors.white : ink,
                              height: 1.4)),
                      if (m['retry'] == 'yes')
                        Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                                onPressed: _retryLastMealRequest,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try again')))
                    ])))),
        const SizedBox(height: 8),
        _card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              'Try: “Plan 5 days of affordable South African meals for 3 people under R250.”',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 10),
          TextField(
              controller: _calorieController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Daily calorie target (optional)',
                  helperText:
                      'Use a target from a qualified source; AI estimates are not medical advice.',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFFFF9EB))),
          const SizedBox(height: 10),
          TextField(
              controller: _aiController,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Ask about meals, food prep or your budget…',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFFFF9EB))),
          const SizedBox(height: 10),
          SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                  onPressed: _sendMealRequest,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Build my meal plan')))
        ])),
      ]);

  Future<void> _sendMealRequest() async {
    final text = _aiController.text.trim();
    if (text.isEmpty) return;
    _lastAiPrompt = text;
    final calorieTarget = int.tryParse(_calorieController.text.trim());
    _aiController.clear();
    setState(() => _chat.add({'role': 'user', 'text': text}));
    final lower = text.toLowerCase();
    final foodWords = [
      'eat',
      'meal',
      'food',
      'recipe',
      'budget',
      'rand',
      'r ',
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
      'app',
      'catchachow'
    ];
    if (!foodWords.any(lower.contains)) {
      setState(() => _chat.add({
            'role': 'bot',
            'text':
                'I can only help with food, meal preparation, recipes, nutrition basics, grocery budgeting, restaurant meal planning and CatchAChow features.'
          }));
      return;
    }
    try {
      final response = await http
          .post(Uri.parse('$apiBaseUrl/api/chat'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'message': text,
                'budget_zar': budget,
                'people': people,
                'days': 7,
                'dietary_preferences': [],
                'daily_calorie_target': calorieTarget,
                'known_products': products
                    .map((p) => {
                          'name': p.name,
                          'retailer': p.retailer,
                          'size': p.size,
                          'sample_price_zar': p.price,
                          'price_is_live': false
                        })
                    .toList()
              }))
          .timeout(const Duration(seconds: 28));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (mounted)
          setState(() => _chat.add({
                'role': 'bot',
                'text':
                    (data['answer'] ?? 'I could not create a plan.').toString()
              }));
      } else {
        if (mounted)
          setState(() => _chat.add({
                'role': 'bot',
                'text':
                    'The AI could not complete this request. Check your connection or try a simpler food-related question. No live prices or calorie guarantees were invented.',
                'retry': 'yes'
              }));
      }
    } catch (_) {
      if (mounted)
        setState(() => _chat.add({
              'role': 'bot',
              'text':
                  'I could not reach the AI service. Check your connection and try again. The chatbot only answers food-related questions.',
              'retry': 'yes'
            }));
    }
  }

  void _retryLastMealRequest() {
    _aiController.text = _lastAiPrompt;
    _sendMealRequest();
  }

  Widget homePage() =>
      ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
        Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: ink, borderRadius: BorderRadius.circular(28)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(30)),
                  child: const Text(
                      '🇿🇦 SOUTH AFRICAN FLAVOUR. SMART SPENDING.',
                      style: TextStyle(
                          color: Color(0xFFBCE4C4),
                          fontSize: 10,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w800))),
              const SizedBox(height: 18),
              const Text('Good food.\nBetter days.',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.8)),
              const SizedBox(height: 10),
              Text(
                  'Plan kasi-inspired meals, stretch your budget, and shop smarter.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(.75),
                      height: 1.4,
                      fontSize: 14)),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: _stat(
                        'WEEKLY BUDGET', 'R${budget.toStringAsFixed(0)}')),
                Expanded(
                    child:
                        _stat('IN YOUR BASKET', 'R${total.toStringAsFixed(2)}'))
              ]),
              const SizedBox(height: 18),
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                      value: budget == 0
                          ? 0
                          : (total / budget).clamp(0, 1).toDouble(),
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      color:
                          total > budget ? const Color(0xFFFF8B72) : orange)),
              const SizedBox(height: 7),
              Text(
                  'R${(budget - total).toStringAsFixed(2)} ${total > budget ? 'over budget' : 'left to spend'}',
                  style: TextStyle(
                      color: total > budget
                          ? const Color(0xFFFFB6A8)
                          : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ])),
        const SizedBox(height: 14),
        ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(alignment: Alignment.bottomLeft, children: [
              Image.network(
                  'https://images.unsplash.com/photo-1683538007978-ec84fe958c27?auto=format&fit=crop&w=1200&q=80',
                  height: 155,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Image.asset(
                      'assets/images/south_african_meal.jpg',
                      height: 155,
                      width: double.infinity,
                      fit: BoxFit.cover)),
              Container(
                  height: 155,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(.72)
                      ]))),
              const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Kasi flavour. Student-friendly prices.',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18)))
            ])),
        const SizedBox(height: 22),
        _sectionTitle('Set up your plan', 'Keep your budget realistic.'),
        _card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
                child: Text('Weekly food budget',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
            Text('R${budget.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: green, fontSize: 18))
          ]),
          Slider(
              value: budget,
              min: 40,
              max: 1000,
              divisions: 96,
              onChanged: (v) => setState(() => budget = v),
              activeColor: green),
          Row(children: [
            const Expanded(
                child: Text('People eating',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            IconButton(
                onPressed: people > 1 ? () => setState(() => people--) : null,
                icon: const Icon(Icons.remove_circle_outline)),
            Text('$people',
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            IconButton(
                onPressed: people < 12 ? () => setState(() => people++) : null,
                icon: const Icon(Icons.add_circle_outline))
          ])
        ])),
        const SizedBox(height: 12),
        SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MealPlanBuilderPage())),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Build a budget-to-meal plan'),
                style: FilledButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.all(15)))),
        const SizedBox(height: 22),
        _sectionTitle(
            'Catch a chow, not a bill', 'Browse sample listed prices.'),
        ...products.take(3).map((p) => productTile(p)),
        const SizedBox(height: 12),
        _notice('Price transparency',
            'These are dated online listing examples, not live prices. Check your local branch and the retailer website before purchasing.'),
      ]);

  Widget shopPage() => ListView(padding: const EdgeInsets.all(18), children: [
        const Text('Grocery price check',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 6),
        const Text('Compare package sizes, prices and retailers.',
            style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 12),
        FilledButton.icon(
            onPressed: loadingLiveProducts ? null : loadLiveProducts,
            icon: loadingLiveProducts
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            label: const Text('Refresh connected live prices')),
        const SizedBox(height: 10),
        _notice(
            liveProducts.isEmpty ? 'Sample listings' : 'Connected feed results',
            liveProductMessage),
        const SizedBox(height: 12),
        if (liveProducts.isNotEmpty) ...liveProducts.map((p) => productTile(p)),
        if (liveProducts.isEmpty) ...products.map((p) => productTile(p)),
        const SizedBox(height: 8),
        _notice('Retailer coverage',
            'Pick n Pay, Checkers, SPAR, Makro, Boxer, Game, Shoprite, Woolworths Food, Food Lover’s Market and Bluff Meat Supply are supported as backend feed slots only. They are not live until an authorised feed is configured. Confirm whether “Take n Pay” refers to Pick n Pay.'),
      ]);

  Widget mealsPage() => ListView(padding: const EdgeInsets.all(18), children: [
        Row(children: [
          const Expanded(
              child: Text('Kasi-style meal ideas',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800, color: ink))),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: butterYellow, borderRadius: BorderRadius.circular(20)),
              child: const Text('🇿🇦 South African',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: ink, fontSize: 12)))
        ]),
        const SizedBox(height: 6),
        const Text(
            'Simple stove-friendly ideas using products in the sample list.',
            style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        _meal(
            '🍚',
            'Rice with baked beans',
            'Rice + 1 can baked beans',
            'Cook rice according to its pack instructions. Heat the beans separately and serve together.',
            'Uses sample prices for rice and baked beans.'),
        _meal(
            '🥔',
            'Boiled potatoes',
            'Potatoes + water',
            'Wash and cut potatoes into even pieces. Boil until tender. Add a suitable protein or vegetables when available.',
            'A side dish, not a complete meal by itself.'),
        _meal(
            '🥣',
            'Soft maize meal porridge (pap)',
            'Maize meal + water',
            'Bring water to a boil. Gradually stir in maize meal and cook following the package instructions.',
            'A staple, not a nutritionally complete meal by itself.'),
        _meal(
            '🍲',
            'Samp and beans',
            'Samp, sugar beans, onion, stock or seasoning',
            'Soak beans and samp as directed, then simmer until tender. Add onion and seasoning; keep enough water in the pot.',
            'Classic filling meal; cooking time depends on dried ingredients.'),
        _meal(
            '🍛',
            'Chicken stew with pap',
            'Chicken portions, onion, tomato, pap',
            'Brown chicken and onion, add chopped tomato and water, then simmer until chicken is fully cooked. Serve with pap.',
            'Cook chicken thoroughly; add vegetables when available.'),
        _meal(
            '🥘',
            'Chakalaka and pap',
            'Chakalaka, maize meal, optional beans',
            'Prepare pap following the packet. Warm chakalaka and add beans for extra protein if available.',
            'Check salt content on prepared chakalaka.'),
        _meal(
            '🍝',
            'Tomato mince pasta',
            'Pasta, tomatoes, onion, optional mince or lentils',
            'Boil pasta. Simmer tomatoes and onion into a sauce; add cooked mince or lentils if available.',
            'Use lentils for a lower-cost plant protein option.'),
        _meal(
            '🥚',
            'Egg fried rice',
            'Cooked rice, eggs, mixed vegetables, a little oil',
            'Scramble eggs, add vegetables and cooked rice, then stir-fry until hot throughout.',
            'Use refrigerated leftover rice promptly and reheat thoroughly.'),
        _meal(
            '🌭',
            'Boerewors rolls',
            'Boerewors, rolls, tomato and onion relish',
            'Cook boerewors thoroughly. Serve in rolls with a quick tomato-onion relish.',
            'A treat meal; add a side salad if available.'),
        _meal(
            '🐟',
            'Pilchard tomato stew',
            'Tinned pilchards, tomatoes, onion, pap or rice',
            'Soften onion and tomato in a pan, fold in pilchards gently and heat through. Serve with pap or rice.',
            'Affordable source of protein; watch added salt.'),
        _meal(
            '🥔',
            'Potato and bean curry',
            'Potatoes, beans, onion, curry spices, tomato',
            'Simmer potato cubes, beans, onion and tomato with curry spices until potatoes are tender.',
            'Beans make this more filling and add protein.'),
        _meal(
            '🥬',
            'Cabbage and carrot stir-fry',
            'Cabbage, carrots, onion, rice or pap',
            'Slice vegetables thinly and stir-fry until tender-crisp. Serve with a staple and add egg or beans if possible.',
            'Add a protein source for a more balanced meal.'),
        _meal(
            '🥞',
            'Vetkoek with savoury mince',
            'Flour, yeast, mince or beans, onion',
            'Prepare and cook vetkoek using a trusted recipe. Fill with cooked savoury mince or seasoned beans.',
            'Deep-frying requires care; this is an occasional option.'),
        _meal(
            '🍗',
            'Oven-style chicken and vegetables',
            'Chicken portions, potatoes, carrots, seasoning',
            'Place chicken and chopped vegetables in a roasting dish and cook until chicken is fully done and vegetables are tender.',
            'Use an oven or covered pan depending on equipment.'),
        _meal(
            '🥣',
            'Umngqusho-inspired samp bowl',
            'Samp, beans, onion, leafy greens',
            'Cook samp and beans until soft. Stir through cooked greens and onion near the end.',
            'Traditional-inspired bowl; allow time for dried samp and beans.'),
        _meal(
            '🥪',
            'Atchar egg sandwich',
            'Bread, eggs, atchar, optional tomato',
            'Boil or scramble eggs, layer on bread and add a small amount of atchar for flavour.',
            'Quick no-fuss meal; check atchar spice and salt.'),
        _meal(
            '🍚',
            'Chicken and vegetable rice',
            'Rice, chicken, carrots, mixed vegetables',
            'Cook chicken until done, add vegetables and combine with cooked rice. Season to taste.',
            'Use measured portions to stretch chicken across servings.'),
        _meal(
            '🫘',
            'Sugar bean tomato curry',
            'Sugar beans, tomato, onion, curry spices, rice',
            'Cook soaked beans until tender. Simmer with tomato, onion and spices, then serve over rice.',
            'Canned beans can reduce cooking time.'),
        _meal(
            '🥗',
            'Chickpea and cabbage bowl',
            'Chickpeas, cabbage, tomato, bread or rice',
            'Rinse canned chickpeas, warm with tomato and spices, and serve with lightly cooked cabbage and a staple.',
            'A quick plant-based option; check canned-food sodium.'),
        _meal(
            '🍳',
            'Tomato and onion eggs',
            'Eggs, tomatoes, onion, bread or pap',
            'Cook onion and tomato until soft, add beaten eggs and stir until fully set. Serve with bread or pap.',
            'Simple breakfast, lunch or supper.'),
        const SizedBox(height: 12),
        _notice('South African flavour 🇿🇦',
            'These are meal ideas, not verified nutrition prescriptions. Costs and nutritional adequacy depend on portions, ingredients, and current local prices.'),
      ]);

  Widget basketPage() => ListView(padding: const EdgeInsets.all(18), children: [
        const Text('My chow basket',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 6),
        Text(
            '$count package${count == 1 ? '' : 's'} · Budget R${budget.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        if (basket.isEmpty)
          _card(
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Column(children: [
                    Icon(Icons.shopping_basket_outlined,
                        size: 44, color: green),
                    SizedBox(height: 12),
                    Text('Your basket is empty',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    SizedBox(height: 6),
                    Text('Add products from Compare to start planning.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54))
                  ])))
        else
          ...basket.entries.map((e) {
            final p = _findProduct(e.key);
            if (p == null) return const SizedBox.shrink();
            return _card(
                child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(p.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${p.retailer} · R${p.price.toStringAsFixed(2)} each',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12))
                  ])),
              IconButton(
                  onPressed: () => remove(p),
                  icon: const Icon(Icons.remove_circle_outline)),
              Text('${e.value}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              IconButton(
                  onPressed: () => add(p),
                  icon: const Icon(Icons.add_circle_outline)),
              Text('R${(p.price * e.value).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800))
            ]));
          }),
        const SizedBox(height: 10),
        _card(
            child: Column(children: [
          Row(children: [
            const Expanded(
                child: Text('Estimated basket total',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            Text('R${total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 22, color: green, fontWeight: FontWeight.w900))
          ]),
          const Divider(height: 22),
          Row(children: [
            const Expanded(child: Text('Budget remaining')),
            Text('R${(budget - total).toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: total > budget ? Colors.red : green))
          ]),
          if (total > budget)
            const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                    'Over budget. Remove a package or increase your budget.',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)))
        ])),
        const SizedBox(height: 12),
        OutlinedButton.icon(
            onPressed:
                basket.isEmpty ? null : () => setState(() => basket.clear()),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear basket')),
        const SizedBox(height: 8),
        _notice('Before checkout',
            'This is a cost estimate from sample online listings. It excludes transport, delivery, price changes and any products not added.'),
      ]);

  Widget morePage() => ListView(padding: const EdgeInsets.all(18), children: [
        const Text('Your CatchAChow',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w900, color: ink)),
        const SizedBox(height: 8),
        _featureCard(
            Icons.workspace_premium,
            'Free & Premium',
            'Free: core budget planner and sample meal ideas. Premium: expanded meal plans, saved weekly plans and advanced household tools. Prices requested: R50/month or R100/year.',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SubscriptionPage()))),
        _featureCard(
            Icons.soup_kitchen,
            'Budget-to-meal planner & pantry',
            'Plan meals by budget, days, household size, vegetarian preference and cooking equipment. Save pantry ingredients on this device and generate a consolidated shopping list.',
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MealPlanBuilderPage()))),
        _featureCard(
            Icons.restaurant,
            'Cheat days & restaurant meals',
            'Plan a restaurant meal as a separate budget line, or set a restaurant-day limit. The app should not silently hide it from your total.',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CheatDayPage()))),
        _featureCard(
            Icons.cake,
            'Birthday specials',
            'Browse restaurant offers, but confirm eligibility and terms directly with each restaurant. Offers are not verified live in this prototype.',
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const OffersPage(
                        title: 'Birthday specials',
                        icon: Icons.cake,
                        birthday: true)))),
        _featureCard(
            Icons.local_offer,
            'Black Friday deals',
            'Seasonal deal discovery. Offers must be checked against retailer pages; no live Black Friday feeds are connected yet.',
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const OffersPage(
                        title: 'Black Friday deals',
                        icon: Icons.local_offer,
                        birthday: false)))),
        _featureCard(
            Icons.settings,
            'App settings',
            'Change between light and dark mode and adjust the app display.',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AppSettingsPage()))),
        _featureCard(Icons.person, 'Account & sign out',
            'Manage your account through Supabase once configured.', () async {
          if (supabaseReady) {
            await Supabase.instance.client.auth.signOut();
            if (mounted)
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                  (_) => false);
          } else {
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Demo mode: no account is signed in.')));
          }
        }),
        const SizedBox(height: 8),
        _notice('Subscription status',
            'Payment processing is not connected yet. The plan selector below is a prototype UI; paid access must only be activated after verified payment and server-side subscription validation.'),
      ]);

  Widget _featureCard(
          IconData icon, String title, String body, VoidCallback action) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _card(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: green, size: 28),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(body, style: const TextStyle(fontSize: 12, height: 1.4)),
                  const SizedBox(height: 8),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                          onPressed: action, child: const Text('Open')))
                ]))
          ])));

  String _productImage(Product p) {
    final n = p.name.toLowerCase();
    if (n.contains('egg'))
      return 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?auto=format&fit=crop&w=300&q=70';
    if (n.contains('rice'))
      return 'https://images.unsplash.com/photo-1516684732162-798a0062be99?auto=format&fit=crop&w=300&q=70';
    if (n.contains('potato'))
      return 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=300&q=70';
    if (n.contains('tomato') ||
        n.contains('carrot') ||
        n.contains('cabbage') ||
        n.contains('onion') ||
        n.contains('banana') ||
        n.contains('vegetable'))
      return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=300&q=70';
    if (n.contains('chicken') ||
        n.contains('boerewors') ||
        n.contains('pilchard'))
      return 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=300&q=70';
    if (n.contains('bread') || n.contains('roll'))
      return 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=300&q=70';
    return 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=300&q=70';
  }

  Widget productTile(Product p) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _card(
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.network(_productImage(p),
                width: 62,
                height: 62,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                    width: 62,
                    height: 62,
                    color: mint,
                    child: Icon(
                        p.category == 'Protein'
                            ? Icons.lunch_dining
                            : p.category == 'Vegetable'
                                ? Icons.eco
                                : Icons.grain,
                        color: green,
                        size: 30)))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text('${p.retailer} · ${p.size}',
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 4),
          Text('Listed ${p.checked}',
              style: const TextStyle(color: Colors.black45, fontSize: 10))
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('R${p.price.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: green, fontSize: 16)),
          const SizedBox(height: 6),
          FilledButton(
              onPressed: () {
                add(p);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${p.name} added to basket'),
                    duration: const Duration(seconds: 1)));
              },
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 34)),
              child: const Text('Add'))
        ])
      ])));

  Widget _meal(String emoji, String title, String ingredients, String steps,
          String note) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(_mealImage(title),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Image.asset(
                            'assets/images/south_african_meal.jpg',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover))),
                const SizedBox(height: 12),
                Row(children: [
                  Text(emoji, style: const TextStyle(fontSize: 27)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)))
                ]),
                const SizedBox(height: 9),
                Text(ingredients,
                    style: const TextStyle(
                        color: green, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(steps, style: const TextStyle(height: 1.45)),
                const SizedBox(height: 8),
                Text(note,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic))
              ])));
  String _mealImage(String title) {
    final t = title.toLowerCase();
    if (t.contains('pasta') || t.contains('vetkoek'))
      return 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?auto=format&fit=crop&w=900&q=75';
    if (t.contains('chicken') || t.contains('boerewors'))
      return 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=900&q=75';
    if (t.contains('egg') || t.contains('sandwich'))
      return 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=900&q=75';
    if (t.contains('cabbage') ||
        t.contains('chickpea') ||
        t.contains('vegetable'))
      return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=900&q=75';
    if (t.contains('rice'))
      return 'https://images.unsplash.com/photo-1516684732162-798a0062be99?auto=format&fit=crop&w=900&q=75';
    if (t.contains('potato'))
      return 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=900&q=75';
    return 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=75';
  }

  Widget _stat(String label, String value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 9,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800))
      ]);
  Widget _sectionTitle(String title, String subtitle) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ink,
                letterSpacing: -.3)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 13))
      ]));
  Widget _card({required Widget child}) => Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFECEDE6))),
      child: child);
  Widget _notice(String title, String body) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF2D9),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFF4DDAA))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded, color: Color(0xFF8C5B16)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 4),
          Text(body,
              style: const TextStyle(
                  height: 1.4, fontSize: 12, color: Color(0xFF5F523B)))
        ]))
      ]));
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
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('App settings')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: butterYellow, borderRadius: BorderRadius.circular(22)),
            child: Row(children: [
              Image.asset('assets/images/catchachow_logo.png',
                  width: 62, height: 62),
              const SizedBox(width: 12),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Make it yours 🇿🇦',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: ink)),
                    Text('Choose the look that feels right.',
                        style: TextStyle(color: ink))
                  ]))
            ])),
        const SizedBox(height: 16),
        Card(
            child: SwitchListTile(
                value: darkMode,
                onChanged: _setDarkMode,
                secondary: Icon(darkMode ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Dark mode'),
                subtitle: const Text(
                    'Switch between light and dark appearance. Your choice is saved on this device.'))),
        const SizedBox(height: 12),
        const Card(
            child: ListTile(
                leading: Icon(Icons.contrast),
                title: Text('Butter-yellow accents'),
                subtitle: Text(
                    'CatchAChow uses warm yellow, red and cream for its South African-inspired identity.'))),
        const SizedBox(height: 12),
        const Card(
            child: ListTile(
                leading: Icon(Icons.flag_outlined),
                title: Text('Proudly South African'),
                subtitle: Text(
                    'Meal ideas focus on familiar local ingredients and budget-friendly cooking.'))),
        const SizedBox(height: 12),
        const Text(
            'Note: a few legacy cards still use light surfaces in dark mode and can be refined in a later UI pass.',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      ]));
}

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});
  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selected = 'monthly';
  bool demoActive = false;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Membership')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        const Text('Choose your plan',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w900, color: ink)),
        const SizedBox(height: 8),
        const Text(
            'Core budgeting remains free. Premium is designed for users who want more planning tools.',
            style: TextStyle(height: 1.4)),
        const SizedBox(height: 16),
        _planCard(
            'Free',
            'R0',
            'Budget calculator\nBasic meal ideas\nShopping list',
            selected == 'free',
            () => setState(() => selected = 'free')),
        const SizedBox(height: 10),
        _planCard(
            'Premium Monthly',
            'R50 / month',
            'Expanded meal plans\nSaved weekly plans\nAdvanced household planning',
            selected == 'monthly',
            () => setState(() => selected = 'monthly')),
        const SizedBox(height: 10),
        _planCard(
            'Premium Yearly',
            'R100 / year',
            'All monthly premium features\nOne yearly renewal',
            selected == 'yearly',
            () => setState(() => selected = 'yearly')),
        const SizedBox(height: 16),
        if (demoActive)
          const Text(
              'Demo selection only. No payment was taken and no paid entitlement was granted.',
              style: TextStyle(
                  color: Colors.deepOrange, fontWeight: FontWeight.w700)),
        FilledButton(
            onPressed: () => setState(() => demoActive = true),
            child: Text(selected == 'free'
                ? 'Continue with Free'
                : 'Continue / Renew $selected')),
        const SizedBox(height: 10),
        const Text(
            'Payment gateway, renewal billing, cancellation, receipts and server-side entitlement checks must be connected before accepting real payments. R100/year is implemented as requested, although it is cheaper than two monthly payments.',
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
      ]));
  Widget _planCard(String title, String price, String features, bool active,
          VoidCallback onTap) =>
      Card(
          color: active ? const Color(0xFFFFE8A3) : Colors.white,
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Text(title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17))),
                          Text(price,
                              style: const TextStyle(
                                  color: green, fontWeight: FontWeight.w900))
                        ]),
                        const SizedBox(height: 8),
                        Text(features, style: const TextStyle(height: 1.6)),
                        const SizedBox(height: 5),
                        Text(active ? 'Selected' : 'Tap to select',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54))
                      ]))));
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
    final b = double.tryParse(_budget.text) ?? 0;
    final r = double.tryParse(_restaurant.text) ?? 0;
    final left = b - (includeInTotal ? r : 0);
    return Scaffold(
        appBar: AppBar(title: const Text('Cheat day planner')),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          const Text('Enjoy a meal out without losing track',
              style: TextStyle(
                  fontSize: 23, fontWeight: FontWeight.w900, color: ink)),
          const SizedBox(height: 8),
          const Text(
              'A restaurant day can be planned inside your food budget or tracked separately. Keeping it separate does not mean the expense disappears.',
              style: TextStyle(height: 1.4)),
          const SizedBox(height: 16),
          TextField(
              controller: _budget,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                  labelText: 'Available food budget (R)',
                  border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: _restaurant,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                  labelText: 'Restaurant-day allowance (R)',
                  border: OutlineInputBorder())),
          SwitchListTile(
              value: includeInTotal,
              onChanged: (v) => setState(() => includeInTotal = v),
              title: const Text('Count restaurant meal in this budget'),
              subtitle: const Text(
                  'Turn off only if tracking it in a separate budget.'),
              contentPadding: EdgeInsets.zero),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Budget result',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text('Remaining: R${left.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: left < 0 ? Colors.red : green)),
                        Text(left < 0
                            ? 'This plan exceeds your chosen budget by R${(-left).toStringAsFixed(2)}.'
                            : 'The restaurant allowance fits the selected budget.'),
                      ])))
        ]));
  }
}

class OffersPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool birthday;
  const OffersPage(
      {super.key,
      required this.title,
      required this.icon,
      required this.birthday});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Icon(icon, size: 44, color: green),
        const SizedBox(height: 10),
        Text(birthday ? 'Birthday rewards' : 'Black Friday watchlist',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: ink)),
        const SizedBox(height: 8),
        Text(
            birthday
                ? 'Possible places to check for birthday freebies or discounts. Eligibility often requires a loyalty account, app, ID or advance registration.'
                : 'Use this page to collect retailer promotions during the Black Friday period. Compare unit prices and check exclusions before buying.',
            style: const TextStyle(height: 1.4)),
        const SizedBox(height: 14),
        ...((birthday
                ? [
                    'Spur — check current birthday-club terms',
                    'RocoMamas — check current loyalty/offer terms',
                    'Krispy Kreme — check local store promotions',
                    'Local cafés and restaurants — ask about birthday rewards'
                  ]
                : [
                    'Checkers — verify offers in the official app/site',
                    'Pick n Pay — verify offers in the official app/site',
                    'Makro — verify online promotions and dates',
                    'Game — compare the normal price with the advertised deal',
                    'Woolworths Food — check product-specific promotions'
                  ])
            .map((s) => Card(
                child: ListTile(
                    leading: Icon(icon, color: green),
                    title: Text(s,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text(
                        'Not a verified live offer. Confirm with the business before relying on it.'))))),
        const SizedBox(height: 8),
        const Text(
            'This list is a starting point, not a guarantee that any offer is currently available. Live offers need approved feeds or manual verification and an expiry date.',
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4))
      ]));
}
