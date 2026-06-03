<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Total Penjualan Hari Ini
    $today = date('Y-m-d');
    $stmt_penjualan = $conn->prepare("SELECT SUM(total_harga) as total_penjualan FROM transaksi WHERE DATE(tanggal_transaksi) = ?");
    $stmt_penjualan->bind_param("s", $today);
    $stmt_penjualan->execute();
    $res_penjualan = $stmt_penjualan->get_result();
    $total_penjualan = $res_penjualan->fetch_assoc()['total_penjualan'] ?? 0;
    
    // Total Obat (Jenis Obat)
    $stmt_obat = $conn->query("SELECT COUNT(id_obat) as total_obat FROM obat WHERE is_deleted = 0");
    $total_obat = $stmt_obat->fetch_assoc()['total_obat'] ?? 0;
    
    // Obat Hampir Habis (stok < 10)
    $stmt_stok = $conn->query("SELECT COUNT(id_obat) as obat_hampir_habis FROM obat WHERE stok < 10 AND is_deleted = 0");
    $obat_hampir_habis = $stmt_stok->fetch_assoc()['obat_hampir_habis'] ?? 0;
    
    // Total Transaksi Bulan Ini
    $current_month = date('Y-m');
    $stmt_trx = $conn->prepare("SELECT COUNT(id_transaksi) as total_transaksi FROM transaksi WHERE DATE_FORMAT(tanggal_transaksi, '%Y-%m') = ?");
    $stmt_trx->bind_param("s", $current_month);
    $stmt_trx->execute();
    $res_trx = $stmt_trx->get_result();
    $total_transaksi = $res_trx->fetch_assoc()['total_transaksi'] ?? 0;
    
    echo json_encode([
        "status" => "success",
        "data" => [
            "total_penjualan_hari_ini" => (float)$total_penjualan,
            "total_obat" => (int)$total_obat,
            "obat_hampir_habis" => (int)$obat_hampir_habis,
            "total_transaksi_bulan_ini" => (int)$total_transaksi
        ]
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Method not allowed"
    ]);
}
$conn->close();
?>
