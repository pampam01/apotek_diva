<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (isset($data->id_obat) && isset($data->kode_obat) && isset($data->nama_obat) && isset($data->id_kategori) && 
        isset($data->harga_beli) && isset($data->harga_jual) && isset($data->stok) && 
        isset($data->satuan) && isset($data->tanggal_kadaluarsa)) {
        
        $id_obat = $data->id_obat;
        $kode_obat = $data->kode_obat;
        $nama_obat = $data->nama_obat;
        $id_kategori = $data->id_kategori;
        $harga_beli = $data->harga_beli;
        $harga_jual = $data->harga_jual;
        $stok = $data->stok;
        $satuan = $data->satuan;
        $tanggal_kadaluarsa = $data->tanggal_kadaluarsa;
        $keterangan = isset($data->keterangan) ? $data->keterangan : '';
        
        $stmt = $conn->prepare("UPDATE obat SET kode_obat=?, nama_obat=?, id_kategori=?, harga_beli=?, harga_jual=?, stok=?, satuan=?, tanggal_kadaluarsa=?, keterangan=? WHERE id_obat=?");
        $stmt->bind_param("ssiddisssi", $kode_obat, $nama_obat, $id_kategori, $harga_beli, $harga_jual, $stok, $satuan, $tanggal_kadaluarsa, $keterangan, $id_obat);
        
        if ($stmt->execute()) {
            echo json_encode([
                "status" => "success",
                "message" => "Obat berhasil diupdate"
            ]);
        } else {
            echo json_encode([
                "status" => "error",
                "message" => "Gagal mengupdate obat: " . $stmt->error
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
