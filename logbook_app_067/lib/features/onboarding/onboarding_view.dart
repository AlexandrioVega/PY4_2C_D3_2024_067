import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}


class _OnboardingViewState extends State<OnboardingView> {
  int step = 0;

  // data onboarding
  final List<Map<String, String>> dataOnboarding = [
    {
      "gambar": "assets/images/reading_glasses_cuate.png",
      "judul": "Catat Aktivitas",
      "deskripsi": "Kelola aktivitas harianmu dengan mudah."
    },
    {
      "gambar": "assets/images/security.png",
      "judul": "Data Aman",
      "deskripsi": "Semua data tersimpan dengan aman."
    },
    {
      "gambar": "assets/images/time.png",
      "judul": "Hemat Waktu",
      "deskripsi": "Akses catatanmu kapan saja dan dimana saja."
    },
  ];

  // fungsi untuk lanjut ke step berikutnya
  void _nextStep() {
    if (step < dataOnboarding.length - 1) {
      setState(() {
        step++;
      });
    }

    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = dataOnboarding[step];
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              data["gambar"]!,
              width: 200,
              height: 200,
            ),

            const SizedBox(height: 40),

            Text(
              data["judul"]!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
  
            Text(
              data["deskripsi"]!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                dataOnboarding.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: step == index ? 12 : 8,
                  height: step == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: step == index ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _nextStep,
              child: Text(
                step == dataOnboarding.length - 1 ? 
                "Mulai" :
                "Lanjut"),
            ),
          ],
        ),
      ),
    );
  }
}