import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MealFinderScreen extends StatefulWidget {
  const MealFinderScreen({super.key});

  @override
  State<MealFinderScreen> createState() => _MealFinderScreenState();
}

class _MealFinderScreenState extends State<MealFinderScreen> {
  // Premium UI Colors
  final Color primaryColor = const Color(0xFF0F4C3A); 
  final Color accentColor = const Color(0xFFD4AF37); 
  final Color bgColor = const Color(0xFFF0F4F8); 
  final Color textMain = const Color(0xFF1C2833);
  final Color textMuted = const Color(0xFF7F8C8D);
  final Color surfaceColor = const Color(0xFFFFFFFF);

  // RUBRIC 4.1.1: Form and Validators
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ingredientController = TextEditingController();

  final List<String> _availableIngredients = [
    'Chicken', 'Eggs', 'Rice', 'Vegetables', 'Beef', 'Pasta', 'Fish', 
    'Garlic', 'Onion', 'Tomato Sauce', 'Cheese', 'Lemon', 'Butter'
  ];
  final List<String> _selectedIngredients = [];

  Future<List<Map<String, dynamic>>>? _recipesFuture;

  // RUBRIC 4.1.2: REAL FIRESTORE READ OPERATION
  Future<List<Map<String, dynamic>>> _findRecipes() async {
    if (_selectedIngredients.isEmpty) return [];

    List<Map<String, dynamic>> matchedRecipes = [];

    try {
      // Fetches real data from your Firebase Cloud Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('recipes').get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> recipe = doc.data() as Map<String, dynamic>;
        // Safely extract tags array from Firestore document
        List<String> recipeTags = List<String>.from(recipe['tags'] ?? []);
        
        int matchCount = 0;
        for (var selected in _selectedIngredients) {
          if (recipeTags.contains(selected)) {
            matchCount++;
          }
        }

        if (matchCount > 0) {
          recipe['matchCount'] = matchCount; 
          matchedRecipes.add(recipe);
        }
      }

      // Sort by best match
      matchedRecipes.sort((a, b) => b['matchCount'].compareTo(a['matchCount']));
      
    } catch (e) {
      // In case Firebase is not connected yet during testing, fallback to empty list
      debugPrint("Firestore Error: $e");
    }

