<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $start_date = isset($_GET['start_date']) ? $_GET['start_date'] : date('Y-m-01'); // Default awal bulan
    $end_date = isset($_GET['end_date']) ? $_GET['end_date'] : date('Y-m-d'); // Default hari ini
    
    $query = "SELECT t.id_transaksi, t.no_faktur, t.tanggal_transaksi, t.total_harga, t.jumlah_bayar, t.kembalian, u.nama_lengkap as kasir 
              FROM transaksi t 
              JOIN users u ON t.id_user = u.id_user 
              WHERE DATE(t.tanggal_transaksi) BETWEEN ? AND ?
              ORDER BY t.tanggal_transaksi DESC";
              
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ss", $start_date, $end_date);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $laporan = [];
    $total_pendapatan = 0;
    while ($row = $result->fetch_assoc()) {
        $laporan[] = $row;
        $total_pendapatan += $row['total_harga'];
    }
    
    echo json_encode([
        "status" => "success",
        "data" => [
            "list" => $laporan,
            "total_pendapatan" => $total_pendapatan,
            "start_date" => $start_date,
            "end_date" => $end_date
        ]
    ]);
    
    $stmt->close();
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Method not allowed"
    ]);
}
$conn->close();
?>
