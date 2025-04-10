<?php
header('Content-Type: application/json');
require_once "../../Connection/conn.php";
require_once "../../Operations/Operations.php";
require '../../PHPMailer/src/PHPMailer.php';
require '../../PHPMailer/src/SMTP.php';
require '../../PHPMailer/src/Exception.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

$action = $_POST['action'] ?? null;
$email = $_POST['email'] ?? null;
$OTP = $_POST['otp'] ?? null;
$NEW_PASSWORD = $_POST['newPassword'] ?? null;

if (!$conn) {
    echo json_encode(["status" => 500, "message" => "Database connection failed"]);
    exit;
}

if (!$email) {
    echo json_encode(["status" => 400, "message" => "Email is required"]);
    exit;
}

// Step 1: Request OTP
if ($action === "request_otp") {
    $sql = "SELECT * FROM dbo.AuthenticationMaster WHERE email = ?";
    $params = array($email);
    $RESULT = sqlsrv_query($conn, $sql, $params);

    if ($RESULT === false || !sqlsrv_has_rows($RESULT)) {
        echo json_encode(["status" => 403, "message" => "Email not registered"]);
        exit;
    }

    $generatedOTP = rand(100000, 999999);

    // Send Email
    $mail = new PHPMailer(true);
    try {
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'om.p.shahane@gmail.com';
        $mail->Password = 'nwje ypmb cyav fhcb';
        $mail->SMTPSecure = 'ssl';
        $mail->Port = 465;

        $mail->setFrom('om.p.shahane@gmail.com', 'Om Shahane');
        $mail->addAddress($email);

        $mail->isHTML(true);
        $mail->Subject = 'Forget Password OTP';
        $mail->Body = "<p>Your OTP is: <b>$generatedOTP</b></p>";
        $mail->send();
    } catch (Exception $e) {
        echo json_encode(["status" => 500, "message" => "Email sending failed"]);
        exit;
    }

    // Save OTP
    $updateSQL = "UPDATE dbo.AuthenticationMaster SET otp = ?, updatedAt = GETDATE() WHERE email = ?";
    $updateParams = array($generatedOTP, $email);
    sqlsrv_query($conn, $updateSQL, $updateParams);

    echo json_encode(["status" => 200, "message" => "OTP sent to email"]);
    exit;
}

// Step 2: Verify OTP
if ($action === "verify_otp") {
    if (!$OTP) {
        echo json_encode(["status" => 400, "message" => "OTP is required"]);
        exit;
    }

    $verifySQL = "SELECT * FROM dbo.AuthenticationMaster WHERE email = ? AND otp = ?";
    $verifyParams = array($email, $OTP);
    $result = sqlsrv_query($conn, $verifySQL, $verifyParams);

    if ($result === false || !sqlsrv_has_rows($result)) {
        echo json_encode(["status" => 401, "message" => "Invalid OTP"]);
        exit;
    }

    echo json_encode(["status" => 200, "message" => "OTP verified successfully"]);
    exit;
}

// Step 3: Reset Password
if ($action === "reset_password") {
    if (!$OTP || !$NEW_PASSWORD) {
        echo json_encode(["status" => 400, "message" => "OTP and new password are required"]);
        exit;
    }

    $verifySQL = "SELECT * FROM dbo.AuthenticationMaster WHERE email = ? AND otp = ?";
    $params = array($email, $OTP);
    $result = sqlsrv_query($conn, $verifySQL, $params);

    if ($result === false || !sqlsrv_has_rows($result)) {
        echo json_encode(["status" => 401, "message" => "Invalid OTP"]);
        exit;
    }

    $hashedPassword = password_hash($NEW_PASSWORD, PASSWORD_DEFAULT);
    $updateSQL = "UPDATE dbo.AuthenticationMaster SET pass = ?, otp = NULL, updatedAt = GETDATE() WHERE email = ?";
    $updateParams = array($hashedPassword, $email);
    sqlsrv_query($conn, $updateSQL, $updateParams);

    echo json_encode(["status" => 200, "message" => "Password reset successfully"]);
    exit;
}

echo json_encode(["status" => 400, "message" => "Invalid request"]);
?>
