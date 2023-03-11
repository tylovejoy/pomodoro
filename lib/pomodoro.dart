enum PomodoroMode {
  work,
  rest,
  longRest,
}

class Pomodoro {
  late int _workTime;
  late int _breakTime;
  late int _longBreakTime;
  late int _workTimeSeconds;
  late int _breakTimeSeconds;
  late int _longBreakTimeSeconds;
  late int _intervals;

  late int _intervalsLeft;
  late PomodoroMode _currentMode;

  Pomodoro(int workTime, int breakTime, int longBreakTime, int intervals) {
    _workTime = workTime;
    _breakTime = breakTime;
    _longBreakTime = longBreakTime;

    _workTimeSeconds = _convertMinutesToSeconds(workTime);
    _breakTimeSeconds = _convertMinutesToSeconds(breakTime);
    _longBreakTimeSeconds = _convertMinutesToSeconds(longBreakTime);
    _intervals = intervals;
    _intervalsLeft = intervals;
    _currentMode = PomodoroMode.work;
  }

  Pomodoro.base() {
    _workTime = 2;
    _breakTime = 1;
    _longBreakTime = 3;
    _workTimeSeconds = _convertMinutesToSeconds(_workTime);
    _breakTimeSeconds = _convertMinutesToSeconds(_breakTime);
    _longBreakTimeSeconds = _convertMinutesToSeconds(_longBreakTime);
    _intervals = 4;
    _intervalsLeft = _intervals;
    _currentMode = PomodoroMode.work;
  }

  int getWorkTimeSeconds() {
    return _workTimeSeconds;
  }

  int getWorkTime() {
    return _workTime;
  }

  void setWorkTime(int workTime) {
    _workTime = workTime;
    _workTimeSeconds = _convertMinutesToSeconds(workTime);
  }

  int getBreakTimeSeconds() {
    return _breakTimeSeconds;
  }

  int getBreakTime() {
    return _breakTime;
  }

  void setBreakTime(int breakTime) {
    _breakTime = breakTime;
    _breakTimeSeconds = _convertMinutesToSeconds(breakTime);
  }

  int getLongBreakTimeSeconds() {
    return _longBreakTimeSeconds;
  }

  int getLongBreakTime() {
    return _longBreakTime;
  }

  void setLongBreakTime(int longBreakTime) {
    _longBreakTime = longBreakTime;
    _longBreakTimeSeconds = _convertMinutesToSeconds(longBreakTime);
  }

  int getIntervals() {
    return _intervals;
  }

  void setIntervals(int intervals) {
    _intervals = intervals;
  }

  int getIntervalsLeft() {
    return _intervalsLeft;
  }

  void decrementIntervalsLeft() {
    _intervalsLeft--;
  }

  void resetIntervalsLeft() {
    _intervalsLeft = _intervals;
  }

  int _convertMinutesToSeconds(int minutes) {
    return minutes * 60;
  }

  String convertSecondsToMinuteStr(int seconds_) {
    int minutes = seconds_ ~/ 60;
    int seconds = seconds_ % 60;

    return '${_padNumber(minutes)}:${_padNumber(seconds)}';
  }

  String _padNumber(int number) {
    String pad = '';
    if (number < 10) {
      pad += '0';
    }
    return '$pad$number';
  }

  void modeChange() {
    if (_currentMode == PomodoroMode.work) {
      if (getIntervalsLeft() > 1) {
        decrementIntervalsLeft();
        _currentMode = PomodoroMode.rest;
      } else {
        resetIntervalsLeft();
        _currentMode = PomodoroMode.longRest;
      }
    } else {
      _currentMode = PomodoroMode.work;
    }
  }

  Function getFuncForMode() {
    if (_currentMode == PomodoroMode.work) return getWorkTimeSeconds;
    if (_currentMode == PomodoroMode.rest) return getBreakTimeSeconds;
    if (_currentMode == PomodoroMode.longRest) return getLongBreakTimeSeconds;
    return getWorkTimeSeconds;
  }
}
