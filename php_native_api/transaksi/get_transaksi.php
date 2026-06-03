<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $search = isset($_GET['search']) ? $_GET['search'] : '';
    
    $query = "SELECT t.*, u.nama_lengkap as nama_kasir, p.nama_pelanggan 
              FROM transaksi t 
              JOIN users u ON t.id_user = u.id_user 
              JOIN pelanggan p ON t.id_pelanggan = p.id_pelanggan
              ORDER BY t.tanggal_transaksi DESC";
              
    if (!empty($search)) {
        $search = "%{$search}%";
        $query = "SELECT t.*, u.nama_lengkap as nama_kasir, p.nama_pelanggan 
                  FROM transaksi t 
                  JOIN users u ON t.id_user = u.id_user 
                  JOIN pelanggan p ON t.id_pelanggan = p.id_pelanggan
                  WHERE t.no_faktur LIKE ? 
                  ORDER BY t.tanggal_transaksi DESC";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("s", $search);
    } else {
        $stmt = $conn->prepare($query);
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    
    $transaksi_list = [];
    while ($row = $result->fetch_assoc()) {
        $transaksi_list[] = $row;
    }
    
    echo json_encode([
        "status" => "success",
        "data" => $transaksi_list
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
