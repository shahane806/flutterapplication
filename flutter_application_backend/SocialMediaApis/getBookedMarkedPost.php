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
if (!$MOBILE) {
    echo json_encode(["status" => 400, "message" => "Missing required parameter: MOBILE"]);
    exit;
}

// Prepare SQL query with parameters
$sql = "SELECT * FROM dbo.BookedMarkMaster WHERE phone = ?";
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
$bookmarkedPosts = [];
while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
    $bookmarkedPosts[] = [
        "id" => $row['id'],
        "postId" => $row['postId'],
        "postType" => $row['postType'] ?? null,
        "postPath" => $row['postPath'] ?? null,
        "phone" => $row['phone'],
        "bookedMarkAt" => $row['bookedMarkAt']
    ];
}

// Free the statement resource
sqlsrv_free_stmt($stmt);

// Return JSON response
if (!empty($bookmarkedPosts)) {
    echo json_encode(["status" => 200, "message" => "Bookmarked Posts Found", "data" => $bookmarkedPosts]);
} else {
    echo json_encode(["status" => 404, "message" => "No bookmarked posts found"]);
}
?>
