<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (isset($data->nama_pelanggan)) {
        $nama_pelanggan = $data->nama_pelanggan;
        $no_telepon = isset($data->no_telepon) ? $data->no_telepon : null;
        $alamat = isset($data->alamat) ? $data->alamat : null;
        
        $stmt = $conn->prepare("INSERT INTO pelanggan (nama_pelanggan, no_telepon, alamat) VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $nama_pelanggan, $no_telepon, $alamat);
        
        if ($stmt->execute()) {
            echo json_encode([
                "status" => "success",
                "message" => "Pelanggan berhasil ditambahkan",
                "id_pelanggan" => $conn->insert_id
            ]);
        } else {
            echo json_encode([
                "status" => "error",
                "message" => "Gagal menambahkan pelanggan: " . $stmt->error
            ]);
        }
        $stmt->close();
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Nama pelanggan wajib diisi"
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
