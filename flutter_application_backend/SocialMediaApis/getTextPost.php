<?php
// Set response header to JSON
header('Content-Type: application/json');

// Include required files for database connection and operations
require_once "../Connection/conn.php";
require_once "../Operations/Operations.php";

// Check if connection is established
if (!$conn) {
    echo json_encode(["status" => 500, "message" => "Database connection failed"]);
    exit;
}

// Initialize variables
$MOBILE = $_POST['MOBILE'] ?? null;

// Validate input
if (!$MOBILE ) {
    echo json_encode(["status" => 400, "message" => "Missing required parameters"]);
    exit;
}

// Prepare SQL query with parameters
$sql = "SELECT id,  phone, title, message, createdAt, updatedAt FROM dbo.TextPost WHERE phone = ? ";
$params = array($MOBILE);

// Prepare and execute query
$stmt = sqlsrv_prepare($conn, $sql, $params);
if (!$stmt) {
    echo json_encode(["status" => 500, "message" => "Query preparation failed", "error" => sqlsrv_errors()]);
    exit;
}

if (!sqlsrv_execute($stmt)) {
    echo json_encode(["status" => 500, "message" => "Query execution failed", "error" => sqlsrv_errors()]);
    exit;
}

// Fetch results
$posts = [];
while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
    $posts[] = [
        "id" => $row['id'],
        "phone" => $row['phone'],
        "title" => $row['title'],
        "message" => $row['message'],
        "createdAt" => $row['createdAt']->format('Y-m-d H:i:s'),
        "updatedAt" => $row['updatedAt']->format('Y-m-d H:i:s')
    ];
}

// Free the statement resource
sqlsrv_free_stmt($stmt);

// Return JSON response
if (!empty($posts)) {
    echo json_encode(["status" => 200, "message" => "Posts Found", "data" => $posts]);
} else {
    echo json_encode(["status" => 404, "message" => "No posts found"]);
}

?>
