import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ← Añade este import
import 'package:intl/intl.dart';

class DatePickerHelper {
  static Future<DateTime?> showDatePickerDialog({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    Locale? locale,
  }) async {
    // Verificar que el contexto tenga MaterialLocalizations
    final materialLocalizations = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    
    if (materialLocalizations == null) {
      // Si no hay MaterialLocalizations, usar un fallback
      return await _showFallbackDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    }
    
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      locale: locale ?? const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: Localizations.override(
            context: context,
            locale: locale ?? const Locale('es', 'ES'),
            delegates: const [
              GlobalMaterialLocalizations.delegate, // ← Cambia esto
              GlobalWidgetsLocalizations.delegate, // ← Cambia esto
            ],
            child: child!,
          ),
        );
      },
    );
  }

  static Future<TimeOfDay?> showTimePickerDialog({
    required BuildContext context,
    TimeOfDay? initialTime,
    Locale? locale,
  }) async {
    // Verificar que el contexto tenga MaterialLocalizations
    final materialLocalizations = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    
    if (materialLocalizations == null) {
      // Si no hay MaterialLocalizations, usar un fallback
      return await _showFallbackTimePicker(
        context: context,
        initialTime: initialTime,
      );
    }
    
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: Localizations.override(
              context: context,
              locale: locale ?? const Locale('es', 'ES'),
              delegates: const [
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
              ],
              child: child!,
            ),
          ),
        );
      },
    );
  }

  // Fallback para DatePicker usando AlertDialog
  static Future<DateTime?> _showFallbackDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    DateTime? selectedDate = initialDate ?? DateTime.now();
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Fecha'),
          content: SizedBox(
            width: 300,
            height: 320,
            child: CalendarDatePicker(
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
              onDateChanged: (date) {
                selectedDate = date;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedDate);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
    
    return selectedDate;
  }

  // Fallback para TimePicker usando AlertDialog
  static Future<TimeOfDay?> _showFallbackTimePicker({
    required BuildContext context,
    TimeOfDay? initialTime,
  }) async {
    TimeOfDay selectedTime = initialTime ?? TimeOfDay.now();
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Hora'),
          content: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTimePicker(context, selectedTime, (time) {
                  selectedTime = time;
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedTime);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
    
    return selectedTime;
  }

  static Widget _buildTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    int hour = initialTime.hour;
    int minute = initialTime.minute;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNumberPicker(
                  value: hour,
                  min: 0,
                  max: 23,
                  onChanged: (value) {
                    setState(() => hour = value);
                    onChanged(TimeOfDay(hour: hour, minute: minute));
                  },
                ),
                const Text(' : ', style: TextStyle(fontSize: 24)),
                _buildNumberPicker(
                  value: minute,
                  min: 0,
                  max: 59,
                  onChanged: (value) {
                    setState(() => minute = value);
                    onChanged(TimeOfDay(hour: hour, minute: minute));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Hora seleccionada: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildNumberPicker({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_drop_up),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
        Container(
          width: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_drop_down),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
      ],
    );
  }
}