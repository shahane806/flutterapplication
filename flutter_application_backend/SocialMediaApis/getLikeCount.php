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
$POST_ID = $_POST['POST_ID'] ?? null;

if (!$POST_ID) {
    echo json_encode(["status" => 400, "message" => "POST_ID is required"]);
    exit;
}

// Prepare SQL query for counting likes
$sql = "SELECT COUNT(*) AS likeCount FROM dbo.LikeMaster WHERE postId = ?";
$params = array($POST_ID);

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
$row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);

// Free the statement resource
sqlsrv_free_stmt($stmt);

// Return JSON response with like count
if ($row) {
    echo json_encode([
        "status" => 200,
        "message" => "Like count fetched successfully",
        "data" => ["likeCount" => (int)$row['likeCount']]
    ]);
} else {
    echo json_encode([
        "status" => 404,
        "message" => "No likes found",
        "data" => ["likeCount" => 0]
    ]);
}

?>
