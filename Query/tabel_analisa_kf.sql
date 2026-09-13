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
