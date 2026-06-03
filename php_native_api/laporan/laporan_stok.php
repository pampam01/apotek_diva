<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Menampilkan obat dengan stok menipis (< 10) atau semua jika parameter all=1
    $show_all = isset($_GET['all']) ? $_GET['all'] : 0;
    
    $query = "SELECT o.kode_obat, o.nama_obat, o.stok, o.satuan, k.nama_kategori 
              FROM obat o 
              LEFT JOIN kategori_obat k ON o.id_kategori = k.id_kategori";
              
    if ($show_all == 0) {
        $query .= " WHERE o.stok < 10";
    }
    
    $query .= " ORDER BY o.stok ASC";
    
    $result = $conn->query($query);
    
    $laporan = [];
    while ($row = $result->fetch_assoc()) {
        $laporan[] = $row;
    }
    
    echo json_encode([
        "status" => "success",
        "data" => $laporan
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Method not allowed"
    ]);
}
$conn->close();
?>
