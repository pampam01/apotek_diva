<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

mysqli_report(MYSQLI_REPORT_OFF); // Prevent PHP 8.1+ from throwing uncaught exceptions on SQL errors

$host = "localhost";
$user = "root"; // Sesuaikan jika menggunakan InfinityFree
$pass = ""; // Sesuaikan jika menggunakan InfinityFree
$db   = "apotek_diva"; // Sesuaikan jika menggunakan InfinityFree

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode([
        "status" => "error",
        "message" => "Koneksi database gagal: " . $conn->connect_error
    ]));
}

// Seed default categories if they do not exist
$conn->query("INSERT IGNORE INTO kategori_obat (id_kategori, nama_kategori) VALUES 
(1, 'Analgesik'), 
(2, 'Antibiotik'), 
(3, 'Vitamin'), 
(4, 'Obat Batuk'), 
(5, 'Antihistamin'), 
(6, 'Antasida'), 
(7, 'Suplemen'), 
(8, 'Antiseptik'), 
(9, 'Obat Luar')");
?>
