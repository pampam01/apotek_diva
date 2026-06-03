<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (isset($data->id_user) && isset($data->id_pelanggan) && isset($data->total_harga) && 
        isset($data->jumlah_bayar) && isset($data->kembalian) && isset($data->items)) {
        
        $conn->begin_transaction();
        
        try {
            $no_faktur = 'TRX-' . date('YmdHis') . rand(100, 999);
            $tanggal_transaksi = date('Y-m-d H:i:s');
            
            $stmt = $conn->prepare("INSERT INTO transaksi (no_faktur, tanggal_transaksi, id_user, id_pelanggan, total_harga, jumlah_bayar, kembalian) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("ssiiddd", $no_faktur, $tanggal_transaksi, $data->id_user, $data->id_pelanggan, $data->total_harga, $data->jumlah_bayar, $data->kembalian);
            $stmt->execute();
            $id_transaksi = $conn->insert_id;
            $stmt->close();
            
            $stmt_detail = $conn->prepare("INSERT INTO detail_transaksi (id_transaksi, id_obat, jumlah, harga_satuan, subtotal) VALUES (?, ?, ?, ?, ?)");
            $stmt_stok = $conn->prepare("UPDATE obat SET stok = stok - ? WHERE id_obat = ?");
            
            foreach ($data->items as $item) {
                $stmt_detail->bind_param("iiidd", $id_transaksi, $item->id_obat, $item->jumlah, $item->harga_satuan, $item->subtotal);
                $stmt_detail->execute();
                
                $stmt_stok->bind_param("ii", $item->jumlah, $item->id_obat);
                $stmt_stok->execute();
            }
            
            $stmt_detail->close();
            $stmt_stok->close();
            
            $conn->commit();
            
            echo json_encode([
                "status" => "success",
                "message" => "Transaksi berhasil ditambahkan",
                "no_faktur" => $no_faktur,
                "id_transaksi" => $id_transaksi
            ]);
            
        } catch (Exception $e) {
            $conn->rollback();
            echo json_encode([
                "status" => "error",
                "message" => "Gagal menambahkan transaksi: " . $e->getMessage()
            ]);
        }
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
