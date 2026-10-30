// bin/pm_tugas_04_4242250002.dart
import 'package:pm_tugas_04_4242250002/parkir.dart';

Future<void> main() async {
  // Inisialisasi area parkir dengan kapasitas maksimal 3 kendaraan
  final areaParkir = AreaParkir(3);

  // Mendengarkan kejadian melalui Stream (ditampilkan di layar pos jaga)
  areaParkir.logStream.listen((event) {
    print(event);
  });

  // Waktu simulasi awal
  final waktuMasuk = DateTime(2026, 11, 1, 8, 0);

  try {
    // 6. Mendemonstrasikan Polimorfisme (List berbagai jenis kendaraan)
    final motor = Motor('BK 1234 AB', waktuMasuk: waktuMasuk);
    final mobil = Mobil('BK 88 UN', waktuMasuk: waktuMasuk);
    final mobilMember = MobilMember('BK 7 MIPA', waktuMasuk: waktuMasuk);
    final trukEkstra = Truk('BK 9999 X', waktuMasuk: waktuMasuk);

    // Kendaraan masuk satu per satu
    await areaParkir.masuk(motor);
    await areaParkir.masuk(mobil);
    await areaParkir.masuk(mobilMember);

    // Mencoba memasukkan kendaraan ke-4 saat kapasitas sudah penuh (Kapasitas = 3)
    try {
      await areaParkir.masuk(trukEkstra);
    } on ParkirPenuh catch (e) {
      print(e); // Menangkap exception kustom Parkir Penuh
    }

    // Simulasi waktu keluar 2 jam kemudian (pukul 10:00)
    final waktuKeluar = DateTime(2026, 11, 1, 10, 0);

    await Future.delayed(const Duration(milliseconds: 200));
    print('\n--- PROSES KELUAR KENDARAAN ---');

    await areaParkir.keluar('BK 1234 AB', waktuKeluar);
    await areaParkir.keluar('BK 88 UN', waktuKeluar);
    await areaParkir.keluar('BK 7 MIPA', waktuKeluar);

    // Menampilkan Total Pendapatan Akhir
    print('\nPendapatan: Rp${areaParkir.totalPendapatan.toInt()}');
  } catch (e) {
    print('Terjadi kesalahan: $e');
  } finally {
    // Menutup stream di akhir program
    await areaParkir.tutup();
  }
}