import 'package:flutter/material.dart';

class CustomInputDropdown extends StatefulWidget {
  const CustomInputDropdown({Key? key}) : super(key: key);

  @override
  State<CustomInputDropdown> createState() => _CustomInputDropdownState();
}

class _CustomInputDropdownState extends State<CustomInputDropdown> {
  String selectedValue = 'Select Option';
  final List<String> items = ['Option 1', 'Option 2', 'Option 3'];

  void showOptions() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => ListView(
        children: items.map((item) {
          return ListTile(
            title: Text(item),
            onTap: () => Navigator.pop(context, item),
          );
        }).toList(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedValue = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom Dropdown Input")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: showOptions,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Select Option',
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              controller: TextEditingController(text: selectedValue),
            ),
          ),
        ),
      ),
    );
  }
}
