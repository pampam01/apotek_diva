<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    if (isset($_GET['id_obat'])) {
        $id_obat = $_GET['id_obat'];
        
        $stmt = $conn->prepare("SELECT o.*, k.nama_kategori FROM obat o LEFT JOIN kategori_obat k ON o.id_kategori = k.id_kategori WHERE o.id_obat = ?");
        $stmt->bind_param("i", $id_obat);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $obat = $result->fetch_assoc();
            echo json_encode([
                "status" => "success",
                "data" => $obat
            ]);
        } else {
            echo json_encode([
                "status" => "error",
                "message" => "Obat tidak ditemukan"
            ]);
        }
        $stmt->close();
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "ID Obat tidak diberikan"
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Method not allowed"
    ]);
}
$conn->close();
?>
