import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StackedCards extends StatefulWidget {
  const StackedCards({super.key});

  @override
  State<StackedCards> createState() => _StackedCardsState();
}

class _StackedCardsState extends State<StackedCards> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _cardsData = [
    {"type": "Debit Cards", "color": const Color(0xFF4A148C), "bal": "₹ 1,24,500"},
    {"type": "Credit Cards", "color": const Color(0xFF0D47A1), "bal": "₹ 45,000 Due"},
    {"type": "Loans", "color": const Color(0xFFE65100), "bal": "₹ 5,00,000"},
    {"type": "Investments", "color": const Color(0xFF1B5E20), "bal": "₹ 12,50,000"},
  ];

  late List<int> _cardOrder;
  double _dragOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    _cardOrder = List.generate(_cardsData.length, (index) => index);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragOffset > 50 || details.velocity.pixelsPerSecond.dy > 300) {
      HapticFeedback.mediumImpact();
      setState(() {
        int topCard = _cardOrder.removeAt(0);
        _cardOrder.add(topCard);
        _dragOffset = 0.0;
      });
    } else {
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: List.generate(_cardOrder.length, (index) {
        int cardIndex = _cardOrder[index];
        bool isTop = index == 0;
        
        double offsetTop = index * 12.0;
        double scale = 1.0 - (index * 0.05);
        if (scale < 0.8) scale = 0.8;
        
        double currentTop = isTop ? offsetTop + _dragOffset : offsetTop;
        double currentOpacity = isTop 
            ? (1.0 - (_dragOffset / 200).clamp(0.0, 1.0)) 
            : 1.0;

        return AnimatedPositioned(
          duration: isTop && _dragOffset != 0 ? Duration.zero : const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          top: currentTop,
          left: 16,
          right: 16,
          child: AnimatedScale(
            duration: isTop && _dragOffset != 0 ? Duration.zero : const Duration(milliseconds: 300),
            scale: scale,
            child: Opacity(
              opacity: currentOpacity,
              child: GestureDetector(
                onPanUpdate: isTop ? _onPanUpdate : null,
                onPanEnd: isTop ? _onPanEnd : null,
                child: Container(
                  height: 160,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _cardsData[cardIndex]["color"],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), 
                        blurRadius: 10, 
                        offset: const Offset(0, 5)
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _cardsData[cardIndex]["type"],
                        style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _cardsData[cardIndex]["bal"],
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).reversed.toList(),
    );
  }
}
