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
    echo json_encode(["status" => 400, "message" => "Missing required parameters"]);
    exit;
}

// Prepare SQL query to fetch liked posts along with like count for each post
$sql = "
    SELECT 
        lm.id, 
        lm.postId, 
        lm.postType, 
        lm.postPath, 
        lm.phone, 
        lm.likedAt, 
        COUNT(lm2.id) AS likeCount
    FROM dbo.LikeMaster lm
    LEFT JOIN dbo.LikeMaster lm2 ON lm2.postId = lm.postId
    WHERE lm.phone = ?
    GROUP BY lm.id, lm.postId, lm.postType, lm.postPath, lm.phone, lm.likedAt
";

// Prepare and execute query
$params = array($MOBILE);
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
        "postId" => $row['postId'],
        "postType" => $row['postType'] ?? null,  // Assuming LikeMaster might not have postType
        "postPath" => $row['postPath'] ?? null,  // Assuming LikeMaster might not have postPath
        "phone" => $row['phone'],
        "likedAt" => $row['likedAt'],
        "likeCount" => $row['likeCount']  // Like count for each post
    ];
}

// Free the statement resource
sqlsrv_free_stmt($stmt);

// Return JSON response
if (!empty($posts)) {
    echo json_encode(["status" => 200, "message" => "Liked Posts Found", "data" => $posts]);
} else {
    echo json_encode(["status" => 404, "message" => "No Liked posts found"]);
}
?>
