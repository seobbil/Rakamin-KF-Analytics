# 🎯 Pendahuluan
Proyek ini bertujuan untuk mengevaluasi dan menganalisis kinerja bisnis Kimia Farma secara menyeluruh selama periode tahun 2020 hingga 2023.
## Analisis Kinerja Bisnis Kimia Farma

Deskripsi:
Pada era yang banyak berkaitan dengan data seperti saat ini, analisis kinerja bisnis memiliki peran penting dalam menghasilkan keputusan. Proyek ini bertujuan untuk menganalisis **Kinerja Bisnis Kimia Farma dari tahun 2020 hingga 2023** menggunakan Google BigQuery, sebagai bagian dari program Rakamin Academy yang berkolaborasi dengan Kimia Farma. 💻💊

Repositori ini memuat seluruh alur kerja yang dilakukan, mulai dari pemrosesan data hingga penarikan insight akhir. Dengan memanfaatkan query SQL dan perangkat visualisasi data, proyek ini akan mengubah data mentah menjadi informasi bisnis yang bermakna dan menemukan berbagai informasi penting. 🔍

Hasil akhir dari analisis ini disajikan melalui dashboard interaktif di Google Looker Studio. Hal ini dirancang untuk memudahkan interpretasi terhadap tren dan pola pada kinerja bisnis Kimia Farma. 

# 📖 Latar Belakang
Proyek ini dilatarbelakangi oleh keinginan untuk memahami dan mengevaluasi kinerja bisnis Kimia Farma secara lebih mendalam. Sebagai bagian dari program Big Data Analytics yang diselenggarakan oleh Rakamin Academy bersama Kimia Farma, analisis dilakukan terhadap berbagai metrik bisnis utama selama periode 2020–2023 untuk memperoleh insight yang dapat mendukung proses pengambilan keputusan. Data yang digunakan berasal dari pencatatan internal Kimia Farma. Karena mengandung informasi yang bersifat rahasia dan sensitif, dataset mentah tidak dipublikasikan secara umum. Hasil pengolahan data kemudian digunakan untuk merancang dashboard interaktif menggunakan Google Looker Studio, yang bertujuan memvisualisasikan tren dan perkembangan kinerja bisnis Kimia Farma secara informatif, sistematis, dan mudah dipahami. Dengan memanfaatkan kombinasi query SQL dan visualisasi data, proyek ini berupaya menjawab beberapa pertanyaan bisnis berikut:

1. Bagaimana tren penjualan bersih 2020–2023 dan apakah ada pola musiman?
2. Sepuluh provinsi mana saja yang mencatatkan jumlah transaksi paling tinggi?
3. Sepuluh provinsi mana saja yang menyumbang penjualan bersih (net sales) terbesar?
4. Bagaimana perkembangan margin laba bersih dari tahun ke tahun?
5. Lima provinsi mana saja yang memiliki tingkat kepuasan (rating) tertinggi, tetapi jumlah transaksinya tergolong paling rendah?

Selain untuk memberikan masukan strategis bagi bisnis Kimia Farma, pengerjaan proyek ini juga menjadi sarana bagi saya untuk terus mengasah keahlian di bidang analitik data, khususnya dalam penggunaan SQL, BigQuery, serta Google Looker Studio. 📊

# 🛠️ Alat yang Digunakan

Dalam menganalisis kinerja bisnis Kimia Farma, saya memanfaatkan tiga tools utama:
1. Google BigQuery: untuk memproses dan menjalankan query pada dataset berskala besar.
2. Google Looker Studio: untuk merancang dashboard interaktif yang menyulap data mentah menjadi visualisasi insight untuk mendukung pengambilan keputusan.
3. GitHub: untuk mendokumentasikan, melacak progres, dan membagikan hasil proyek secara terstruktur.

# 📁 Data Understanding

Dalam proyek ini, digunakan **4 file CSV** yang memuat data bisnis utama dari **Kimia Farma**:

