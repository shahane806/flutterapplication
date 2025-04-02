<?php
// Set response header to JSON
header('Content-Type: application/json');

require_once "../../Connection/conn.php";
require_once "../../Operations/Operations.php";

$action = $_POST['action'] ?? null;
$MOBILE = $_POST['MOBILE'] ?? null;
$DEVICE_ID = $_POST['DEVICE_ID'] ?? null;
$OTP = $_POST['OTP'] ?? null;
$NEW_PASSWORD = $_POST['NEW_PASSWORD'] ?? null;

// Check if connection is established
if (!$conn) {
    echo json_encode(["status" => 500, "message" => "Database connection failed"]);
    exit;
}

if (!$MOBILE || !$DEVICE_ID) {
    echo json_encode(["status" => 400, "message" => "Missing required fields (MOBILE or DEVICE_ID)"]);
    exit;
}

// **Step 1: Request OTP (Forget Password)**
if ($action === "request_otp") {
    // Check if the user exists and verify DEVICE_ID
    $sql = "SELECT * FROM dbo.AuthenticationMaster WHERE phone = ? AND deviceId = ?";
    $params = array($MOBILE, $DEVICE_ID);
    $RESULT = sqlsrv_query($conn, $sql, $params);

    if ($RESULT === false) {
        echo json_encode(["status" => 500, "message" => "Database query failed", "error" => sqlsrv_errors()]);
        exit;
    }

    $user = sqlsrv_fetch_array($RESULT, SQLSRV_FETCH_ASSOC);

    if (!$user) {
        echo json_encode(["status" => 403, "message" => "Unauthorized device or user not found"]);
        exit;
    }

    // Generate a 6-digit OTP
    $generatedOTP = rand(100000, 999999);

    // Update OTP in database
    $updateOtpSQL = "UPDATE dbo.AuthenticationMaster SET otp = ?, updatedAt = GETDATE() WHERE phone = ?";
    $updateOtpParams = array($generatedOTP, $MOBILE);
    $updateResult = sqlsrv_query($conn, $updateOtpSQL, $updateOtpParams);

    if (!$updateResult) {
        echo json_encode(["status" => 500, "message" => "Failed to update OTP"]);
        exit;
    }

    // TODO: Integrate an SMS API to send OTP to the user's phone number
    // sendOTP($MOBILE, $generatedOTP); // Uncomment when you integrate an SMS API

    echo json_encode(["status" => 200, "message" => "OTP sent successfully", "OTP" => $generatedOTP]); // Remove OTP from response in production!
    exit;
}

// **Step 2: Verify OTP & Reset Password**
if ($action === "reset_password") {
    if (!$OTP || !$NEW_PASSWORD) {
        echo json_encode(["status" => 400, "message" => "Missing OTP or new password"]);
        exit;
    }

    // Verify OTP and DEVICE_ID
    $verifyOtpSQL = "SELECT * FROM dbo.AuthenticationMaster WHERE phone = ? AND otp = ? AND deviceId = ?";
    $verifyOtpParams = array($MOBILE, $OTP, $DEVICE_ID);
    $verifyResult = sqlsrv_query($conn, $verifyOtpSQL, $verifyOtpParams);

    if ($verifyResult === false) {
        echo json_encode(["status" => 500, "message" => "Database query failed", "error" => sqlsrv_errors()]);
        exit;
    }

    $user = sqlsrv_fetch_array($verifyResult, SQLSRV_FETCH_ASSOC);

    if (!$user) {
        echo json_encode(["status" => 401, "message" => "Invalid OTP or unauthorized device"]);
        exit;
    }

    // Hash the new password
    $hashedPassword = password_hash($NEW_PASSWORD, PASSWORD_DEFAULT);

    // Update password in database
    $updatePasswordSQL = "UPDATE dbo.AuthenticationMaster SET pass = ?, otp = NULL, updatedAt = GETDATE() WHERE phone = ?";
    $updatePasswordParams = array($hashedPassword, $MOBILE);
    $updatePasswordResult = sqlsrv_query($conn, $updatePasswordSQL, $updatePasswordParams);

    if (!$updatePasswordResult) {
        echo json_encode(["status" => 500, "message" => "Failed to update password"]);
        exit;
    }

    echo json_encode(["status" => 200, "message" => "Password reset successfully"]);
    exit;
}

echo json_encode(["status" => 400, "message" => "Invalid request"]);
?>
