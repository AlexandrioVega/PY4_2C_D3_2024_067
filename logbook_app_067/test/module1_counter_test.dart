import 'package:flutter_test/flutter_test.dart';
// Sesuaikan import di bawah ini dengan lokasi file CounterController kamu
import 'package:logbook_app_067/features/logbook/counter_controller.dart';

void main() {
  group('CounterController Unit Tests', () {
    late CounterController controller;

    setUp(() {
      // (1) Arrange: Inisialisasi objek setiap kali test dijalankan
      controller = CounterController();
    });

    test('TC01: Initial value should be 0', () {
      // (3) Assert
      expect(controller.value, 0);
    });

    test('TC02: changeStep should change step value', () {
      // (2) Act
      controller.changeStep(5);
      controller.increment(); // Jika step berubah ke 5, increment jadi 5
      
      // (3) Assert
      expect(controller.value, 5);
    });

    test('TC03: changeStep should ignore negative value', () {
      // (1) Arrange
      controller.changeStep(3);
      
      // (2) Act
      controller.changeStep(-1);
      controller.increment();
      
      // (3) Assert: Harus tetap 3 karena -1 harusnya diabaikan
      expect(controller.value, 3);
    });

    test('TC04: increment should increase counter based on step', () {
      // (1) Arrange
      controller.changeStep(2);
      
      // (2) Act
      controller.increment();
      
      // (3) Assert
      expect(controller.value, 2);
    });

    test('TC05: decrement should decrease counter based on step', () {
      // (1) Arrange
      controller.changeStep(1);
      controller.increment(); // counter jadi 1
      
      // (2) Act
      controller.decrement();
      
      // (3) Assert
      expect(controller.value, 0);
    });

    test('TC06: decrement should not go below zero', () {
      // (1) Arrange: Counter mulai dari 0
      
      // (2) Act
      controller.decrement();
      
      // (3) Assert
      expect(controller.value, 0);
    });

    test('TC07: reset should set counter to zero', () {
      // (1) Arrange
      controller.increment();
      controller.increment();
      controller.increment();
      
      // (2) Act
      controller.reset();
      
      // (3) Assert: Ekspektasi harus 0
      expect(controller.value, 0);
    });

    test('TC08: history should record actions', () {
      // (2) Act
      controller.increment();
      
      // (3) Assert
      expect(controller.history.isNotEmpty, true);
      expect(controller.history.first.contains("Menambah"), true);
    });

    test('TC09: history should not exceed 5 items', () {
      for (int i = 0; i < 6; i++) {
        controller.increment();
      }

      expect(controller.history.length, 5);
    });
  });
}