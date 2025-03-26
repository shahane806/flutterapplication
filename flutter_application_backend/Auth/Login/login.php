<?php
    // Set response header to JSON
    header('Content-Type: application/json');

    // Include required files for database connection and operations
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

    if (!$MOBILE || !$PASSWORD) {
        echo json_encode(["status" => 400, "message" => "Missing required fields"]);
        exit;
    }

    // Prepare SQL query with parameters for authentication
    $sql = "SELECT * FROM dbo.AuthenticationMaster WHERE phone = ?";
    $params = array($MOBILE);

    // Execute the SQL query
    $RESULT = sqlsrv_query($conn, $sql, $params);

    if ($RESULT === false) {
        echo json_encode(["status" => 500, "message" => "Query execution failed", "error" => sqlsrv_errors()]);
        exit;
    }

    $user = sqlsrv_fetch_array($RESULT, SQLSRV_FETCH_ASSOC);
    
    if ($user) {
        // echo $PASSWORD;
        // echo $user['pass'];
        // Verify password (assuming passwords are stored hashed)
        if (!password_verify($PASSWORD, $user['pass'])) {
            echo json_encode(["status" => 401, "message" => "Invalid credentials"]);
            exit;
        }else{
            
        // Return success response
        echo json_encode([
            "status" => 200,
            "message" => "User Found",
            "data" => [
                "id" => $user['id'],
                "userName" => $user['userName'],
                "phone" => $user['phone'],
                "otp" => $user['otp'],
                "role"=>$user['role'],
                "deviceId" => $user['deviceId']
            ]
        ]);
        }

    } else {
        echo json_encode(["status" => 404, "message" => "User not found"]);
    }

    // Free the statement resource
    sqlsrv_free_stmt($RESULT);
?>
