<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (isset($data->id_obat)) {
        $id_obat = $data->id_obat;
        
        $stmt = $conn->prepare("DELETE FROM obat WHERE id_obat = ?");
        $stmt->bind_param("i", $id_obat);
        
        if ($stmt->execute()) {
            echo json_encode([
                "status" => "success",
                "message" => "Obat berhasil dihapus"
            ]);
        } else {
            echo json_encode([
                "status" => "error",
                "message" => "Gagal menghapus obat: " . $stmt->error
            ]);
        }
        $stmt->close();
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Data tidak lengkap"
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