🧾 * `kf_final_transaction` : Berisi riwayat pencatatan transaksi, termasuk detail penjualan dan pendapatan.
📦 * `kf_inventory` : Memuat data ketersediaan stok produk dan pergerakan inventaris.
🏢 `kf_kantor_cabang` : Menyediakan informasi terkait lokasi kantor cabang dan detail operasionalnya.
🏷️ * `kf_product` : Memuat rincian informasi produk, termasuk kategori dan harga.

Setelah mengimpor file-file tersebut ke dalam **Google BigQuery**, saya membuat sebuah tabel analisis baru bernama `tabel_analisis_kf` pada dataset yang sama. Tabel ini berfungsi sebagai **sumber data terpusat (*centralized data source*)**, yang menggabungkan keempat file CSV sebelumnya untuk memudahkan proses analisis. Kemudian **menggabungkan dataset ini** menggunakan *query* SQL untuk memastikan dataset menjadi terstruktur sebelum dianalisis lebih lanjut. Berikut adalah kode SQL yang digunakan untuk membuat tabel analisis: 

```sql
CREATE OR REPLACE TABLE `kimia_farma.tabel_analisa_kf` AS
SELECT 
  -- 1. Tabel transaksi (1)
  t.transaction_id,
  t.date,
  t.branch_id,

  -- 2. Tabel kantor cabang
  c.branch_name,
  c.kota,
  c.provinsi,
  c.rating AS rating_kantor_cabang,
  
  -- 3. Tabel transaksi (2)
  t.customer_name,
  t.product_id,
  
  -- 4. Tabel produk
  p.product_name,
  p.price AS actual_price,
  t.discount_percentage,
  
  -- 5. Persentase gross laba 
  CASE 
    WHEN p.price <= 50000 THEN 0.10
    WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
    WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
    WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
    WHEN p.price > 500000 THEN 0.30
  END AS persentase_gross_laba,
  
  -- 6. Harga setelah diskon
  (t.price * (1 - (t.discount_percentage / 100))) AS nett_sales,
  
  -- 7. Menghitung nett profit 
  (t.price * (1 - (t.discount_percentage / 100))) * 
  CASE 
    WHEN p.price <= 50000 THEN 0.10
    WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
    WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
    WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
    WHEN p.price > 500000 THEN 0.30
  END AS nett_profit,
  
  -- 8. Rating transaksi dari tabel utama
  t.rating AS rating_transaksi

-- JOIN
FROM `kimia_farma.kf_final_transaction` AS t
LEFT JOIN `kimia_farma.kf_kantor_cabang` AS c
  ON t.branch_id = c.branch_id
LEFT JOIN `kimia_farma.kf_product` AS p
  ON t.product_id = p.product_id
;
```
Setelah tabel `tabel_analisa_kf` berhasil dibuat di **Google BigQuery**, langkah selanjutnya adalah menghubungkannya ke **Google Looker Studio** untuk proses analisis dan visualisasi data.

### 🔗 Koneksi BigQuery ke Looker Studio
1. Buka **Google Looker Studio** dan buat *data source* (sumber data) baru.
2. Pilih **Google BigQuery**.
3. Pilih *project* dan *dataset* `kimia_farma`, lalu pilih tabel `tabel_analisa_kf`.
4. Klik **Connect**.

### 📊 Analisis & Visualisasi
Setelah terhubung, data divisualisasikan menggunakan beberapa komponen utama:
* 📈 **Bar & Line Charts:** Untuk memantau tren penjualan.
* 🗺️ **Geo Maps:** Untuk memetakan sebaran transaksi, *net sales*, dan *net profit* berdasarkan lokasi.
* 🧮 **Tables & Scorecards:** Untuk menyoroti metrik penting seperti total pendapatan, laba bersih, dan jumlah keseluruhan transaksi.

Pemanfaatan Looker Studio ini membantu menggali *insight* lebih dalam terkait performa bisnis Kimia Farma, sehingga mendukung pengambilan keputusan yang akurat dan berbasis data (*data-driven decision-making*). 🎯
