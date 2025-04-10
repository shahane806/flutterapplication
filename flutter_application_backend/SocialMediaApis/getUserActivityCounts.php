<?php
header('Content-Type: application/json');

require_once "../Connection/conn.php"; // Your database connection file

// Check if connection is established
if (!$conn) {
    echo json_encode([
        "status" => 500, 
        "message" => "Database connection failed"
    ]);
    exit;
}

// Get the phone number from the POST request
$phone = isset($_POST['phone']) ? trim($_POST['phone']) : '';

if (empty($phone)) {
    echo json_encode([
        "status" => 400, 
        "message" => "Phone number is required"
    ]);
    exit;
}

// Function to get bookmarked posts count
function getBookmarkedCount($conn, $phone) {
    $query = "SELECT COUNT(*) as bookmarked_count 
              FROM [flutterApplicationBackend].[dbo].[BookedMarkMaster] 
              WHERE phone = ?";
    $params = array($phone);
    $result = sqlsrv_query($conn, $query, $params);
    
    if ($result === false) {
        return -1; // Indicate error
    }
    
    $row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC);
    sqlsrv_free_stmt($result);
    return $row['bookmarked_count'] ?? 0;
}

// Function to get liked posts count
function getLikedCount($conn, $phone) {
    $query = "SELECT COUNT(*) as liked_count 
              FROM [flutterApplicationBackend].[dbo].[LikeMaster] 
              WHERE phone = ?";
    $params = array($phone);
    $result = sqlsrv_query($conn, $query, $params);
    
    if ($result === false) {
        return -1; // Indicate error
    }
    
    $row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC);
    sqlsrv_free_stmt($result);
    return $row['liked_count'] ?? 0;
}

// Function to get posts count
function getPostsCount($conn, $phone) {
    $query = "SELECT COUNT(*) as posts_count 
              FROM [flutterApplicationBackend].[dbo].[Postmaster] 
              WHERE phone = ?";
    $params = array($phone);
    $result = sqlsrv_query($conn, $query, $params);
    
    if ($result === false) {
        return -1; // Indicate error
    }
    
    $row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC);
    sqlsrv_free_stmt($result);
    return $row['posts_count'] ?? 0;
}

// Fetch counts
$bookmarkedCount = getBookmarkedCount($conn, $phone);
$likedCount = getLikedCount($conn, $phone);
$postsCount = getPostsCount($conn, $phone);

// Check for errors in query execution
if ($bookmarkedCount === -1 || $likedCount === -1 || $postsCount === -1) {
    echo json_encode([
        "status" => 500,
        "message" => "Error fetching counts",
        "error" => sqlsrv_errors()
    ]);
    exit;
}

// Return success response with counts
echo json_encode([
    "status" => 200,
    "message" => "Counts fetched successfully",
    "data" => [
        "bookmarked_count" => $bookmarkedCount,
        "liked_count" => $likedCount,
        "posts_count" => $postsCount
    ]
]);


?>