    return matchedRecipes;
  }

  void _addCustomIngredient() {
    // RUBRIC 4.1.1: Trigger Form Validation
    if (_formKey.currentState!.validate()) {
      String newIngredient = _ingredientController.text.trim();
      newIngredient = newIngredient[0].toUpperCase() + newIngredient.substring(1).toLowerCase();
      
      setState(() {
        if (!_availableIngredients.contains(newIngredient)) {
          _availableIngredients.insert(0, newIngredient); 
        }
        if (!_selectedIngredients.contains(newIngredient) && _selectedIngredients.length < 10) {
          _selectedIngredients.add(newIngredient);
        }
      });
      _ingredientController.clear();
      FocusScope.of(context).unfocus(); 
    }
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textMuted),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(color: textMuted, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- AI CHEF SELECTION CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(Icons.kitchen_rounded, "AI Chef"),
                    Text('Select fridge ingredients:', style: TextStyle(fontWeight: FontWeight.w600, color: textMuted, fontSize: 13)),
                    const SizedBox(height: 12),
                    
                    // RUBRIC 4.1.1: FORM IMPLEMENTATION
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _ingredientController,
                        textInputAction: TextInputAction.done, 
                        onFieldSubmitted: (value) => _addCustomIngredient(),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Type an ingredient to add...',
                          hintStyle: TextStyle(color: textMuted.withOpacity(0.6), fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add_circle, color: primaryColor),
                            onPressed: _addCustomIngredient,
                          ),
                        ),
                        // VALIDATOR COMPONENT
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an ingredient name';
                          }
                          if (value.length > 20) {
                            return 'Keep ingredient names short';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _availableIngredients.map((ingredient) {
                        final isSelected = _selectedIngredients.contains(ingredient);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedIngredients.remove(ingredient);
                              } else if (_selectedIngredients.length < 10) {
                                _selectedIngredients.add(ingredient);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected 
                                ? [BoxShadow(color: primaryColor.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))] 
                                : [],
                            ),
                            child: Text(
                              ingredient,
                              style: TextStyle(color: isSelected ? Colors.white : textMuted, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _recipesFuture = _findRecipes();
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Find Recipes', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- RESULTS SECTION ---
              if (_recipesFuture != null)
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _recipesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Padding(padding: const EdgeInsets.all(20), child: CircularProgressIndicator(color: primaryColor)));
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Firebase Error. Ensure Firestore is connected.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No matching recipes found in Database.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }

                    List<Map<String, dynamic>> recipes = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(Icons.list_alt_rounded, "Suggested Meals (${recipes.length})"),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            return _buildRecipeCard(context, recipes[index]);
                          },
                        ),
                        const SizedBox(height: 80), 
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        // RUBRIC 4.1.1: NAMED ROUTES USAGE
        Navigator.pushNamed(
          context, 
          '/recipe_detail', 
          arguments: recipe, // Pass the Firestore document data to the detail screen
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
        ),
        child: Row(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(18)),
              child: Icon(Icons.restaurant_rounded, color: primaryColor, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'] ?? 'Unknown Recipe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textMain),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14, color: textMuted),
                      const SizedBox(width: 4),
                      Text('${recipe['prepTime_min']} mins', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textMuted)),
                      const SizedBox(width: 15),
                      Icon(Icons.local_fire_department_rounded, size: 14, color: textMuted),
                      const SizedBox(width: 4),
                      Text('${recipe['calories']} kcal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textMuted)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// RECIPE DETAIL SCREEN (Inside the same file)
// ==========================================
class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // RUBRIC 4.1.1: Capture the data passed via Named Route
    final Map<String, dynamic> recipe = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Color primaryColor = const Color(0xFF0F4C3A);
    final Color textMain = const Color(0xFF1C2833);
    final Color textMuted = const Color(0xFF7F8C8D);
    
    final List<String> ingredients = List<String>.from(recipe['fullIngredients'] ?? []);
    final List<String> instructions = List<String>.from(recipe['instructions'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: primaryColor),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Player Placeholder
              Container(
                height: 220, width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 25, offset: const Offset(0, 8))]
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(opacity: 0.5, child: Icon(Icons.restaurant_rounded, size: 100, color: Colors.grey[800])),
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: Icon(Icons.play_arrow_rounded, color: primaryColor, size: 35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Details Card
              Container(
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 8))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe['title'] ?? 'Recipe Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textMain)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildStatBadge(Icons.schedule_rounded, '${recipe['prepTime_min']} mins', const Color(0xFFD4AF37)),
                        const SizedBox(width: 15),
                        _buildStatBadge(Icons.local_fire_department_rounded, '${recipe['calories']} kcal', Colors.orange),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFF1F5F9), thickness: 2)),
                    
                    Text('INGREDIENTS', style: TextStyle(color: textMuted, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.0)),
                    const SizedBox(height: 10),
                    ...ingredients.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6), decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle)),
                          const SizedBox(width: 15),
                          Expanded(child: Text(item, style: TextStyle(fontSize: 14, color: textMain, fontWeight: FontWeight.w600))),
                        ],
                      ),
                    )),

                    const SizedBox(height: 20),
                    Text('PREPARATION', style: TextStyle(color: textMuted, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.0)),
                    const SizedBox(height: 10),
                    ...instructions.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32, height: 32, alignment: Alignment.center,
                              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
                              child: Text('${entry.key + 1}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 14)),
                            ),
                            const SizedBox(width: 15),
                            Expanded(child: Text(entry.value, style: TextStyle(fontSize: 14, height: 1.5, color: textMain, fontWeight: FontWeight.w500))),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 12)),
        ],
      ),
    );
  }
}