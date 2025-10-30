import 'dart:async';
import 'package:flutter/material.dart';
import '../models/flash_sale_model.dart';

class FlashSaleTimer extends StatefulWidget {
  final FlashSaleSchedule schedule;
  final VoidCallback? onTimerEnd;

  const FlashSaleTimer({
    Key? key,
    required this.schedule,
    this.onTimerEnd,
  }) : super(key: key);

  @override
  State<FlashSaleTimer> createState() => _FlashSaleTimerState();
}

class _FlashSaleTimerState extends State<FlashSaleTimer> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimer();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTimer());
  }

  void _updateTimer() {
    if (!mounted) return;

    setState(() {
      if (widget.schedule.isUpcoming) {
        _remainingTime = widget.schedule.timeUntilStart;
      } else if (widget.schedule.isActive) {
        _remainingTime = widget.schedule.timeUntilEnd;
      } else {
        _remainingTime = Duration.zero;
        if (widget.onTimerEnd != null) {
          widget.onTimerEnd!();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getTimerColor() {
    if (widget.schedule.isUpcoming) {
      return Colors.blue[700]!;
    } else if (widget.schedule.isActive) {
      return Colors.red[600]!;
    } else {
      return Colors.grey[600]!;
    }
  }

  IconData _getTimerIcon() {
    if (widget.schedule.isUpcoming) {
      return Icons.schedule;
    } else if (widget.schedule.isActive) {
      return Icons.local_fire_department;
    } else {
      return Icons.check_circle;
    }
  }

  String _getTimerText() {
    if (widget.schedule.isEnded) {
      return 'Berakhir';
    }

    final hours = _remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = (_remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  String _getStatusLabel() {
    if (widget.schedule.isUpcoming) {
      return 'Dimulai dalam';
    } else if (widget.schedule.isActive) {
      return 'Berakhir dalam';
    } else {
      return 'Flash Sale';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: widget.schedule.isEnded 
          ? null 
          : LinearGradient(
              colors: [_getTimerColor(), _getTimerColor().withOpacity(0.8)],
            ),
        color: widget.schedule.isEnded ? Colors.grey[300] : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: widget.schedule.isEnded ? null : [
          BoxShadow(
            color: _getTimerColor().withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTimerIcon(),
            color: widget.schedule.isEnded ? Colors.grey[600] : Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getStatusLabel(),
                style: TextStyle(
                  color: widget.schedule.isEnded ? Colors.grey[600] : Colors.white.withOpacity(0.9),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _getTimerText(),
                style: TextStyle(
                  color: widget.schedule.isEnded ? Colors.grey[700] : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}