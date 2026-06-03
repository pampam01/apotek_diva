<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $search = isset($_GET['search']) ? $_GET['search'] : '';
    
    $query = "SELECT o.*, k.nama_kategori 
              FROM obat o 
              LEFT JOIN kategori_obat k ON o.id_kategori = k.id_kategori
              WHERE o.is_deleted = 0";
              
    if (!empty($search)) {
        $search = "%{$search}%";
        $query .= " AND (o.nama_obat LIKE ? OR o.kode_obat LIKE ?)";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ss", $search, $search);
    } else {
        $stmt = $conn->prepare($query);
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    
    $obat_list = [];
    while ($row = $result->fetch_assoc()) {
        $obat_list[] = $row;
    }
    
    echo json_encode([
        "status" => "success",
        "data" => $obat_list
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
