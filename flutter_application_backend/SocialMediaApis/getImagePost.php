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

// Prepare SQL query with JOIN to include like count
$sql = "
    SELECT 
        p.id,
        p.postType,
        p.postPath,
        p.phone,
        p.createdAt,
        p.updatedAt,
        COUNT(l.id) AS likeCount
    FROM dbo.PostMaster p
    LEFT JOIN dbo.LikeMaster l ON p.id = l.postId
    GROUP BY 
        p.id, 
        p.postType, 
        p.postPath, 
        p.phone, 
        p.createdAt, 
        p.updatedAt
";

// Prepare and execute query
$stmt = sqlsrv_prepare($conn, $sql);
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
        "updatedAt" => $row['updatedAt'],
        "likeCount" => (int)$row['likeCount']
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
