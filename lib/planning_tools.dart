import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _red = Color(0xFFD20E22);
const _yellow = Color(0xFFFFC928);
const _ink = Color(0xFF24130D);
const _cream = Color(0xFFFFF9EB);

/// Offline-first planning tool. Price and nutrient figures are explicitly illustrative
/// until CatchAChow connects approved local product feeds and a validated nutrient dataset.
class MealPlanBuilderPage extends StatefulWidget {
  const MealPlanBuilderPage({super.key});
  @override
  State<MealPlanBuilderPage> createState() => _MealPlanBuilderPageState();
}

class _MealPlanBuilderPageState extends State<MealPlanBuilderPage> {
  final _budget = TextEditingController(text: '250');
  final _days = TextEditingController(text: '5');
  final _pantry = TextEditingController();
  int _people = 1;
  bool _vegetarian = false;
  bool _noFridge = false;
  bool _microwaveOnly = false;
  bool _generated = false;
  bool _saving = false;
  List<String> _pantryItems = [];
  List<_PlannedMeal> _plan = [];
  Map<String, int> _shoppingList = {};
  double _estimatedTotal = 0;
  double _estimatedCaloriesPerPersonDay = 0;

  static const _recipes = <_Recipe>[
    _Recipe('Rice, beans & cabbage bowl', {'rice': 1, 'baked beans': 1, 'cabbage': 1}, 49.0, 620, false, false, 'Cook rice; heat beans; sauté or steam cabbage.'),
    _Recipe('Egg fried rice with vegetables', {'rice': 1, 'eggs': 6, 'mixed vegetables': 1}, 58.0, 540, false, false, 'Cook rice, scramble eggs, then stir-fry with vegetables.'),
    _Recipe('Peanut butter oats with banana', {'oats': 1, 'peanut butter': 1, 'bananas': 4}, 43.0, 480, true, true, 'Prepare oats with hot water; add sliced banana and peanut butter.'),
    _Recipe('Bean & potato stew', {'potatoes': 1, 'baked beans': 1, 'onions': 1}, 52.0, 510, true, false, 'Boil diced potatoes and onions until tender; stir in beans.'),
    _Recipe('Chicken, rice & vegetables', {'chicken portions': 4, 'rice': 1, 'mixed vegetables': 1}, 86.0, 650, false, false, 'Cook chicken fully; serve with rice and vegetables.'),
    _Recipe('Peanut butter banana wraps', {'wraps': 1, 'peanut butter': 1, 'bananas': 4}, 55.0, 500, true, true, 'Spread peanut butter on wraps, add banana and roll.'),
  ];

  @override
  void initState() { super.initState(); _loadPantry(); }
  @override
  void dispose() { _budget.dispose(); _days.dispose(); _pantry.dispose(); super.dispose(); }

