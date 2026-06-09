import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const DateTimeCheckerApp());
}

class DateTimeCheckerApp extends StatelessWidget {
  const DateTimeCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Time Checker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Arial'),
      home: const DateTimeCheckerPage(),
    );
  }
}

class HistoryItem {
  final String date;
  final bool isValid;
  final String time;

  HistoryItem({
    required this.date,
    required this.isValid,
    required this.time,
  });
}

class AutoTestCase {
  final String id;
  final int day;
  final int month;
  final int year;
  final bool expectedValid;
  final bool wrongExpected;
  bool? actualValid;
  bool? passed;

  AutoTestCase({
    required this.id,
    required this.day,
    required this.month,
    required this.year,
    required this.expectedValid,
    this.wrongExpected = false,
    this.actualValid,
    this.passed,
  });
}

class DateTimeCheckerPage extends StatefulWidget {
  const DateTimeCheckerPage({super.key});

  @override
  State<DateTimeCheckerPage> createState() => _DateTimeCheckerPageState();
}

class _DateTimeCheckerPageState extends State<DateTimeCheckerPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Random random = Random();

  int selectedTab = 0;

  int selectedDay = 31;
  int selectedMonth = 4;
  int selectedYear = 2024;

  final dayController = TextEditingController(text: '31');
  final monthController = TextEditingController(text: '04');
  final yearController = TextEditingController(text: '2024');

  bool? isValid;
  String resultDate = '';
  String resultMessage = '';
  String dayOfWeek = '-';
  int daysOfMonth = 0;
  bool leapYear = false;

  final List<HistoryItem> history = [];
  List<AutoTestCase> autoTests = [];

  List<List<int>> leapExamples = [];
  List<List<int>> invalidExamples = [];

  @override
  void initState() {
    super.initState();
    autoTests = generateAutoTests();
    leapExamples = generateLeapExamples();
    invalidExamples = generateInvalidExamples();
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.dispose();
  }

  bool isLeapYear(int year) {
    return year % 400 == 0 || (year % 4 == 0 && year % 100 != 0);
  }

  int daysInMonth(int month, int year) {
    if ([1, 3, 5, 7, 8, 10, 12].contains(month)) return 31;
    if ([4, 6, 9, 11].contains(month)) return 30;
    if (month == 2) return isLeapYear(year) ? 29 : 28;
    return 0;
  }

  bool checkDateLogic(int day, int month, int year) {
    if (day < 1 || day > 31) return false;
    if (month < 1 || month > 12) return false;
    if (year < 1920 || year > 3000) return false;
    return day <= daysInMonth(month, year);
  }

  String formatDate(int day, int month, int year) {
    return '${day.toString().padLeft(2, '0')}/'
        '${month.toString().padLeft(2, '0')}/'
        '$year';
  }

  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  String getDayOfWeek(int day, int month, int year) {
    final date = DateTime(year, month, day);
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  void setInputDate(int day, int month, int year) {
    setState(() {
      selectedDay = day;
      selectedMonth = month;
      selectedYear = year;

      dayController.text = day.toString().padLeft(2, '0');
      monthController.text = month.toString().padLeft(2, '0');
      yearController.text = year.toString();

      isValid = null;
      resultDate = '';
      resultMessage = '';
      dayOfWeek = '-';
      daysOfMonth = 0;
      leapYear = false;
    });
  }

  void setToday() {
    final now = DateTime.now();
    final safeYear = now.year.clamp(1920, 3000);
    setInputDate(now.day, now.month, safeYear);
  }

  void setRandomDate() {
    final year = 1920 + random.nextInt(1081);
    final month = 1 + random.nextInt(12);
    final day = 1 + random.nextInt(daysInMonth(month, year));
    setInputDate(day, month, year);
  }

  List<List<int>> generateLeapExamples() {
    final r = Random(DateTime.now().microsecondsSinceEpoch);

    final leapYears = <int>[
      1920,
      1924,
      1944,
      1960,
      1984,
      1996,
      2000,
      2004,
      2012,
      2020,
      2024,
      2040,
      2080,
      2400,
      2800,
      3000,
    ];

    final nonLeapYears = <int>[
      1921,
      1930,
      1977,
      1999,
      2023,
      2025,
      2100,
      2200,
      2300,
      2500,
      2900,
    ];

    leapYears.shuffle(r);
    nonLeapYears.shuffle(r);

    final result = <List<int>>[];
    final used = <String>{};

    void addUnique(int day, int month, int year) {
      final key = '$day-$month-$year';
      if (used.add(key)) result.add([day, month, year]);
    }

    // Only 2 leap-day cases: 1 valid and 1 invalid.
    addUnique(29, 2, leapYears[0]);
    addUnique(29, 2, nonLeapYears[0]);

    // The rest must use different days/months so reset looks diverse.
    final normalCases = <List<int>>[
      [15 + r.nextInt(10), 1, leapYears[1]],   // valid
      [1 + r.nextInt(28), 3, leapYears[2]],    // valid
      [10 + r.nextInt(15), 7, leapYears[3]],   // valid
      [5 + r.nextInt(20), 12, leapYears[4]],   // valid
      [31, 4, leapYears[5]],                   // invalid
      [31, 6, leapYears[6]],                   // invalid
      [30, 2, nonLeapYears[1]],                // invalid
      [10, 13, leapYears[7]],                  // invalid
    ];

    normalCases.shuffle(r);

    for (final item in normalCases.take(6)) {
      addUnique(item[0], item[1], item[2]);
    }

    result.shuffle(r);
    return result;
  }

  List<List<int>> generateInvalidExamples() {
    final r = Random(DateTime.now().microsecondsSinceEpoch);
    final result = <List<int>>[];
    final used = <String>{};

    void addUnique(int day, int month, int year) {
      final key = '$day-$month-$year';
      if (used.add(key)) result.add([day, month, year]);
    }

    final fixedCases = <List<int>>[
      [31, 4, 2024],
      [30, 2, 2024],
      [29, 2, 2023],
      [32, 1, 2024],
      [10, 13, 2024],
      [10, 12, 1919],
      [10, 12, 3001],
      [31, 6, 2025],
      [31, 11, 2026],
      [0, 5, 2024],
      [15, 0, 2024],
    ];

    fixedCases.shuffle(r);

    for (final item in fixedCases.take(3)) {
      addUnique(item[0], item[1], item[2]);
    }

    while (result.length < 7) {
      final year = 1920 + r.nextInt(1081);
      final month = 1 + r.nextInt(12);
      final maxDay = daysInMonth(month, year);
      final type = r.nextInt(5);

      if (type == 0) {
        addUnique(maxDay + 1, month, year);
      } else if (type == 1) {
        addUnique(32, month, year);
      } else if (type == 2) {
        addUnique(10, 13, year);
      } else if (type == 3) {
        addUnique(10, month, r.nextBool() ? 1919 : 3001);
      } else {
        addUnique(29, 2, isLeapYear(year) ? 2023 : year);
      }
    }

    result.shuffle(r);
    return result;
  }

  List<AutoTestCase> generateAutoTests() {
    final r = Random(DateTime.now().microsecondsSinceEpoch);
    final used = <String>{};
    final selected = <List<int>>[];

    void addUnique(int day, int month, int year) {
      final key = '$day-$month-$year';
      if (used.add(key)) selected.add([day, month, year]);
    }

    final importantCases = <List<int>>[
      [29, 2, 2024],
      [29, 2, 2023],
      [29, 2, 2000],
      [29, 2, 2100],
      [31, 4, 2024],
      [30, 4, 2024],
      [31, 12, 3000],
      [1, 1, 1920],
      [10, 12, 1919],
      [10, 12, 3001],
      [32, 1, 2024],
      [0, 6, 2024],
      [15, 13, 2024],
      [31, 6, 2025],
      [28, 2, 2023],
      [31, 1, 2024],
      [30, 11, 2025],
      [29, 2, 2400],
    ];

    importantCases.shuffle(r);

    for (final item in importantCases.take(7)) {
      addUnique(item[0], item[1], item[2]);
    }

    final totalCases = 10 + r.nextInt(5);

    while (selected.length < totalCases) {
      final year = 1920 + r.nextInt(1081);
      final month = 1 + r.nextInt(12);
      final maxDay = daysInMonth(month, year);

      if (r.nextBool()) {
        addUnique(1 + r.nextInt(maxDay), month, year);
      } else {
        final invalidType = r.nextInt(4);

        if (invalidType == 0) {
          addUnique(maxDay + 1, month, year);
        } else if (invalidType == 1) {
          addUnique(32, month, year);
        } else if (invalidType == 2) {
          addUnique(10, 13, year);
        } else {
          addUnique(10, month, r.nextBool() ? 1919 : 3001);
        }
      }
    }

    selected.shuffle(r);

    final failCount = 1 + r.nextInt(min(5, totalCases));
    final wrongExpectedIndexes = <int>{};

    while (wrongExpectedIndexes.length < failCount) {
      wrongExpectedIndexes.add(r.nextInt(totalCases));
    }

    return List.generate(totalCases, (index) {
      final item = selected[index];
      final actual = checkDateLogic(item[0], item[1], item[2]);
      final wrongExpected = wrongExpectedIndexes.contains(index);

      return AutoTestCase(
        id: 'TC-${(index + 1).toString().padLeft(2, '0')}',
        day: item[0],
        month: item[1],
        year: item[2],
        expectedValid: wrongExpected ? !actual : actual,
        wrongExpected: wrongExpected,
      );
    });
  }

  void clearInput() {
    setState(() {
      selectedDay = 1;
      selectedMonth = 1;
      selectedYear = 2024;

      dayController.text = '01';
      monthController.text = '01';
      yearController.text = '2024';

      isValid = null;
      resultDate = '';
      resultMessage = '';
      dayOfWeek = '-';
      daysOfMonth = 0;
      leapYear = false;
    });
  }

  void checkDate() {
    final day = int.tryParse(dayController.text.trim());
    final month = int.tryParse(monthController.text.trim());
    final year = int.tryParse(yearController.text.trim());

    if (day == null) return showError('Input data for Day is incorrect format!');
    if (day < 1 || day > 31) return showError('Input data for Day is out of range!');
    if (month == null) return showError('Input data for Month is incorrect format!');
    if (month < 1 || month > 12) return showError('Input data for Month is out of range!');
    if (year == null) return showError('Input data for Year is incorrect format!');
    if (year < 1920 || year > 3000) return showError('Input data for Year is out of range!');

    final valid = checkDateLogic(day, month, year);
    final date = formatDate(day, month, year);

    setState(() {
      selectedDay = day;
      selectedMonth = month;
      selectedYear = year;

      isValid = valid;
      resultDate = date;
      resultMessage = valid
          ? 'This is a correct and valid date.'
          : 'This date is not correct.';

      daysOfMonth = daysInMonth(month, year);
      leapYear = isLeapYear(year);
      dayOfWeek = valid ? getDayOfWeek(day, month, year) : '-';

      history.insert(
        0,
        HistoryItem(
          date: date,
          isValid: valid,
          time: formatTime(DateTime.now()),
        ),
      );
    });
  }

  void showError(String message) {
    setState(() {
      isValid = false;
      resultDate = '';
      resultMessage = message;
      dayOfWeek = '-';
      daysOfMonth = 0;
      leapYear = false;
    });
  }

  void runAutoTest() {
    setState(() {
      for (final testCase in autoTests) {
        final actual = checkDateLogic(testCase.day, testCase.month, testCase.year);
        testCase.actualValid = actual;
        testCase.passed = actual == testCase.expectedValid;
      }
    });
  }

  void resetAutoTest() {
    setState(() {
      autoTests = generateAutoTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xffF8FAFC),
      drawer: appDrawer(),
      body: Center(
        child: SizedBox(
          width: 430,
          child: Stack(
            children: [
              IndexedStack(
                index: selectedTab,
                children: [
                  checkerPage(),
                  historyPage(),
                  autoTestPage(),
                  aboutPage(),
                ],
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: bottomBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appDrawer() {
    return Drawer(
      backgroundColor: const Color(0xffF8FAFC),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff7C3AED), Color(0xff0EA5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 30),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Quick Tools',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            drawerItem(
              icon: Icons.today_rounded,
              title: 'Today',
              subtitle: 'Fill today date automatically',
              color: const Color(0xff2563EB),
              onTap: () {
                Navigator.pop(context);
                setToday();
              },
            ),
            drawerItem(
              icon: Icons.casino_rounded,
              title: 'Random Date',
              subtitle: 'Generate a random valid date',
              color: const Color(0xff7C3AED),
              onTap: () {
                Navigator.pop(context);
                setRandomDate();
              },
            ),
            drawerItem(
              icon: Icons.star_rounded,
              title: 'Leap Year Examples',
              subtitle: 'Choose leap and non-leap year cases',
              color: const Color(0xff16A34A),
              onTap: () {
                Navigator.pop(context);
                showExampleSheet(
                  title: 'Leap Year Examples',
                  isLeapExample: true,
                );
              },
            ),
            drawerItem(
              icon: Icons.warning_rounded,
              title: 'Invalid Date Examples',
              subtitle: 'Choose common invalid dates',
              color: const Color(0xffDC2626),
              onTap: () {
                Navigator.pop(context);
                showExampleSheet(
                  title: 'Invalid Date Examples',
                  isLeapExample: false,
                );
              },
            ),
            drawerItem(
              icon: Icons.cleaning_services_rounded,
              title: 'Clear Input',
              subtitle: 'Clear date and result',
              color: const Color(0xffF97316),
              onTap: () {
                Navigator.pop(context);
                clearInput();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: whiteCardDecoration(),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xff101828),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xff667085),
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xff98A2B3)),
      ),
    );
  }

  void showExampleSheet({
    required String title,
    required bool isLeapExample,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<List<int>> currentExamples() {
              return isLeapExample ? leapExamples : invalidExamples;
            }

            void resetExamples() {
              final newExamples = isLeapExample
                  ? generateLeapExamples()
                  : generateInvalidExamples();

              setState(() {
                if (isLeapExample) {
                  leapExamples = newExamples;
                } else {
                  invalidExamples = newExamples;
                }
              });

              setModalState(() {});
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.82,
              minChildSize: 0.45,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                final examples = currentExamples();

                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xffD0D5DD),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const SizedBox(width: 46),
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                color: Color(0xff101828),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xffFEF2F2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Color(0xffDC2626),
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: resetExamples,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xffC084FC), Color(0xff7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shuffle_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'RESET EXAMPLES',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Tap RESET to generate new non-duplicate day / month / year examples.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff667085),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: examples.length,
                          itemBuilder: (context, index) {
                            final date = examples[index];
                            final day = date[0];
                            final month = date[1];
                            final year = date[2];
                            final valid = checkDateLogic(day, month, year);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  Navigator.pop(context);
                                  setInputDate(day, month, year);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: valid
                                        ? const Color(0xffF0FDF4)
                                        : const Color(0xffFEF2F2),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: valid
                                          ? const Color(0xffBBF7D0)
                                          : const Color(0xffFECACA),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        valid
                                            ? Icons.check_circle_rounded
                                            : Icons.cancel_rounded,
                                        color: valid
                                            ? const Color(0xff16A34A)
                                            : const Color(0xffDC2626),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          formatDate(day, month, year),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xff101828),
                                          ),
                                        ),
                                      ),
                                      resultWord(valid),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget checkerPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 105),
      child: Column(
        children: [
          header(),
          Transform.translate(
            offset: const Offset(0, -42),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  inputCard(),
                  const SizedBox(height: 20),
                  if (isValid != null) resultCard(),
                  const SizedBox(height: 20),
                  tipCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget historyPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 46, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeader(
            title: 'Check History',
            subtitle: 'Your recent date checking records',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 22),
          if (history.isEmpty)
            emptyCard(
              icon: Icons.history_rounded,
              title: 'No history yet',
              subtitle: 'Go to Checker and press Check Date to save a record.',
            )
          else
            Column(
              children: history.map((item) {
                final color = item.isValid ? const Color(0xff16A34A) : const Color(0xffDC2626);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: whiteCardDecoration(),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: color.withOpacity(0.12),
                        child: Icon(
                          item.isValid ? Icons.check_rounded : Icons.close_rounded,
                          color: color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.date,
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.isValid ? 'Valid date' : 'Invalid date',
                              style: const TextStyle(
                                color: Color(0xff667085),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item.time,
                        style: const TextStyle(
                          color: Color(0xff98A2B3),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          if (history.isNotEmpty)
            InkWell(
              onTap: () {
                setState(() => history.clear());
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xffFEF2F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xffFECACA)),
                ),
                child: const Center(
                  child: Text(
                    'Clear History',
                    style: TextStyle(
                      color: Color(0xffDC2626),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget autoTestPage() {
    final passedCount = autoTests.where((test) => test.passed == true).length;
    final failedCount = autoTests.where((test) => test.passed == false).length;
    final testedCount = autoTests.where((test) => test.passed != null).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 46, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeader(
            title: 'Auto Test',
            subtitle: 'Random, non-duplicate test cases',
            icon: Icons.science_rounded,
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: whiteCardDecoration(),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: autoSummaryItem(
                        title: 'Total',
                        value: '${autoTests.length}',
                        color: const Color(0xff2563EB),
                        icon: Icons.list_alt_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: autoSummaryItem(
                        title: 'Passed',
                        value: '$passedCount',
                        color: const Color(0xff16A34A),
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: autoSummaryItem(
                        title: 'Failed',
                        value: '$failedCount',
                        color: const Color(0xffDC2626),
                        icon: Icons.cancel_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    gradientButton(
                      text: 'RUN TEST',
                      icon: Icons.play_arrow_rounded,
                      colors: const [Color(0xff22C55E), Color(0xff16A34A)],
                      onTap: runAutoTest,
                    ),
                    const SizedBox(width: 12),
                    gradientButton(
                      text: 'RESET',
                      icon: Icons.shuffle_rounded,
                      colors: const [Color(0xffFB923C), Color(0xffEC4899)],
                      onTap: resetAutoTest,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            testedCount == 0
                ? 'Test cases are ready to run'
                : 'Executed $testedCount/${autoTests.length} test cases',
            style: const TextStyle(
              color: Color(0xff475467),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: autoTests.map(testCaseCard).toList(),
          ),
        ],
      ),
    );
  }

  Widget testCaseCard(AutoTestCase testCase) {
    final passed = testCase.passed;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (passed == null) {
      statusColor = const Color(0xff667085);
      statusText = 'UNTESTED';
      statusIcon = Icons.radio_button_unchecked_rounded;
    } else if (passed) {
      statusColor = const Color(0xff16A34A);
      statusText = 'PASS';
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = const Color(0xffDC2626);
      statusText = 'FAIL';
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: statusColor.withOpacity(0.12),
            child: Icon(statusIcon, color: statusColor, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${testCase.id} - ${formatDate(testCase.day, testCase.month, testCase.year)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff101828),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Expected:',
                      style: TextStyle(color: Color(0xff667085), fontSize: 14),
                    ),
                    resultWord(testCase.expectedValid),
                    if (testCase.actualValid != null)
                      const Text(
                        '| Actual:',
                        style: TextStyle(
                          color: Color(0xff667085),
                          fontSize: 14,
                        ),
                      ),
                    if (testCase.actualValid != null)
                      resultWord(testCase.actualValid == true),
                    if (testCase.wrongExpected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffFB923C).withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Wrong Expected',
                          style: TextStyle(
                            color: Color(0xffEA580C),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget aboutPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 46, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeader(
            title: 'About App',
            subtitle: 'Date Time Checker mobile application',
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 22),
          aboutCard(
            icon: Icons.mobile_friendly_rounded,
            title: 'Topic',
            content: 'Mobile Date Time Checker app built with Flutter.',
          ),
          aboutCard(
            icon: Icons.rule_rounded,
            title: 'Validation Rules',
            content: 'Day must be 1–31.\nMonth must be 1–12.\nYear must be 1920–3000.',
          ),
          aboutCard(
            icon: Icons.menu_rounded,
            title: 'Quick Tools Menu',
            content: 'The menu provides Today, Random Date, Leap Year Examples and Invalid Date Examples.',
          ),
          aboutCard(
            icon: Icons.science_rounded,
            title: 'Auto Test',
            content: 'Auto Test randomly generates non-duplicate test cases and random PASS/FAIL results.',
          ),
          aboutCard(
            icon: Icons.star_rounded,
            title: 'Leap Year Rule',
            content: 'A leap year is divisible by 400, or divisible by 4 but not divisible by 100.',
          ),
          aboutCard(
            icon: Icons.person_rounded,
            title: 'Creator',
            content: 'Nguyen Minh Quy',
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      height: 365,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 46, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff7C3AED), Color(0xff0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(42),
          bottomRight: Radius.circular(42),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => scaffoldKey.currentState?.openDrawer(),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.menu_rounded, color: Colors.white, size: 34),
              ),
            ),
          ),
          const Positioned(
            top: 6,
            right: 0,
            child: Icon(Icons.access_time, color: Colors.white, size: 32),
          ),
          const Positioned(
            left: 0,
            top: 84,
            child: Text(
              'Date Time\nChecker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                height: 1.25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Positioned(
            left: 0,
            top: 213,
            child: Text(
              'Enter a date to check if it is valid',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Positioned(right: 30, top: 58, child: calendarIcon()),
          Positioned(right: 2, top: 144, child: clockIcon()),
          const Positioned(
            right: 158,
            top: 24,
            child: Text('⭐', style: TextStyle(fontSize: 20)),
          ),
          const Positioned(
            right: 12,
            top: 82,
            child: Text('⭐', style: TextStyle(fontSize: 28)),
          ),
        ],
      ),
    );
  }

  Widget calendarIcon() {
    return Container(
      width: 132,
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xffFB4268),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 24,
            right: 20,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                9,
                (index) => Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: index == 3 ? const Color(0xffF43F5E) : const Color(0xff93C5FD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget clockIcon() {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xff7C3AED), width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.schedule, color: Color(0xff7C3AED), size: 40),
      ),
    );
  }

  Widget inputCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
      decoration: whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: Color(0xff7C3AED)),
              SizedBox(width: 10),
              Text(
                'Enter Date',
                style: TextStyle(
                  color: Color(0xff7C3AED),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          dateSelector(
            title: 'Day',
            value: selectedDay,
            values: List.generate(31, (index) => index + 1),
            color: const Color(0xffF43F5E),
            controller: dayController,
            onSelected: (value) => selectedDay = value,
          ),
          const SizedBox(height: 16),
          dateSelector(
            title: 'Month',
            value: selectedMonth,
            values: List.generate(12, (index) => index + 1),
            color: const Color(0xff7C3AED),
            controller: monthController,
            onSelected: (value) => selectedMonth = value,
          ),
          const SizedBox(height: 16),
          dateSelector(
            title: 'Year',
            value: selectedYear,
            values: List.generate(1081, (index) => 1920 + index),
            color: const Color(0xff16A34A),
            controller: yearController,
            onSelected: (value) => selectedYear = value,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap the arrow to select quickly, or type manually. Year must be between 1920 and 3000.',
            style: TextStyle(
              color: Color(0xff667085),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              gradientButton(
                text: 'CLEAR',
                icon: Icons.refresh,
                colors: const [Color(0xffFB923C), Color(0xffEC4899)],
                onTap: clearInput,
              ),
              const SizedBox(width: 12),
              gradientButton(
                text: 'CHECK DATE',
                icon: Icons.search,
                colors: const [Color(0xffC084FC), Color(0xff4F46E5)],
                onTap: checkDate,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget dateSelector({
    required String title,
    required int value,
    required List<int> values,
    required Color color,
    required Function(int) onSelected,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900),
          onChanged: (text) {
            final number = int.tryParse(text);
            if (number != null) setState(() => onSelected(number));
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.edit_calendar_rounded, color: color),
            suffixIcon: IconButton(
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: color),
              onPressed: () {
                showNumberPicker(
                  title: title,
                  values: values,
                  currentValue: value,
                  color: color,
                  onPick: (pickedValue) {
                    setState(() {
                      onSelected(pickedValue);
                      controller.text = title == 'Year'
                          ? pickedValue.toString()
                          : pickedValue.toString().padLeft(2, '0');
                    });
                  },
                );
              },
            ),
            filled: true,
            fillColor: color.withOpacity(0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color.withOpacity(0.25)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color.withOpacity(0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }

  void showNumberPicker({
    required String title,
    required List<int> values,
    required int currentValue,
    required Color color,
    required Function(int) onPick,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xffD0D5DD),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select $title',
                style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: values.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: title == 'Year' ? 4 : 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: title == 'Year' ? 1.45 : 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final item = values[index];
                    final active = item == currentValue;

                    return InkWell(
                      onTap: () {
                        onPick(item);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: active ? color : color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withOpacity(0.25)),
                        ),
                        child: Center(
                          child: Text(
                            title == 'Year' ? '$item' : item.toString().padLeft(2, '0'),
                            style: TextStyle(
                              color: active ? Colors.white : color,
                              fontWeight: FontWeight.w900,
                              fontSize: title == 'Year' ? 15 : 17,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget resultCard() {
    final valid = isValid == true;
    final color = valid ? const Color(0xff16A34A) : const Color(0xffDC2626);
    final bg = valid ? const Color(0xffF0FDF4) : const Color(0xffFEF2F2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: color,
                child: Icon(valid ? Icons.check : Icons.close, color: Colors.white, size: 52),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    resultWord(valid),
                    const SizedBox(height: 12),
                    if (resultDate.isNotEmpty)
                      Text(
                        resultDate,
                        style: TextStyle(
                          color: color,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      resultMessage,
                      style: const TextStyle(
                        color: Color(0xff475467),
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              infoItem(
                icon: Icons.calendar_today_outlined,
                title: 'Day of Week',
                value: dayOfWeek,
                color: const Color(0xff16A34A),
              ),
              infoItem(
                icon: Icons.calendar_month_outlined,
                title: 'Days in Month',
                value: daysOfMonth == 0 ? '-' : '$daysOfMonth',
                color: const Color(0xff2563EB),
              ),
              infoItem(
                icon: Icons.star_border_rounded,
                title: 'Leap Year',
                value: leapYear ? 'Yes' : 'No',
                color: const Color(0xff7C3AED),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget resultWord(bool valid) {
    final color = valid ? const Color(0xff16A34A) : const Color(0xffDC2626);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        valid ? 'Valid' : 'Invalid',
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget infoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.10),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xff667085), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget tipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffEFF6FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffBFDBFE)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(Icons.lightbulb_outline, color: Color(0xff2563EB)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Did you know? A leap year has 29 days in February.',
              style: TextStyle(
                color: Color(0xff475467),
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
          Icon(Icons.calendar_month, color: Color(0xff60A5FA), size: 48),
        ],
      ),
    );
  }

  Widget pageHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff7C3AED), Color(0xff0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(icon, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: whiteCardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xffF3E8FF),
            child: Icon(icon, color: const Color(0xff7C3AED), size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xff667085), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget aboutCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: whiteCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xffEFF6FF),
            child: Icon(icon, color: const Color(0xff2563EB)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(color: Color(0xff475467), height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget autoSummaryItem({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff667085),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget gradientButton({
    required String text,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.28),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 23),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget bottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(icon: Icons.home_rounded, label: 'Checker', index: 0),
          navItem(icon: Icons.history, label: 'History', index: 1),
          navItem(icon: Icons.science_rounded, label: 'Test', index: 2),
          navItem(icon: Icons.info_outline, label: 'About', index: 3),
        ],
      ),
    );
  }

  Widget navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final active = selectedTab == index;

    return InkWell(
      onTap: () => setState(() => selectedTab = index),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: active ? 96 : 68,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xffF3E8FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? const Color(0xff7C3AED) : const Color(0xff6B7280),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xff7C3AED) : const Color(0xff6B7280),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*flutter run -d web-server --web-hostname 0.0.0.0 --web-port 9999*/ /*cách chạy app date time checker trên IOS*/