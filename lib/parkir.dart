// lib/parkir.dart
import 'dart:async';

// 3. Exception Kustom untuk Parkir Penuh
class ParkirPenuh implements Exception {
  final String pesan;
  ParkirPenuh(this.pesan);
  @override
  String toString() => 'Ditolak: $pesan';
}

// 2. Mixin untuk Kendaraan Member / Berlangganan (Diskon 50%)
mixin Berlangganan {
  double hitungDiskon(double tarifNormal) => tarifNormal * 0.5;
}

// 1. Abstract Class Kendaraan
abstract class Kendaraan {
  final String plat;
  final DateTime waktuMasuk;

  // Mengubah waktuMasuk menjadi named parameter agar sinkron dengan subclass
  Kendaraan(this.plat, {DateTime? waktuMasuk})
      : waktuMasuk = waktuMasuk ?? DateTime.now();

  String get jenis;
  double get tarifPerJam;

  // Perhitungan biaya: pembulatan ke atas per jam, minimal 1 jam
  double biaya(DateTime keluar) {
    final selisih = keluar.difference(waktuMasuk);
    int jam = selisih.inHours;
    if (selisih.inMinutes % 60 != 0 || jam == 0) {
      jam = jam < 1 ? 1 : jam + 1;
    }
    return jam * tarifPerJam;
  }
}

// Subclass 1: Motor
class Motor extends Kendaraan {
  Motor(super.plat, {super.waktuMasuk});
  @override
  String get jenis => 'Motor';
  @override
  double get tarifPerJam => 2000;
}

// Subclass 2: Mobil Biasa
class Mobil extends Kendaraan {
  Mobil(super.plat, {super.waktuMasuk});
  @override
  String get jenis => 'Mobil';
  @override
  double get tarifPerJam => 5000;
}

// Subclass 3: Mobil Member (Menerapkan mixin Berlangganan)
class MobilMember extends Kendaraan with Berlangganan {
  MobilMember(super.plat, {super.waktuMasuk});
  @override
  String get jenis => 'Mobil (member)';
  @override
  double get tarifPerJam => 5000;

  @override
  double biaya(DateTime keluar) {
    final normal = super.biaya(keluar);
    return hitungDiskon(normal); // Diskon 50%
  }
}

// Subclass tambahan: Truk
class Truk extends Kendaraan {
  Truk(super.plat, {super.waktuMasuk});
  @override
  String get jenis => 'Truk';
  @override
  double get tarifPerJam => 10000;
}

// 3 & 5. Kelas AreaParkir (Mengelola Kapasitas dan Stream Kejadian)
class AreaParkir {
  final int kapasitas;
  final List<Kendaraan> _parkir = [];
  double _totalPendapatan = 0;

  final _streamController = StreamController<String>.broadcast();

  AreaParkir(this.kapasitas);

  Stream<String> get logStream => _streamController.stream;
  int get sisaKapasitas => kapasitas - _parkir.length;
  double get totalPendapatan => _totalPendapatan;

  // Method Masuk (Asinkron dengan simulasi palang Future.delayed)
  Future<void> masuk(Kendaraan kendaraan, {DateTime? waktuSimulasi}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_parkir.length >= kapasitas) {
      throw ParkirPenuh('Parkiran penuh (kapasitas $kapasitas)');
    }

    _parkir.add(kendaraan);
    final info = 'MASUK ${kendaraan.jenis} ${kendaraan.plat} (sisa $sisaKapasitas)';
    _streamController.add(info);
  }

  // Method Keluar (Asinkron dengan simulasi palang Future.delayed)
  Future<double> keluar(String plat, DateTime waktuKeluar) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final kendaraan = _parkir.firstWhere(
      (k) => k.plat == plat,
      orElse: () => throw Exception('Kendaraan dengan plat $plat tidak ditemukan'),
    );

    _parkir.remove(kendaraan);
    final totalBayar = kendaraan.biaya(waktuKeluar);
    _totalPendapatan += totalBayar;

    final info = 'KELUAR ${kendaraan.jenis} ${kendaraan.plat} bayar Rp${totalBayar.toInt()}';
    _streamController.add(info);

    return totalBayar;
  }

  Future<void> tutup() async {
    await _streamController.close();
  }
}