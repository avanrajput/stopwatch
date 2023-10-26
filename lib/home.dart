import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool isRunning = false;
  List<StopWatchRecord> lapTimes = [];

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  void startStopTimer() {
    if (isRunning) {
      _stopWatchTimer.onStopTimer();
    } else {
      _stopWatchTimer.onStartTimer();
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  void resetTimer() {
    _stopWatchTimer.onResetTimer();
    setState(() {
      isRunning = false;
      lapTimes.clear();
    });
  }

  void lapTimer() {
    _stopWatchTimer.onAddLap();
    setState(() {
      _stopWatchTimer.records.listen((event) {
        lapTimes = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isRunning ? Colors.red : Colors.blue,
                    width: 4,
                  ),
                  //borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: StreamBuilder<int>(
                    stream: _stopWatchTimer.rawTime,
                    initialData: 0,
                    builder: (context, snap) {
                      final value = snap.data;
                      final displayTime = StopWatchTimer.getDisplayTime(value!);
                      return Text(
                        displayTime,
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: isRunning ? Colors.red : Colors.blue),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: resetTimer,
                    backgroundColor: Colors.grey.shade800,
                    child:
                        const Icon(Icons.refresh, size: 32, color: Colors.cyan),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: startStopTimer,
                    backgroundColor: isRunning ? Colors.red : Colors.blue,
                    child: Icon(
                      isRunning ? Icons.stop : Icons.play_arrow,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: isRunning ? lapTimer : null,
                    backgroundColor: Colors.grey.shade800,
                    child: const Icon(Icons.flag, size: 32, color: Colors.cyan),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              if (lapTimes.isNotEmpty)
                DataTable(
                  columns: const [
                    DataColumn(
                        label: Text(
                      'Lap',
                      style: TextStyle(color: Colors.cyan),
                    )),
                    DataColumn(
                        label: Text(
                      'Lap Time',
                      style: TextStyle(color: Colors.cyan),
                    )),
                    DataColumn(
                        label: Text(
                      'Total',
                      style: TextStyle(color: Colors.cyan),
                    )),
                  ],
                  rows: lapTimes.asMap().entries.map((entry) {
                    final int currentLapTime = entry.value.rawValue!;
                    final int previousLapTime = entry.key > 0
                        ? int.parse(lapTimes[entry.key - 1].rawValue.toString())
                        : 0;
                    final lapTime = StopWatchTimer.getDisplayTime(
                        currentLapTime - previousLapTime);

                    return DataRow(
                      cells: [
                        DataCell(Text(
                          (entry.key + 1).toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                        DataCell(Text(
                          lapTime.toString(),
                          style: const TextStyle(color: Colors.red),
                        )),
                        DataCell(Text(
                          entry.value.displayTime!,
                          style: const TextStyle(color: Colors.blue),
                        )),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
