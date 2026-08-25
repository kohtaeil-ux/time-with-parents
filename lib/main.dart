import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 애드몹 초기화
  MobileAds.instance.initialize();
  runApp(const TimeWithParentsApp());
}

class TimeWithParentsApp extends StatelessWidget {
  const TimeWithParentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '함께 할 수 있는 시간',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F6F0),
        primaryColor: const Color(0xFF8D7B68),
        fontFamily: 'Pretendard',
      ),
      home: const SplashView(),
    );
  }
}

// 1. 스플래시 / 인트로 화면
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InputView()),
          );
        },
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.favorite_border, size: 64, color: Color(0xFFB4A595)),
              SizedBox(height: 24),
              Text(
                "소중한 시간을 함께하세요",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5C5346),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 48),
              Text(
                "화면을 터치해 시작하세요",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. 생년월일 입력 화면
class InputView extends StatefulWidget {
  const InputView({super.key});

  @override
  State<InputView> createState() => _InputViewState();
}

class _InputViewState extends State<InputView> {
  final TextEditingController _fYear = TextEditingController();
  final TextEditingController _fMonth = TextEditingController();
  final TextEditingController _fDay = TextEditingController();
  String _fCalendar = '양력';

  final TextEditingController _mYear = TextEditingController();
  final TextEditingController _mMonth = TextEditingController();
  final TextEditingController _mDay = TextEditingController();
  String _mCalendar = '양력';

  void _onComplete() async {
    bool hasFather = _fYear.text.isNotEmpty && _fMonth.text.isNotEmpty && _fDay.text.isNotEmpty;
    bool hasMother = _mYear.text.isNotEmpty && _mMonth.text.isNotEmpty && _mDay.text.isNotEmpty;

    if (!hasFather && !hasMother) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("부모님 중 최소 한 분의 생년월일을 입력해주세요.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('f_year');
    await prefs.remove('m_year');

    if (hasFather) {
      await prefs.setString('f_year', _fYear.text);
      await prefs.setString('f_month', _fMonth.text);
      await prefs.setString('f_day', _fDay.text);
      await prefs.setString('f_cal', _fCalendar);
    }
    
    if (hasMother) {
      await prefs.setString('m_year', _mYear.text);
      await prefs.setString('m_month', _mMonth.text);
      await prefs.setString('m_day', _mDay.text);
      await prefs.setString('m_cal', _mCalendar);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FrequencyView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5C5346)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              "부모님의 생년월일을\n알려주세요",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A4033), height: 1.3),
            ),
            const SizedBox(height: 8),
            const Text(
              "기록하지 않은 분은 비워두셔도 됩니다.",
              style: TextStyle(fontSize: 14, color: Color(0xFF8C8275)),
            ),
            const SizedBox(height: 32),
            _buildDateInputBox("아버지 생년월일", _fYear, _fMonth, _fDay, _fCalendar, (val) {
              setState(() => _fCalendar = val!);
            }),
            const SizedBox(height: 20),
            _buildDateInputBox("어머니 생년월일", _mYear, _mMonth, _mDay, _mCalendar, (val) {
              setState(() => _mCalendar = val!);
            }),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8D7B68),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("완료", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInputBox(String title, TextEditingController y, TextEditingController m, TextEditingController d, String cal, ValueChanged<String?> onCalChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF5C5346))),
              DropdownButton<String>(
                value: cal,
                underline: const SizedBox(),
                style: const TextStyle(fontSize: 13, color: Color(0xFF8D7B68), fontWeight: FontWeight.bold),
                items: ['양력', '음력'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onCalChanged,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(flex: 2, child: _textField(y, "년 (YYYY)")),
              const SizedBox(width: 8),
              Expanded(flex: 1, child: _textField(m, "월")),
              const SizedBox(width: 8),
              Expanded(flex: 1, child: _textField(d, "일")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}

// 3. 만남 주기 입력 화면
class FrequencyView extends StatefulWidget {
  const FrequencyView({super.key});

  @override
  State<FrequencyView> createState() => _FrequencyViewState();
}

class _FrequencyViewState extends State<FrequencyView> {
  final TextEditingController _freqController = TextEditingController(text: "12");

  void _saveFrequency() async {
    int freq = int.tryParse(_freqController.text) ?? 12;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('frequency', freq);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainCountdownView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5C5346)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1년에 몇 번\n부모님을 뵙나요?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A4033), height: 1.3),
            ),
            const SizedBox(height: 8),
            const Text(
              "1년 동안 직접 만나뵙고 함께 시간을 보내는 횟수를 적어주세요.",
              style: TextStyle(fontSize: 14, color: Color(0xFF8C8275)),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _freqController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4033)),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  const Text("회 / 년", style: TextStyle(fontSize: 16, color: Color(0xFF8C8275))),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveFrequency,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8D7B68),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("확인", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 4. 메인 카운트다운 화면 (애드몹 배너 광고 연동)
class MainCountdownView extends StatefulWidget {
  const MainCountdownView({super.key});

  @override
  State<MainCountdownView> createState() => _MainCountdownViewState();
}

class _MainCountdownViewState extends State<MainCountdownView> {
  bool _isLoading = true;
  DateTime? fatherTarget;
  DateTime? motherTarget;
  Timer? _timer;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadDataAndCalculate();
    _initBannerAd();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  // 구글 공식 테스트 배너 광고 로드
  void _initBannerAd() {
    _bannerAd = BannerAd(
      // 테스트용 배너 광고 ID (실제 출시 때는 본인 애드몹 ID로 교체 필요)
      adUnitId: 'ca-app-pub-7684630036817212/1444739290',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadDataAndCalculate() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? fY = prefs.getString('f_year');
    String? fM = prefs.getString('f_month');
    String? fD = prefs.getString('f_day');

    String? mY = prefs.getString('m_year');
    String? mM = prefs.getString('m_month');
    String? mD = prefs.getString('m_day');

    int freq = prefs.getInt('frequency') ?? 12;

    if (fY != null && fM != null && fD != null) {
      fatherTarget = _getTargetDateTime(int.parse(fY), int.parse(fM), int.parse(fD), freq);
    }

    if (mY != null && mM != null && mD != null) {
      motherTarget = _getTargetDateTime(int.parse(mY), int.parse(mM), int.parse(mD), freq);
    }

    setState(() {
      _isLoading = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  DateTime _getTargetDateTime(int year, int month, int day, int freqPerYear) {
    try {
      DateTime birthDate = DateTime(year, month, day);
      DateTime target100Date = DateTime(birthDate.year + 100, birthDate.month, birthDate.day);
      
      DateTime now = DateTime.now();
      if (now.isAfter(target100Date)) return now;

      int totalDaysUntil100 = target100Date.difference(now).inDays;
      int remainingYears = (totalDaysUntil100 / 365).round();
      int totalMeetings = remainingYears * freqPerYear;
      int totalMeetingHours = totalMeetings * 24; 
      
      return now.add(Duration(hours: totalMeetingHours));
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF8D7B68))));
    }

    bool hasFather = fatherTarget != null;
    bool hasMother = motherTarget != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasFather && !hasMother) ...[
                      const Spacer(),
                      _buildCountdownCard("아버지와의 남은 시간", fatherTarget!),
                      const Spacer(),
                    ] else if (!hasFather && hasMother) ...[
                      const Spacer(),
                      _buildCountdownCard("어머니와의 남은 시간", motherTarget!),
                      const Spacer(),
                    ] else if (hasFather && hasMother) ...[
                      const Spacer(),
                      _buildCountdownCard("아버지와의 남은 시간", fatherTarget!),
                      const SizedBox(height: 24),
                      _buildCountdownCard("어머니와의 남은 시간", motherTarget!),
                      const Spacer(),
                    ],

                    const Text(
                      "시간은 많지 않습니다. 가족과 함께 하세요",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8D7B68),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // 하단 실제 애드몹 배너 광고 영역
            Container(
              alignment: Alignment.center,
              width: _bannerAd?.size.width.toDouble() ?? 320.0,
              height: _bannerAd?.size.height.toDouble() ?? 50.0,
              child: _isAdLoaded && _bannerAd != null
                  ? AdWidget(ad: _bannerAd!)
                  : const Text(
                      "광고 로딩 중...",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownCard(String title, DateTime targetTime) {
    Duration remaining = targetTime.difference(DateTime.now());
    if (remaining.isNegative) remaining = Duration.zero;

    int days = remaining.inDays;
    int hours = remaining.inHours % 24;
    int minutes = remaining.inMinutes % 60;
    int seconds = remaining.inSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: Color(0xFF8C8275), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              _timeBox("$days", "일"),
              const Text(" ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _timeBox("$hours", "시간"),
              const Text(" ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _timeBox("$minutes", "분"),
              const Text(" ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _timeBox("$seconds", "초"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String value, String unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value.padLeft(2, '0'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A4033)),
        ),
        const SizedBox(width: 2),
        Text(
          unit,
          style: const TextStyle(fontSize: 13, color: Color(0xFF5C5346), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}