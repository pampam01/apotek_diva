-- SQL Query untuk memperbarui kategori obat di database Apotek Diva yang sudah terpasang.
-- Anda dapat menjalankan query ini langsung di phpMyAdmin (Tab SQL) atau SQL Client Anda.

INSERT INTO `kategori_obat` (`id_kategori`, `nama_kategori`) 
VALUES 
(5, 'Antihistamin'), 
(6, 'Antasida'), 
(7, 'Suplemen'), 
(8, 'Antiseptik'), 
(9, 'Obat Luar')
ON DUPLICATE KEY UPDATE `nama_kategori` = VALUES(`nama_kategori`);
