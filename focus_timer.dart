import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  int focusDuration = 25 * 60; // 25 minutes
  int breakDuration = 5 * 60;  // 5 minutes
  int remainingTime = 25 * 60;

  bool isFocusMode = true;
  bool isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Memuat pengaturan dari SharedPreferences
  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      focusDuration = prefs.getInt('focusDuration') ?? 25 * 60; // Default 25 minutes
      breakDuration = prefs.getInt('breakDuration') ?? 5 * 60; // Default 5 minutes
      remainingTime = isFocusMode ? focusDuration : breakDuration;
    });
  }

  // Menyimpan pengaturan ke SharedPreferences
  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('focusDuration', focusDuration);
    prefs.setInt('breakDuration', breakDuration);
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          isRunning = false;
        });
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(isFocusMode ? "Sesi Fokus Selesai" : "Istirahat Selesai"),
            content: Text(isFocusMode
                ? "Saatnya istirahat sejenak!"
                : "Waktunya kembali fokus!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  switchMode();
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    });

    setState(() {
      isRunning = true;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      remainingTime = isFocusMode ? focusDuration : breakDuration;
    });
  }

  void switchMode() {
    setState(() {
      isFocusMode = !isFocusMode;
      remainingTime = isFocusMode ? focusDuration : breakDuration;
    });
  }

  String formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void openSettingsDialog() {
    final focusController = TextEditingController(text: (focusDuration ~/ 60).toString());
    final breakController = TextEditingController(text: (breakDuration ~/ 60).toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Timer Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: focusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Focus Duration (minutes)"),
            ),
            TextField(
              controller: breakController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Break Duration (minutes)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                focusDuration = int.tryParse(focusController.text) != null
                    ? int.parse(focusController.text) * 60
                    : focusDuration;
                breakDuration = int.tryParse(breakController.text) != null
                    ? int.parse(breakController.text) * 60
                    : breakDuration;
                remainingTime = isFocusMode ? focusDuration : breakDuration;
              });
              _saveSettings(); // Simpan pengaturan setelah diubah
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTime = isFocusMode ? focusDuration : breakDuration;
    final progress = 1 - (remainingTime / totalTime);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(  // Tombol back di kiri
          icon: const Icon(Icons.arrow_back), color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          isFocusMode ? "Pomodoro" : "Istirahat",
          style: const TextStyle( 
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isFocusMode ? Colors.redAccent : Colors.lightGreenAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: openSettingsDialog,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: 1 - progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(isFocusMode ? Colors.redAccent : Colors.lightGreenAccent),
                  ),
                ),
                Text(
                  formatTime(remainingTime),
                  style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 40),
            isRunning
                ? ElevatedButton.icon(
                    onPressed: stopTimer,
                    icon: const Icon(Icons.pause, size: 25),
                    label: const Text("Pause", style: TextStyle(fontSize: 25)),
                  )
                : ElevatedButton.icon(
                    onPressed: startTimer,
                    icon: const Icon(Icons.play_arrow, size: 25),
                    label: const Text("Start", style: TextStyle(fontSize: 25)),
                  ),
            TextButton(
              onPressed: resetTimer,
              child: const Text("Reset", style: TextStyle(fontSize: 25)),
            ),
          ],
        ),
      ),
    );
  }
}