  Future<void> _loadPantry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('catchachow_pantry_v1') ?? [];
      if (!mounted) return;
      setState(() { _pantryItems = saved; _pantry.text = saved.join(', '); });
    } catch (_) { /* Planner still works when local storage is unavailable. */ }
  }

  Future<void> _savePantry() async {
    final items = _pantry.text.split(',').map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty).toSet().toList()..sort();
    setState(() { _pantryItems = items; _saving = true; });
    try { final prefs = await SharedPreferences.getInstance(); await prefs.setStringList('catchachow_pantry_v1', items); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pantry is available for this session, but could not be saved on this device.'))); }
    if (mounted) setState(() => _saving = false);
  }

  void _generate() {
    final budget = double.tryParse(_budget.text.trim());
    final days = int.tryParse(_days.text.trim());
    if (budget == null || budget <= 0 || days == null || days < 1 || days > 31) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a budget above R0 and between 1 and 31 days.'))); return;
    }
    final available = budget;
    final perDayPerPerson = budget / days / _people;
    final pantry = _pantryItems.toSet();
    final candidates = _recipes.where((r) => (!_vegetarian || r.vegetarian) && (!_microwaveOnly || r.noStove)).toList()
      ..sort((a,b) => a.estimatedCost.compareTo(b.estimatedCost));
    if (candidates.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No matching meals. Change the cooking or diet filters.'))); return; }
    final selected = <_PlannedMeal>[];
    final list = <String, int>{};
    double total = 0;
    // Greedy, transparent estimate: choose low-cost variety and count package purchases once per selected recipe.
    for (var day = 0; day < days; day++) {
      final recipe = candidates[day % candidates.length];
      final cost = recipe.estimatedCost * _people;
      if (total + cost > available) break;
      selected.add(_PlannedMeal(day + 1, recipe, cost));
      total += cost;
      recipe.ingredients.forEach((ingredient, quantity) {
        final alreadyOwned = pantry.any((p) => ingredient.contains(p) || p.contains(ingredient));
        if (!alreadyOwned) list[ingredient] = (list[ingredient] ?? 0) + quantity * _people;
      });
    }
    setState(() {
      _plan = selected;
      _shoppingList = list;
      _estimatedTotal = total;
      _estimatedCaloriesPerPersonDay = selected.isEmpty ? 0 : selected.fold<double>(0, (sum, m) => sum + m.recipe.calories) / selected.length;
      _generated = true;
    });
    if (selected.length < days) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The estimate could not fit every day. Reduce people/days, increase the budget, or add pantry items.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _cream,
    appBar: AppBar(title: const Text('Build my food plan'), backgroundColor: _cream),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: _yellow, borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.savings_rounded, color: _red, size: 32), SizedBox(height: 8), Text('Your money. Your meals.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _ink)), SizedBox(height: 6), Text('Plan around your real budget, household size, cooking setup and food you already have.', style: TextStyle(height: 1.4, color: _ink))])),
      const SizedBox(height: 14),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('1. Your budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10), TextField(controller: _budget, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Total food budget (R)', border: OutlineInputBorder(), prefixText: 'R ')),
        const SizedBox(height: 10), TextField(controller: _days, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'How many days?', border: OutlineInputBorder())),
        const SizedBox(height: 8), Row(children: [const Expanded(child: Text('People eating', style: TextStyle(fontWeight: FontWeight.w700))), IconButton(onPressed: _people > 1 ? () => setState(() => _people--) : null, icon: const Icon(Icons.remove_circle_outline)), Text('$_people', style: const TextStyle(fontWeight: FontWeight.w800)), IconButton(onPressed: _people < 12 ? () => setState(() => _people++) : null, icon: const Icon(Icons.add_circle_outline))]),
      ])),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('2. Your kitchen and preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        SwitchListTile(contentPadding: EdgeInsets.zero, value: _vegetarian, activeColor: _red, title: const Text('Vegetarian meals'), onChanged: (v) => setState(() => _vegetarian = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, value: _microwaveOnly, activeColor: _red, title: const Text('Microwave / kettle only'), subtitle: const Text('Choose no-stove meal ideas'), onChanged: (v) => setState(() => _microwaveOnly = v),),
        SwitchListTile(contentPadding: EdgeInsets.zero, value: _noFridge, activeColor: _red, title: const Text('No fridge available'), subtitle: const Text('Reminder to avoid storing cooked food for later'), onChanged: (v) => setState(() => _noFridge = v)),
        if (_noFridge) const Text('Food-safety reminder: plan smaller portions and follow package guidance. Do not keep cooked food at room temperature for extended periods.', style: TextStyle(fontSize: 12, color: _red)),
      ])),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('3. What you already have', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Enter ingredients separated by commas. Saved on this device for offline use.', style: TextStyle(color: Colors.black54, fontSize: 12)), const SizedBox(height: 10), TextField(controller: _pantry, maxLines: 3, decoration: const InputDecoration(hintText: 'e.g. rice, oil, salt, onions', border: OutlineInputBorder())), const SizedBox(height: 8), OutlinedButton.icon(onPressed: _saving ? null : _savePantry, icon: const Icon(Icons.save_outlined), label: Text(_saving ? 'Saving…' : 'Save my pantry')),
      ])),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _generate, icon: const Icon(Icons.auto_awesome), label: const Text('Create affordable plan'), style: FilledButton.styleFrom(backgroundColor: _red, padding: const EdgeInsets.all(15)))),
      if (_generated) ...[
        const SizedBox(height: 18),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Your plan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 10), Row(children: [Expanded(child: _metric('ESTIMATED TOTAL', 'R${_estimatedTotal.toStringAsFixed(2)}')), Expanded(child: _metric('BUDGET LEFT', 'R${((double.tryParse(_budget.text) ?? 0) - _estimatedTotal).toStringAsFixed(2)}'))]), const SizedBox(height: 8), Text('${_plan.length} of ${int.tryParse(_days.text) ?? 0} planned days · $_people person(s)', style: const TextStyle(color: Colors.black54))])),
        ..._plan.map((m) => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DAY ${m.day}', style: const TextStyle(color: _red, fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 4), Text(m.recipe.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(m.recipe.method), const SizedBox(height: 8), Text('Estimated recipe cost for $_people: R${m.cost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)), Text('Illustrative energy estimate: ${m.recipe.calories} kcal per serving', style: const TextStyle(color: Colors.black54, fontSize: 12))]))),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Consolidated shopping list', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 8), if (_shoppingList.isEmpty) const Text('Your pantry covers the listed ingredients, or no matching items were generated.'), ..._shoppingList.entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [const Icon(Icons.check_box_outline_blank, size: 20, color: _red), const SizedBox(width: 8), Expanded(child: Text(e.key)), Text('x${e.value}', style: const TextStyle(fontWeight: FontWeight.w800))])))])),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Nutrition and price transparency', style: TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text('Average illustrative energy: ${_estimatedCaloriesPerPersonDay.round()} kcal per planned meal/day. This is not a complete daily calorie total and is not a validated nutrition assessment.'), const SizedBox(height: 6), const Text('All costs and calories in this planner are demo estimates, not live retailer prices. It currently plans one main meal per day. Connect approved product feeds and a validated nutrition database before relying on the totals.', style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.4))])),
      ],
    ]),
  );

  Widget _card(Widget child) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFECEDE6))), child: child);
  Widget _metric(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 1, color: Colors.black54, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 21, color: _red, fontWeight: FontWeight.w900))]);
}

class _Recipe {
  final String name; final Map<String, int> ingredients; final double estimatedCost; final int calories; final bool vegetarian; final bool noStove; final String method;
  const _Recipe(this.name, this.ingredients, this.estimatedCost, this.calories, this.vegetarian, this.noStove, this.method);
}
class _PlannedMeal { final int day; final _Recipe recipe; final double cost; const _PlannedMeal(this.day, this.recipe, this.cost); }
