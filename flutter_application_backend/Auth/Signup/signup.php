<?php
    // Set response header to JSON
    header('Content-Type: application/json');

    require_once "../../Connection/conn.php";
    require_once "../../Operations/Operations.php";
    
    // Check if connection is established
    if (!$conn) {
        echo json_encode(["status" => 500, "message" => "Database connection failed"]);
        exit;
    }
    // Initialize variables
    $MOBILE = $_POST['MOBILE'] ?? null;
    $PASSWORD = $_POST['PASSWORD'] ?? null;
    $USERNAME = $_POST['USERNAME'] ?? null;
    $DEVICE_ID = $_POST['DEVICE_ID']??null;
    $COUNTRY_CODE = $_POST['COUNTRY_CODE']??null;
    $DIAL_CODE = $_POST['DIAL_CODE']??null;
    $EMAIL = $_POST['EMAIL']??null;
    $OTP = $_POST['OTP'] ?? null;
    if (!$MOBILE || !$PASSWORD) {
        echo json_encode(["status" => 400, "message" => "Missing required fields"]);
        exit;
    }

    
    // Prepare SQL query with parameters for authentication
    $sql = "SELECT * FROM dbo.AuthenticationMaster WHERE phone = ?";
    $registerSql = "INSERT INTO dbo.AuthenticationMaster (userName, phone, otp, deviceId, pass,countryCode,dialCode,email,role) VALUES (?, ?, ?, ?,?,?, ?,?,'user')";
    $params = array($MOBILE);
    // Hash the password before storing
    $hashedPassword = password_hash($PASSWORD, PASSWORD_DEFAULT);
    $registerParams = array($USERNAME, $MOBILE, $OTP, $DEVICE_ID, $hashedPassword,$COUNTRY_CODE,$DIAL_CODE,$EMAIL);
    // Execute the SQL query
    $RESULT = sqlsrv_query($conn, $sql, $params);
    
    if ($RESULT === false) {
        echo json_encode(["status" => 500, "message" => "Query execution failed", "error" => sqlsrv_errors()]);
        exit;
    }

    $user = sqlsrv_fetch_array($RESULT, SQLSRV_FETCH_ASSOC);
    
    if ($user) {
       
        echo json_encode([
            "status" => 200,
            "message" => "User Already Present",
        ]);

    } else {
    //  echo $conn;
    //  echo $registerSql;
    //  print_r($registerParams);
       $RESULT = sqlsrv_query($conn,$registerSql,$registerParams);
       if($RESULT === false){
        echo json_encode(["status" => 401, "message" => "Registration Failed"]);
        exit;
       }
        echo json_encode([
            "status" => 200,
            "message" => "User Registered Successfully",
        ]);
    }

?>
