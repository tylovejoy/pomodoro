import 'dart:async';
import 'package:pomodoro/pomodoro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

Pomodoro pomodoro = Pomodoro.base();
AudioPlayer player = AudioPlayer();
bool isPaused = false;
bool isStarted = false;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const HomePage(title: 'Pomodoro'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(Object context) {
    return const NavMenu(menuItems: [
      TimerField(),
      SettingsPage(),
      AboutPage(),
    ]);
  }
}

class NavMenu extends StatefulWidget {
  const NavMenu({super.key, required this.menuItems});
  final List<Widget> menuItems;

  @override
  State<NavMenu> createState() => _NavMenuState();
}

class _NavMenuState extends State<NavMenu> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pomodoro")),
      body: Center(
        child: widget.menuItems[_currentPage],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Image(image: AssetImage('assets/tomato.png')),
            ),
            ListTile(
              title: const Text('Timer'),
              onTap: () {
                setState(() {
                  _currentPage = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                setState(() {
                  _currentPage = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                setState(() {
                  _currentPage = 2;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TimerField extends StatefulWidget {
  const TimerField({super.key});

  @override
  State<StatefulWidget> createState() => _TimerField();
}

class _TimerField extends State<TimerField> {
  late int _timeLeft;
  late bool _isPaused;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = pomodoro.getWorkTimeSeconds();
    _isPaused = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntervalCount(
          intervals: pomodoro.getIntervals(),
          curInterval: pomodoro.getIntervals() - pomodoro.getIntervalsLeft(),
        ),
        Container(
          padding: const EdgeInsetsDirectional.all(50),
          child: Text(
            pomodoro.convertSecondsToMinuteStr(_timeLeft),
            style: const TextStyle(fontSize: 50),
          ),
        ),
        TimerButton(
          startCallback: startTimer,
          pauseCallback: pauseTimer,
          resetCallback: resetTimer,
          fullResetCallback: fullResetTimer,
        )
      ],
    );
  }

  void startTimer() {
    if (_timeLeft < pomodoro.getFuncForMode()() || timer?.isActive == true) {
      return;
    }
    Timer.periodic(const Duration(milliseconds: 1), (timer) {
      this.timer = timer;

      if (!_isPaused) {
        setState(() {
          _timeLeft--;
        });
      }

      if (_timeLeft == 0) {
        isPaused = false;
        isStarted = false;
        playAlarm();
        timer.cancel();
        pomodoro.modeChange();
        setState(() {
          _timeLeft = pomodoro.getFuncForMode()();
        });
      }
    });
  }

  void playAlarm() {
    () async {
      await player.play(AssetSource('audio/alarm.wav'));
    }();
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      _timeLeft = pomodoro.getFuncForMode()();
    });
    timer = null;
  }

  void pauseTimer() {
    _isPaused = !_isPaused;
  }

  void fullResetTimer() {
    resetTimer();
    pomodoro.reset();
  }
}

class TimerButton extends StatefulWidget {
  const TimerButton(
      {super.key,
      required this.startCallback,
      required this.resetCallback,
      required this.pauseCallback,
      required this.fullResetCallback});
  final VoidCallback startCallback;
  final VoidCallback pauseCallback;
  final VoidCallback resetCallback;
  final VoidCallback fullResetCallback;
  @override
  State<StatefulWidget> createState() => _TimerButton();
}

class _TimerButton extends State<TimerButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const SizedBox(width: 1),
        Row(
          children: [
            ElevatedButton(
                onPressed: !isStarted
                    ? () {
                        setState(() {
                          isStarted = !isStarted;
                          widget.startCallback();
                        });
                      }
                    : null,
                child: const Text("START")),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: isStarted
                  ? () {
                      setState(() {
                        isPaused = !isPaused;
                        widget.pauseCallback();
                      });
                    }
                  : null,
              child: Text(isPaused ? 'RESUME' : 'PAUSE'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    isPaused = false;
                    isStarted = false;
                    widget.resetCallback();
                  });
                },
                child: const Text('RESET')),
            const SizedBox(width: 10),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    isPaused = false;
                    isStarted = false;
                    widget.fullResetCallback();
                  });
                },
                child: const Text('FULL RESET'))
          ],
        ),
        const SizedBox(width: 1)
      ],
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Made by Ty Lovejoy');
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _volume = 1;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('Work'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                  width: 50,
                  child: TextField(
                      textAlign: TextAlign.center,
                      onChanged: (value) => pomodoro
                          .setWorkTime(value == '' ? 0 : int.parse(value)),
                      controller: TextEditingController(
                          text: pomodoro.getWorkTime().toString()),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ])),
              const SizedBox(
                width: 40,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('Rest'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                  width: 50,
                  child: TextField(
                      textAlign: TextAlign.center,
                      onChanged: (value) => pomodoro
                          .setBreakTime(value == '' ? 0 : int.parse(value)),
                      controller: TextEditingController(
                          text: pomodoro.getBreakTime().toString()),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ])),
              const SizedBox(
                width: 40,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('Long Rest'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                  width: 50,
                  child: TextField(
                      textAlign: TextAlign.center,
                      onChanged: (value) => pomodoro
                          .setLongBreakTime(value == '' ? 0 : int.parse(value)),
                      controller: TextEditingController(
                          text: pomodoro.getLongBreakTime().toString()),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ])),
              const SizedBox(
                width: 40,
              ),
            ],
          ),
          const SizedBox(),
          const Text('Volume'),
          SizedBox(
            width: 200,
            child: Slider(
                value: _volume,
                onChanged: (value) async {
                  await player.setVolume(value);
                  setState(() {
                    _volume = value;
                  });
                }),
          )
        ],
      ),
    );
  }
}

class IntervalCount extends StatefulWidget {
  const IntervalCount(
      {super.key, required this.intervals, required this.curInterval});
  final int intervals;
  final int curInterval;
  @override
  State<IntervalCount> createState() => _IntervalCountState();
}

class _IntervalCountState extends State<IntervalCount> {
  @override
  Widget build(BuildContext context) {
    List<Widget> circles = [];

    for (var i = 0; i < widget.intervals; i++) {
      circles.add(Icon(
        widget.curInterval > i ? Icons.lens : Icons.trip_origin,
      ));
    }

    return Column(
      children: [
        Text("Round ${widget.curInterval} / ${widget.intervals}"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: circles,
        ),
      ],
    );
  }
}
