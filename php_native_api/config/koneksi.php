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
?>
