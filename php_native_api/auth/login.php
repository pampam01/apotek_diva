<?php
require_once '../config/koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (isset($data->username) && isset($data->password)) {
        $username = $data->username;
        $password = md5($data->password);
        
        $stmt = $conn->prepare("SELECT id_user, username, role, nama_lengkap FROM users WHERE username = ? AND password = ?");
        $stmt->bind_param("ss", $username, $password);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $user = $result->fetch_assoc();
            echo json_encode([
                "status" => "success",
                "message" => "Login berhasil",
                "data" => $user
            ]);
        } else {
            echo json_encode([
                "status" => "error",
                "message" => "Username atau password salah"
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
