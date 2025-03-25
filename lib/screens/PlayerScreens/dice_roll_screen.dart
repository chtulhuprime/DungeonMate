import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/character.dart';

class DiceRollScreen extends StatefulWidget {
  final Character character;

  const DiceRollScreen({super.key, required this.character});

  @override
  State<DiceRollScreen> createState() => _DiceRollScreenState();
}

class _DiceRollScreenState extends State<DiceRollScreen>
    with SingleTickerProviderStateMixin {
  // Выбранные параметры
  String _selectedDice = 'd20'; // Тип кубика
  String _selectedAttribute = 'Сила'; // Характеристика
  int _numberOfDice = 1; // Количество кубиков
  String _rollType = 'Обычный'; // Тип броска: Обычный, Преимущество, Помеха

  // Результат броска
  List<int> _rollResults = [];
  int _totalResult = 0;

  // Анимация
  late AnimationController _controller;
  late Animation<double> _animation;

  // Список доступных кубиков
  final List<String> _diceTypes = ['d4', 'd6', 'd8', 'd10', 'd12', 'd20', 'd100'];

  // Список характеристик
  final List<String> _attributes = ['Сила', 'Ловкость', 'Телосложение', 'Интеллект', 'Мудрость', 'Харизма'];

  // Список типов бросков
  final List<String> _rollTypes = ['Обычный', 'Преимущество', 'Помеха'];

  @override
  void initState() {
    super.initState();
    // Инициализация анимации
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Функция для броска кубика
  void _rollDice() {
    final random = Random();
    final modifier = _getModifier(_selectedAttribute); // Получаем модификатор характеристики
    _rollResults.clear();
    _totalResult = 0;

    // Запуск анимации
    _controller.reset();
    _controller.forward();

    // Задержка для завершения анимации перед отображением результата
    Future.delayed(const Duration(milliseconds: 1000), () {
      for (int i = 0; i < _numberOfDice; i++) {
        final diceValue = _selectedDice.substring(1); // Убираем "d" из названия кубика
        final maxValue = int.parse(diceValue);
        int roll1 = random.nextInt(maxValue) + 1; // Первый бросок
        int roll2 = random.nextInt(maxValue) + 1; // Второй бросок (для преимущества/помехи)

        int finalRoll = roll1;
        if (_rollType == 'Преимущество') {
          finalRoll = max(roll1, roll2); // Выбираем наибольший результат
        } else if (_rollType == 'Помеха') {
          finalRoll = min(roll1, roll2); // Выбираем наименьший результат
        }

        _rollResults.add(finalRoll);
        _totalResult += finalRoll;
      }

      // Добавляем модификатор к общему результату
      _totalResult += modifier;

      setState(() {});
    });
  }

  // Получение модификатора характеристики
  int _getModifier(String attribute) {
    switch (attribute) {
      case 'Сила':
        return (widget.character.strength - 10) ~/ 2;
      case 'Ловкость':
        return (widget.character.dexterity - 10) ~/ 2;
      case 'Телосложение':
        return (widget.character.constitution - 10) ~/ 2;
      case 'Интеллект':
        return (widget.character.intelligence - 10) ~/ 2;
      case 'Мудрость':
        return (widget.character.wisdom - 10) ~/ 2;
      case 'Харизма':
        return (widget.character.charisma - 10) ~/ 2;
      default:
        return 0;
    }
  }

  // Виджет для отображения кубика
  Widget _buildDiceWidget(int index) {
    int sides;
    switch (_selectedDice) {
      case 'd4':
        sides = 4;
        break;
      case 'd6':
        sides = 6;
        break;
      case 'd8':
        sides = 8;
        break;
      case 'd10':
        sides = 10;
        break;
      case 'd12':
        sides = 12;
        break;
      case 'd20':
        sides = 20;
        break;
      case 'd100':
        sides = 100;
        break;
      default:
        sides = 6; // По умолчанию d6
    }

    return RotationTransition(
      turns: _animation,
      child: CustomPaint(
        size: const Size(60, 60), // Уменьшенный размер кубика
        painter: DiePainter(
          sides: sides,
          color: Colors.blue,
          textColor: Colors.white,
          withText: true,
          value: _rollResults.isNotEmpty ? _rollResults[index] : null, // Передаем выпавшее число
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Бросок кубика'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Выбор типа кубика
            DropdownButton<String>(
              value: _selectedDice,
              items: _diceTypes.map((dice) {
                return DropdownMenuItem(
                  value: dice,
                  child: Text(dice),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDice = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Выбор характеристики
            DropdownButton<String>(
              value: _selectedAttribute,
              items: _attributes.map((attribute) {
                return DropdownMenuItem(
                  value: attribute,
                  child: Text(attribute),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAttribute = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Выбор количества кубиков
            Row(
              children: [
                const Text('Количество кубиков:'),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _numberOfDice,
                  items: List.generate(10, (index) => index + 1).map((number) {
                    return DropdownMenuItem(
                      value: number,
                      child: Text('$number'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _numberOfDice = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Выбор типа броска
            DropdownButton<String>(
              value: _rollType,
              items: _rollTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _rollType = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Кнопка броска
            ElevatedButton(
              onPressed: _rollDice,
              child: const Text('Бросить кубик'),
            ),
            const SizedBox(height: 20),

            // Отрисовка нескольких кубиков с прокруткой
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center, // Выравнивание по центру
                  spacing: 10, // Расстояние между кубиками
                  runSpacing: 10, // Расстояние между рядами
                  children: List.generate(
                    _numberOfDice,
                        (index) => _buildDiceWidget(index),
                  ),
                ),
              ),
            ),

            // Результат броска
            if (_rollResults.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Результаты: ${_rollResults.join(', ')}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Общий результат: $_totalResult',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Класс для отрисовки кубиков
class DiePainter extends CustomPainter {
  final int sides;
  final Color color;
  final Color textColor;
  final bool withText;
  final int? value; // Выпавшее число

  DiePainter({
    required this.sides,
    required this.color,
    required this.textColor,
    this.withText = true,
    this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (sides) {
      case 2:
        canvas.drawCircle(
            Offset(size.width / 2, size.height / 2), size.width * 0.5, paint);
        break;
      case 4:
        Offset p1 = Offset(size.width / 2, -size.height / 8);
        Offset p2 = Offset(-size.width / 6, size.height);
        Offset p3 = Offset(size.width + size.width / 6, size.height);

        final double radius = size.width * 0.05;

        Path path = Path();
        path.moveTo(p1.dx + radius, p1.dy + radius);
        path.quadraticBezierTo(p1.dx, p1.dy, p1.dx - radius, p1.dy + radius);
        path.lineTo(p2.dx + radius, p2.dy - radius * 3);
        path.quadraticBezierTo(
            p2.dx, p2.dy - radius, p2.dx + radius * 2, p2.dy);
        path.lineTo(p3.dx - radius * 2, p3.dy);
        path.quadraticBezierTo(
            p3.dx, p3.dy - radius, p3.dx - radius, p3.dy - radius * 3);
        path.close();

        canvas.drawPath(path, paint);
        break;
      case 6:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(0, 0, size.width, size.height),
                Radius.circular(size.width * 0.1)),
            paint);
        break;
      case 8:
      case 10:
      case 100:
        final PictureRecorder pictureRecorder = PictureRecorder();
        final Canvas pictureCanvas = Canvas(pictureRecorder);

        pictureCanvas.translate(size.width / 2, size.height / 2);
        pictureCanvas.rotate(45 * pi / 180);

        pictureCanvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(
                    -size.width / 2, -size.height / 2, size.width, size.height),
                Radius.circular(size.width * 0.1)),
            paint);

        final Picture picture = pictureRecorder.endRecording();

        canvas.save();
        canvas.translate(size.width / 2, size.height / 2);

        if (sides == 10 || sides == 100) {
          canvas.scale(1.0, 0.9);
        } else {
          canvas.scale(0.85, 1.0);
        }

        canvas.translate(-size.width / 2, -size.height / 2);
        canvas.drawPicture(picture);
        canvas.restore();
        break;
      case 12:
        double radius = size.width * 0.05;

        Offset p1 = Offset(size.width / 2, -radius * 3.0);
        Offset p2 = Offset(-radius * 2.0, size.height / 2.5);
        Offset p3 = Offset(size.width / 6, size.height);
        Offset p4 = Offset(size.width - size.width / 6, size.height);
        Offset p5 = Offset(size.width + radius * 2.0, size.height / 2.5);

        Path path = Path();
        path.moveTo(p1.dx + radius, p1.dy + radius);
        path.arcToPoint(Offset(p1.dx - radius, p1.dy + radius),
            radius: Radius.elliptical(radius * 1.25, radius * 0.75),
            clockwise: false);
        path.lineTo(p2.dx + radius, p2.dy - radius);
        path.arcToPoint(Offset(p2.dx + radius, p2.dy + radius),
            radius: Radius.elliptical(radius * 0.75, radius * 1.25),
            clockwise: false);
        path.lineTo(p3.dx - radius, p3.dy - radius * 2.0);
        path.arcToPoint(Offset(p3.dx + radius, p3.dy),
            radius: Radius.circular(radius * 3.0), clockwise: false);
        path.lineTo(p4.dx - radius, p4.dy);
        path.arcToPoint(Offset(p4.dx + radius, p4.dy - radius * 2.0),
            radius: Radius.circular(radius * 3.0), clockwise: false);
        path.lineTo(p5.dx - radius, p5.dy + radius);
        path.arcToPoint(Offset(p5.dx - radius, p5.dy - radius),
            radius: Radius.elliptical(radius * 0.75, radius * 1.25),
            clockwise: false);
        path.close();

        canvas.drawPath(path, paint);
        break;
      case 20:
        double radius = size.width * 0.05;

        Offset p1 = Offset(size.width / 2, -radius * 3.0);
        Offset p2 = Offset(-radius * 2.0, size.height / 4);
        Offset p3 =
        Offset(-radius * 2.0, size.height - size.height / 4 + radius);
        Offset p4 = Offset(size.width / 2, size.height + radius * 3.0);
        Offset p5 = Offset(
            size.width + radius * 2.0, size.height - size.height / 4 + radius);
        Offset p6 = Offset(size.width + radius * 2.0, size.height / 4);

        Path path = Path();
        path.moveTo(p1.dx + radius, p1.dy + radius);
        path.arcToPoint(Offset(p1.dx - radius, p1.dy + radius),
            radius: Radius.circular(radius * 2.0), clockwise: false);
        path.lineTo(p2.dx + radius * 2.0, p2.dy - radius);
        path.arcToPoint(Offset(p2.dx + radius, p2.dy + radius),
            radius: Radius.circular(radius * 2.0), clockwise: false);
        path.lineTo(p3.dx + radius, p3.dy - radius);
        path.arcToPoint(Offset(p3.dx + radius * 2.0, p3.dy + radius),
            radius: Radius.circular(radius * 2.0), clockwise: false);
        path.lineTo(p4.dx - radius, p4.dy - radius);
        path.arcToPoint(Offset(p4.dx + radius, p4.dy - radius),
            radius: Radius.circular(radius * 2.0), clockwise: false);
        path.lineTo(p5.dx - radius * 2.0, p5.dy + radius);
        path.arcToPoint(Offset(p5.dx - radius, p5.dy - radius),
            radius: Radius.circular(radius * 2.0), clockwise: false);
        path.lineTo(p6.dx - radius, p6.dy + radius);
        path.arcToPoint(Offset(p6.dx - radius * 2.0, p6.dy - radius),
            radius: Radius.circular(radius * 2.0), clockwise: false);
        path.close();

        canvas.drawPath(path, paint);

        canvas.drawCircle(
            Offset(size.width / 2, size.height / 2), radius * 1.5, paint);
        break;
    }

    if (!withText || value == null) {
      return;
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '$value', // Отображаем выпавшее число
        style: TextStyle(
          color: textColor,
          fontSize: size.width * 0.33,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(DiePainter oldDelegate) {
    return oldDelegate.sides != sides || oldDelegate.value != value;
  }
}