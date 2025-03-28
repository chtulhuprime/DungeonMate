import 'package:flutter/material.dart';

class InteractiveMapScreen extends StatefulWidget {
  @override
  _InteractiveMapScreenState createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  final int _mapSize = 10;
  final double _cellSize = 50.0;
  int _playerX = 0;
  int _playerY = 0;
  double _pixelSize = 0;
  List<Offset> _availableCells = [];

  @override
  void initState() {
    super.initState();
    pixelSize();
    _updateAvailableCells();
  }

  // Обновление списка доступных клеток с точным расчетом расстояния
  void _updateAvailableCells() {
    _availableCells.clear();

    for (int x = 0; x < _mapSize; x++) {
      for (int y = 0; y < _mapSize; y++) {
        // Используем "шахматное" расстояние (манхэттенское)
        final distance = (x - _playerX).abs() + (y - _playerY).abs();
        if (distance <= 6 && distance != 0) {
          _availableCells.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }
  }

  // Высчитывание размеров изображения и координат для изображения персонажа
  void pixelSize() {
    _pixelSize = 411.6/ _mapSize;
  }

  // Перемещение персонажа с проверкой расстояния
  void _movePlayer(int targetX, int targetY) {
    final distance = (targetX - _playerX).abs() + (targetY - _playerY).abs();
    if (distance > 6) return;
    debugPrint("Нажатие на координаты: ($targetX, $targetY)");
    debugPrint("Смещение от персонажа: (${targetY-_playerX}, ${targetY-_playerY})");

    setState(() {
      _playerX = targetX;
      _playerY = targetY;
      _updateAvailableCells();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Точное позиционирование')),
      body: InteractiveViewer(
        boundaryMargin: EdgeInsets.all(double.infinity),
        minScale: 0.5,
        maxScale: 3.0,
        child: Container(
          width: _mapSize * _cellSize,
          height: _mapSize * _cellSize,
          child: Stack(
            children: [
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _mapSize,
                  childAspectRatio: 1.0,
                ),
                itemCount: _mapSize * _mapSize,
                itemBuilder: (context, index) {
                  final x = index % _mapSize;
                  final y = index ~/ _mapSize;
                  final isAvailable = _availableCells.any(
                        (cell) => cell.dx == x && cell.dy == y,
                  );

                  return GestureDetector(
                    onTap: () => _movePlayer(x, y),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: isAvailable ? Colors.green.withOpacity(0.3) : null,
                      ),
                    ),
                  );
                },
              ),

              // Персонаж с точным позиционированием
              Positioned(
                left: _playerX * _pixelSize, //10.29 на 40 пикселей; 20.58 на 20 пикселей,
                top: _playerY  * _pixelSize, // сделать формулу по высчитыванию координат и размера изображения
                child: SizedBox(
                  child: Image.asset(
                    'assets/shield.png',
                    width: _pixelSize,
                    height: _pixelSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}