<?php
// Set response header to JSON
header('Content-Type: application/json');
require_once "../Connection/conn.php";

$API_TYPE = $_POST['API_TYPE'] ?? null;
$POST_ID = $_POST['POST_ID'] ?? null;
$MOBILE = $_POST['MOBILE'] ?? null;

if (!$POST_ID || !$MOBILE) {
    echo json_encode(["status" => 400, "message" => "POST_ID and MOBILE are required"]);
    exit;
}

if ($API_TYPE == "liked") {
    // Check if the user already liked the post
    $checkQuery = "SELECT * FROM dbo.LikeMaster WHERE postId = ? AND phone = ?";
    $checkParams = array($POST_ID, $MOBILE);
    $checkStmt = sqlsrv_query($conn, $checkQuery, $checkParams);

    if ($checkStmt === false) {
        echo json_encode(["status" => 500, "message" => "Error checking like status", "error" => sqlsrv_errors()]);
        exit;
    }

    if (sqlsrv_has_rows($checkStmt)) {
        // User already liked, do nothing
        echo json_encode(["status" => 409, "message" => "User already liked this post"]);
        exit;
    }
    
    // Like the post
    $likeQuery = "INSERT INTO dbo.LikeMaster (postId, phone) VALUES (?, ?)";
    $likeParams = array($POST_ID, $MOBILE);
    $likeStmt = sqlsrv_query($conn, $likeQuery, $likeParams);

    if ($likeStmt === false) {
        echo json_encode(["status" => 500, "message" => "Failed to add like", "error" => sqlsrv_errors()]);
        exit;
    }

    sqlsrv_free_stmt($likeStmt);
}

elseif ($API_TYPE == "DisLikedPost") {
    // Remove like for the specific user
    $query = "DELETE FROM dbo.LikeMaster WHERE postId = ? AND phone = ?";
    $params = array($POST_ID, $MOBILE);
    $stmt = sqlsrv_query($conn, $query, $params);

    if ($stmt === false) {
        echo json_encode(["status" => 500, "message" => "Failed to dislike post", "error" => sqlsrv_errors()]);
        exit;
    }

    $rows_affected = sqlsrv_rows_affected($stmt);

    if ($rows_affected > 0) {
        echo json_encode(["status" => 200, "message" => "Post disliked successfully"]);
    } else {
        echo json_encode(["status" => 404, "message" => "No like record found for this user"]);
    }

    sqlsrv_free_stmt($stmt);
}

// Get the total like count
$countQuery = "SELECT COUNT(*) AS likeCount FROM dbo.LikeMaster WHERE postId = ?";
$countParams = array($POST_ID);
$countStmt = sqlsrv_query($conn, $countQuery, $countParams);

if ($countStmt === false) {
    echo json_encode(["status" => 500, "message" => "Failed to get like count", "error" => sqlsrv_errors()]);
    exit;
}

$row = sqlsrv_fetch_array($countStmt, SQLSRV_FETCH_ASSOC);
$totalLikes = $row['likeCount'];

sqlsrv_free_stmt($countStmt);

echo json_encode([
    "status" => 200,
    "message" => "Action successful",
    "likeCount" => $totalLikes
]);
?>
