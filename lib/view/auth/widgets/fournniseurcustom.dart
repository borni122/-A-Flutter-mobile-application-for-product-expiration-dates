import 'package:flutter/material.dart';
import 'package:stockify/constance.dart';

class CustomDropdownFormFieldFournniseur<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final ValueChanged<T?>? onChanged;
  final List<T> items; // Modifiez le type de la liste des éléments
  final String? errorText;
  final String? dropdownValue;

  const CustomDropdownFormFieldFournniseur({
    Key? key,
    required this.value,
    required this.hint,
    required this.onChanged,
    required this.items,
    this.errorText,
    this.dropdownValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint ?? ''),
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()), // Utilisez la méthode toString() pour afficher le nom du fournisseur
        );
      }).toList(),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: primaryColor),
        ),
        labelText: dropdownValue ?? '',
        errorText: errorText,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: primaryColor),
        ),
        labelStyle: TextStyle(color: primaryColor),
      ),
    );
  }
}
