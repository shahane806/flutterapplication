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

// Get page and limit from query parameters (with defaults)
$page = isset($_POST['PAGE']) ? (int)$_POST['PAGE'] : 1;
$limit = isset($_POST['PAGE_SIZE']) ? (int)$_POST['PAGE_SIZE'] : 10;
// Calculate the offset based on page number (page is 1-based)
$offset = ($page - 1) * $limit;

// Ensure offset and limit are non-negative
$offset = max(0, $offset);
$limit = max(1, $limit);

// Prepare SQL query with pagination
$sql = "
  SELECT id, postType, postPath, phone, createdAt, updatedAt, userName
  FROM [flutterApplicationBackend].[dbo].[Postmaster]
  ORDER BY id DESC
  OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
";

// Prepare and execute query with correct parameters
$params = [$offset, $limit];
$stmt = sqlsrv_prepare($conn, $sql, $params);
if (!$stmt) {
    echo json_encode([
        "status" => 500,
        "message" => "Query preparation failed",
        "error" => sqlsrv_errors()
    ]);
    exit;
}

if (!sqlsrv_execute($stmt)) {
    echo json_encode([
        "status" => 500,
        "message" => "Query execution failed",
        "error" => sqlsrv_errors()
    ]);
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
        "username" => $row['userName'],
        "createdAt" => $row['createdAt'] instanceof DateTime ? $row['createdAt']->format('Y-m-d H:i:s') : $row['createdAt'],
        "updatedAt" => $row['updatedAt'] instanceof DateTime ? $row['updatedAt']->format('Y-m-d H:i:s') : $row['updatedAt'],
    ];
}

// Free the statement resource
sqlsrv_free_stmt($stmt);

// Get total count for pagination metadata
$totalCountSql = "SELECT COUNT(*) as total FROM [flutterApplicationBackend].[dbo].[Postmaster]";
$totalStmt = sqlsrv_query($conn, $totalCountSql);
if ($totalStmt === false) {
    echo json_encode([
        "status" => 500,
        "message" => "Total count query failed",
        "error" => sqlsrv_errors()
    ]);
    exit;
}

$totalRow = sqlsrv_fetch_array($totalStmt, SQLSRV_FETCH_ASSOC);
$totalRecords = $totalRow['total'];
$totalPages = ceil($totalRecords / $limit);

// Free the total count statement resource
sqlsrv_free_stmt($totalStmt);

// Return JSON response with pagination details
if (!empty($posts)) {
    echo json_encode([
        "status" => 200,
        "message" => "Posts Found",
        "data" => $posts,
        "pagination" => [
            "page" => $page,
            "limit" => $limit,
            "totalRecords" => $totalRecords,
            "totalPages" => $totalPages
        ]
    ]);
} else {
    echo json_encode([
        "status" => 404,
        "message" => "No posts found for page $page",
        "pagination" => [
            "page" => $page,
            "limit" => $limit,
            "totalRecords" => $totalRecords,
            "totalPages" => $totalPages
        ]
    ]);
}

?>