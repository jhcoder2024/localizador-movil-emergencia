import 'package:flutter/material.dart';

class IntervalSection extends StatelessWidget {
  final int valor;
  final ValueChanged<int> onChanged;

  const IntervalSection({
    super.key,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Intervalo de envío',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Cada $valor min',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: valor.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '$valor minutos',
              activeColor: const Color(0xFFD32F2F),
              onChanged: (v) => onChanged(v.toInt()),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 min', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('30 min', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
