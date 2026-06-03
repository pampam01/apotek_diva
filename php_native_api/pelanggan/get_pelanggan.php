<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $search = isset($_GET['search']) ? $_GET['search'] : '';
    
    $query = "SELECT * FROM pelanggan";
              
    if (!empty($search)) {
        $search = "%{$search}%";
        $query .= " WHERE nama_pelanggan LIKE ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("s", $search);
    } else {
        $stmt = $conn->prepare($query);
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    
    $pelanggan_list = [];
    while ($row = $result->fetch_assoc()) {
        $pelanggan_list[] = $row;
    }
    
    echo json_encode([
        "status" => "success",
        "data" => $pelanggan_list
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
