<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    if (isset($_GET['id_transaksi'])) {
        $id_transaksi = $_GET['id_transaksi'];
        
        // Get transaksi info
        $stmt = $conn->prepare("SELECT t.*, u.nama_lengkap as nama_kasir, p.nama_pelanggan 
                                FROM transaksi t 
                                JOIN users u ON t.id_user = u.id_user 
                                JOIN pelanggan p ON t.id_pelanggan = p.id_pelanggan
                                WHERE t.id_transaksi = ?");
        $stmt->bind_param("i", $id_transaksi);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $transaksi = $result->fetch_assoc();
            $stmt->close();
            
            // Get detail items
            $stmt_detail = $conn->prepare("SELECT dt.*, o.nama_obat, o.kode_obat 
                                           FROM detail_transaksi dt 
                                           JOIN obat o ON dt.id_obat = o.id_obat
                                           WHERE dt.id_transaksi = ?");
            $stmt_detail->bind_param("i", $id_transaksi);
            $stmt_detail->execute();
            $result_detail = $stmt_detail->get_result();
            
            $items = [];
            while ($row = $result_detail->fetch_assoc()) {
                $items[] = $row;
            }
            $stmt_detail->close();
            
            $transaksi['items'] = $items;
            
            echo json_encode([
                "status" => "success",
                "data" => $transaksi
            ]);
        } else {
            echo json_encode([
                "status" => "error",
                "message" => "Transaksi tidak ditemukan"
            ]);
        }
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "ID Transaksi tidak diberikan"
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
