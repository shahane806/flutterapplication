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
$POST_TYPE = $_POST['POST_TYPE'] ?? null;

// Validate input
if (!$MOBILE || !$POST_TYPE) {
    echo json_encode(["status" => 400, "message" => "Missing required parameters"]);
    exit;
}

// Prepare SQL query with parameters
$sql = "SELECT * FROM dbo.Postmaster WHERE phone = ? AND postType = ?";
$params = array($MOBILE, $POST_TYPE);

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
        "postType" => $row['postType'],
        "postPath" => $row['postPath'],
        "phone" => $row['phone'],
        "createdAt" => $row['createdAt'],
        "updatedAt" => $row['updatedAt']
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
