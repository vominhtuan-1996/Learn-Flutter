import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';

class AddHabitV1Screen extends StatefulWidget {
  const AddHabitV1Screen({super.key});

  @override
  State<AddHabitV1Screen> createState() => _AddHabitV1ScreenState();
}

class _AddHabitV1ScreenState extends State<AddHabitV1Screen> {
  final _nameController = TextEditingController();
  String _habitType = "Build";
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  String _selectedFrequency = "Daily";
  bool _notificationOn = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);

  final List<IconData> _icons = [
    Icons.book, Icons.fitness_center, Icons.wb_sunny, Icons.water_drop, 
    Icons.favorite, Icons.edit, Icons.code, Icons.music_note
  ];

  final List<Color> _colors = [
    const Color(0xFFFDA758), const Color(0xFFF9B5D0), const Color(0xFF7CB8F7),
    const Color(0xFF85E0A3), const Color(0xFFC4A5F1), const Color(0xFFFF8A8A)
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['mode'] == 'edit') {
        setState(() {
          _nameController.text = args['habitName'] ?? "";
          // In a real app, we would match icon and color indices
          _selectedIconIndex = 0; 
          _selectedColorIndex = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocaleTranslate.deleteHabitConfirm.getString(context),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: themeTokens.colors.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            _buildDeleteOption(
              context, 
              AppLocaleTranslate.deleteAndClear.getString(context), 
              Colors.red, 
              () {
                Navigator.pop(context);
                Navigator.pop(context); // Back to Home
              }
            ),
            const SizedBox(height: 12),
            _buildDeleteOption(
              context, 
              AppLocaleTranslate.archiveKeepHistory.getString(context), 
              themeTokens.colors.primary, 
              () => Navigator.pop(context)
            ),
            const SizedBox(height: 12),
            _buildDeleteOption(
              context, 
              AppLocaleTranslate.cancel.getString(context), 
              themeTokens.colors.onSurface.withOpacity(0.4), 
              () => Navigator.pop(context)
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteOption(BuildContext context, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isEdit = args != null && args['mode'] == 'edit';

    return Scaffold(
      backgroundColor: themeTokens.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeTokens.colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit 
            ? AppLocaleTranslate.editHabitTitle.getString(context)
            : AppLocaleTranslate.addHabitTitle.getString(context),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface,
          ),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Habit Name
            _buildLabel(context, AppLocaleTranslate.habitNameLabel.getString(context)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: AppLocaleTranslate.habitNameHint.getString(context),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Habit Type
            Row(
              children: [
                _buildTypeTab("Build", AppLocaleTranslate.buildHabit.getString(context)),
                const SizedBox(width: 12),
                _buildTypeTab("Quit", AppLocaleTranslate.quitHabit.getString(context)),
              ],
            ),
            const SizedBox(height: 24),
            // Icon & Color Picker
            _buildLabel(context, AppLocaleTranslate.habitIconLabel.getString(context)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _icons.length,
                    itemBuilder: (context, index) => _buildIconItem(index),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_colors.length, (index) => _buildColorItem(index)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Frequency
            _buildLabel(context, AppLocaleTranslate.habitFrequencyLabel.getString(context)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFrequencyChip("Daily", AppLocaleTranslate.daily.getString(context)),
                const SizedBox(width: 8),
                _buildFrequencyChip("Weekly", AppLocaleTranslate.weekly.getString(context)),
                const SizedBox(width: 8),
                _buildFrequencyChip("Monthly", AppLocaleTranslate.monthly.getString(context)),
              ],
            ),
            const SizedBox(height: 24),
            // Reminder
            _buildLabel(context, AppLocaleTranslate.reminderLabel.getString(context)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: _reminderTime);
                      if (time != null) setState(() => _reminderTime = time);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: HabitBuilderTheme.light.colors.primary),
                        const SizedBox(width: 12),
                        Text(
                          _reminderTime.format(context),
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: HabitBuilderTheme.light.colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notificationOn,
                    onChanged: (val) => setState(() => _notificationOn = val),
                    activeColor: HabitBuilderTheme.light.colors.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HabitBuilderTheme.light.colors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  AppLocaleTranslate.saveButton.getString(context),
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    final themeTokens = HabitBuilderTheme.light;
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: themeTokens.colors.onSurface.withOpacity(0.4),
      ),
    );
  }

  Widget _buildTypeTab(String type, String label) {
    final isSelected = _habitType == type;
    final themeTokens = HabitBuilderTheme.light;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _habitType = type),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? themeTokens.colors.secondary : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : themeTokens.colors.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconItem(int index) {
    final isSelected = _selectedIconIndex == index;
    final themeTokens = HabitBuilderTheme.light;
    return GestureDetector(
      onTap: () => setState(() => _selectedIconIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _colors[_selectedColorIndex].withOpacity(0.2) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: _colors[_selectedColorIndex], width: 2) : null,
        ),
        child: Icon(
          _icons[index],
          color: isSelected ? _colors[_selectedColorIndex] : Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildColorItem(int index) {
    final isSelected = _selectedColorIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _colors[index],
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected ? [BoxShadow(color: _colors[index].withOpacity(0.5), blurRadius: 10)] : null,
        ),
      ),
    );
  }

  Widget _buildFrequencyChip(String freq, String label) {
    final isSelected = _selectedFrequency == freq;
    final themeTokens = HabitBuilderTheme.light;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFrequency = freq),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? themeTokens.colors.secondary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? null : Border.all(color: themeTokens.colors.onBackground.withOpacity(0.1)),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : themeTokens.colors.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
