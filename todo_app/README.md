# Todo List (Flutter)

Aplikasi to-do list mobile yang desainnya mengikuti referensi Dribbble
**"BidStitch mobile app"** (`../Drible.jpeg`): kartu warna solid dengan sudut sangat
membulat, dekorasi blok piksel, kartu bergaris tepi hitam dengan bayangan keras,
bar progres bersegmen, dan tombol outline.

## Fitur

- Tambah, ubah, dan hapus tugas (hapus bisa **diurungkan** lewat snackbar).
- Centang tugas selesai lewat badge di kiri judul.
- Prioritas (Rendah / Sedang / Tinggi) dan tenggat (tanggal + jam).
- Sisa waktu otomatis, mis. `18j 42m tersisa`; tugas yang lewat tenggat ditandai merah (`Terlambat 2j 10m`).
- Kartu progres bersegmen dan kartu statistik (Selesai / Tertunda).
- Filter Semua / Aktif / Selesai, serta tombol **Bersihkan** untuk menghapus semua tugas selesai.
- Data tersimpan di perangkat (`shared_preferences`), jadi tidak hilang saat aplikasi ditutup.
- Antarmuka berbahasa Indonesia, termasuk date picker dan time picker.

## Menjalankan

```bash
flutter pub get
flutter run            # pilih perangkat/emulator Android yang tersedia
flutter test           # menjalankan semua tes
```

Saat pertama dibuka, aplikasi berisi 6 contoh tugas supaya tampilannya langsung terlihat.
Font (Hanken Grotesk) diunduh oleh `google_fonts` pada peluncuran pertama, jadi perlu
internet sekali; setelah itu tersimpan di perangkat. Jika offline, aplikasi memakai font bawaan.

## Struktur kode

```
lib/
├── main.dart                  # titik masuk, MaterialApp, lokalisasi id_ID
├── models/todo.dart           # model Todo + prioritas, (de)serialisasi JSON
├── state/todo_controller.dart # ChangeNotifier: CRUD, filter, urutan, penyimpanan
├── theme/                     # palet warna, gaya teks, ThemeData
├── utils/formatters.dart      # format tanggal/jam/sisa waktu bahasa Indonesia
├── screens/home_screen.dart   # layar utama
└── widgets/                   # hero_card, progress_card, stat_card, todo_card,
                               # todo_form_sheet, filter_bar, bottom_cta, dst.
test/                          # tes unit (model, controller, formatter) + tes widget
```

## Catatan teknis

- `android/gradle.properties` berisi `kotlin.incremental=false`. Pub cache Flutter berada di
  drive `C:` sedangkan proyek di drive `H:`; tanpa pengaturan ini kompilasi Kotlin gagal dengan
  *"this and base files have different roots"*. Jika proyek dan pub cache berada di drive yang
  sama, baris itu boleh dihapus.
- Izin `INTERNET` ditambahkan di `AndroidManifest.xml` agar `google_fonts` bisa mengunduh font
  pada build release.
