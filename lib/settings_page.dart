// settings_page.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkTheme = false;
  String selectedFont = 'Roboto';
  String selectedLanguage = 'English';
  Color selectedColor = Colors.deepPurple;

  final List<String> fonts = ['Roboto', 'OpenSans', 'Lato'];
  final List<String> languages = ['English', 'French', 'Spanish'];
  final List<Color> themeColors = [Colors.deepPurple, Colors.teal, Colors.blue, Colors.orange];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: selectedColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: Text('Dark Theme'),
              value: isDarkTheme,
              onChanged: (value) {
                setState(() => isDarkTheme = value);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Font Selection'),
              subtitle: DropdownButton<String>(
                value: selectedFont,
                onChanged: (value) {
                  setState(() => selectedFont = value!);
                },
                items: fonts.map((font) => DropdownMenuItem(
                  value: font,
                  child: Text(font),
                )).toList(),
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Language'),
              subtitle: DropdownButton<String>(
                value: selectedLanguage,
                onChanged: (value) {
                  setState(() => selectedLanguage = value!);
                },
                items: languages.map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                )).toList(),
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Theme Color'),
              subtitle: Wrap(
                spacing: 8,
                children: themeColors.map((color) => GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 16,
                    child: selectedColor == color ? Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                )).toList(),
              ),
            ),
            Divider(),
            ListTile(
              title: Text('App Info'),
              subtitle: Text('Simple File Organizer v1.0'),
            ),
          ],
        ),
      ),
    );
  }
}
