<?php
header('Content-Type: application/json');

require_once "../Connection/conn.php";
require_once "../Operations/Operations.php";

// Check if connection is established
if (!$conn) {
    echo json_encode(["status" => 500, "message" => "Database connection failed"]);
    exit;
}

// Initialize variables
$MOBILE       = $_POST['MOBILE'] ?? null;
$POST_TYPE    = $_POST['POST_TYPE'] ?? null;
$POST_PATH    = $_POST['POST_PATH'] ?? null;
$POST_COMMENT = $_POST['POST_COMMENT'] ?? null;
$POST_FILE    = $_FILES['file'] ?? null;
$POST_TITLE   = $_POST['POST_TITLE'] ?? null;
$POST_MESSAGE = $_POST['POST_MESSAGE'] ?? null;
$POST_ID      = $_POST['POST_ID'] ?? null;
$API_TYPE     = $_POST['API_TYPE'] ?? null;
$USERNAME     = $_POST['USERNAME'] ?? null; // Added USERNAME field

// Validate required fields
if (!$MOBILE) {
    echo json_encode(["status" => 400, "message" => "Missing required fields"]);
    exit;
}

if ($POST_TYPE == "video" && $POST_FILE) {
    $uploadDir = "uploads/videos/$MOBILE/";
    if ($POST_FILE['error'] === 0) {
        if (!file_exists($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
    }

    $fileName = basename($POST_FILE['name']);
    $targetFilePath = $uploadDir . $fileName;
    $counter = 1;
    while (file_exists($targetFilePath)) {
        $targetFilePath = $uploadDir . $counter . '_' . $fileName;
        $counter++;
    }

    if (move_uploaded_file($POST_FILE['tmp_name'], $targetFilePath)) {
        $query = "INSERT INTO dbo.Postmaster (postType, postPath, phone, userName) VALUES (?, ?, ?, ?)"; // Added userName
        $params = array($POST_TYPE, $targetFilePath, $MOBILE, $USERNAME); // Added USERNAME to params
        $result = sqlsrv_query($conn, $query, $params);

        if ($result === false) {
            echo json_encode(["status" => 500, "message" => "Path Uploadation Failed", "error" => sqlsrv_errors()]);
            exit;
        }

        echo json_encode(["status" => 200, "message" => "File uploaded successfully", "file_path" => $targetFilePath]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error moving the uploaded file"]);
    }
} elseif ($POST_TYPE == "image" && $POST_FILE) {
    $uploadDir = "uploads/images/$MOBILE/";
    if ($POST_FILE['error'] === 0) {
        if (!file_exists($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
    }

    $fileName = basename($POST_FILE['name']);
    $targetFilePath = $uploadDir . $fileName;
    $counter = 1;
    while (file_exists($targetFilePath)) {
        $targetFilePath = $uploadDir . $counter . '_' . $fileName;
        $counter++;
    }

    if (move_uploaded_file($POST_FILE['tmp_name'], $targetFilePath)) {
        $query = "INSERT INTO dbo.Postmaster (postType, postPath, phone, userName) VALUES (?, ?, ?, ?)"; // Added userName
        $params = array($POST_TYPE, $targetFilePath, $MOBILE, $USERNAME); // Added USERNAME to params
        $result = sqlsrv_query($conn, $query, $params);

        if ($result === false) {
            echo json_encode(["status" => 500, "message" => "Path Uploadation Failed", "error" => sqlsrv_errors()]);
            exit;
        }

        echo json_encode(["status" => 200, "message" => "File uploaded successfully", "file_path" => $targetFilePath]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error moving the uploaded file"]);
    }
} else if ($POST_TYPE == "textPost") {
    $query = "INSERT INTO [dbo].[TextPost] (postType, phone, title, message, userName) VALUES (?, ?, ?, ?, ?)"; // Added userName
    $params = array($POST_TYPE, $MOBILE, $POST_TITLE, $POST_MESSAGE, $USERNAME); // Added USERNAME to params
    $result = sqlsrv_query($conn, $query, $params);

    if ($result === false) {
        echo json_encode(["status" => 500, "message" => "TextPost Insertion Failed", "error" => sqlsrv_errors()]);
        exit;
    }

    echo json_encode(["status" => 200, "message" => "TextPost added successfully", "PostTitle" => $POST_TITLE]);
} else if ($API_TYPE == "liked") {
    // Check if the user already liked the post
    $checkQuery = "SELECT * FROM dbo.LikeMaster WHERE postId = ? AND phone = ?";
    $checkParams = array($POST_ID, $MOBILE);
    $checkStmt = sqlsrv_query($conn, $checkQuery, $checkParams);

    if ($checkStmt === false) {
        echo json_encode(["status" => 500, "message" => "Error checking like status", "error" => sqlsrv_errors()]);
        exit;
    }

    // If not already liked, insert the like
    if (!sqlsrv_has_rows($checkStmt)) {
        $insertQuery = "INSERT INTO dbo.LikeMaster (postId, postType, postPath, phone) VALUES (?, ?, ?, ?)";
        $insertParams = array($POST_ID, $POST_TYPE, $POST_PATH, $MOBILE);
        $insertStmt = sqlsrv_query($conn, $insertQuery, $insertParams);

        if ($insertStmt === false) {
            echo json_encode(["status" => 500, "message" => "Like Insertion Failed", "error" => sqlsrv_errors()]);
            exit;
        }

        sqlsrv_free_stmt($insertStmt);
    }

    sqlsrv_free_stmt($checkStmt);

    echo json_encode(["status" => 200, "message" => "Like added successfully"]);
}

// DISLIKE action
else if ($API_TYPE == "DisLikedPost") {
    // Remove the like for the specific user only
    $deleteQuery = "DELETE FROM dbo.LikeMaster WHERE postId = ? AND phone = ?";
    $deleteParams = array($POST_ID, $MOBILE);
    $deleteStmt = sqlsrv_query($conn, $deleteQuery, $deleteParams);

    if ($deleteStmt === false) {
        echo json_encode(["status" => 500, "message" => "Failed to remove like", "error" => sqlsrv_errors()]);
        exit;
    }

    sqlsrv_free_stmt($deleteStmt);

    echo json_encode(["status" => 200, "message" => "Like removed successfully"]);
}

// Get the total like count for the post
else if ($API_TYPE == "getLikeCount") {
    $countQuery = "SELECT COUNT(*) AS likeCount FROM dbo.LikeMaster WHERE postId = ?";
    $countParams = array($POST_ID);
    $countStmt = sqlsrv_query($conn, $countQuery, $countParams);

    if ($countStmt === false) {
        echo json_encode(["status" => 500, "message" => "Failed to get like count", "error" => sqlsrv_errors()]);
        exit;
    }

    $countRow = sqlsrv_fetch_array($countStmt, SQLSRV_FETCH_ASSOC);
    $totalLikes = $countRow['likeCount'];

    sqlsrv_free_stmt($countStmt);

    echo json_encode([
        "status" => 200,
        "likeCount" => $totalLikes
    ]);
}

elseif ($API_TYPE == "bookedMarked") {
    $query = "INSERT INTO dbo.BookedMarkMaster (postId, postType, postPath, phone) VALUES (?, ?, ?, ?)";
    $params = array($POST_ID, $POST_TYPE, $POST_PATH, $MOBILE);
    $result = sqlsrv_query($conn, $query, $params);

    if ($result === false) {
        echo json_encode(["status" => 500, "message" => "Bookmark Insertion Failed", "error" => sqlsrv_errors()]);
        exit;
    }

    echo json_encode(["status" => 200, "message" => "Bookmark added successfully", "file_path" => $POST_PATH]);
} elseif ($API_TYPE == "comment") {
    $query = "INSERT INTO dbo.CommentMaster (postId, postType, postPath, phone, comment) VALUES (?, ?, ?, ?, ?)";
    $params = array($POST_ID, $POST_TYPE, $POST_PATH, $MOBILE, $POST_COMMENT);
   
    $result = sqlsrv_query($conn, $query, $params);
    if ($result === false) {
        echo json_encode(["status" => 500, "message" => "Comment Insertion Failed", "error" => sqlsrv_errors()]);
        exit;
    }

    echo json_encode(["status" => 200, "message" => "Comment added successfully", "file_path" => $POST_PATH]);
} elseif ($POST_TYPE == "deleteComment") {
    $COMMENT_ID = $_POST['COMMENT_ID'] ?? null;
    $query = "DELETE FROM dbo.CommentMaster WHERE commentId = ?";
    $params = array($COMMENT_ID);
    $result = sqlsrv_query($conn, $query, $params);

    if ($result === false) {
        echo json_encode(["status" => 500, "message" => "Comment Deletion Failed", "error" => sqlsrv_errors()]);
        exit;
    }

    $rows_affected = sqlsrv_rows_affected($result);
    if ($rows_affected > 0) {
        echo json_encode(["status" => 200, "message" => "Comment deleted successfully"]);
    } else {
        echo json_encode(["status" => 404, "message" => "No comment found with the specified ID"]);
    }
} elseif ($POST_TYPE == "updateComment") {
    $COMMENT_ID = $_POST['COMMENT_ID'] ?? null;
    $query = "UPDATE dbo.CommentMaster SET postType = ?, postPath = ?, phone = ?, comment = ? WHERE commentId = ?";
    $params = array($POST_TYPE, $POST_PATH, $MOBILE, $POST_COMMENT, $COMMENT_ID);
    $result = sqlsrv_query($conn, $query, $params);

    if ($result === false) {
        echo json_encode(["status" => 500, "message" => "Comment Update Failed", "error" => sqlsrv_errors()]);
        exit;
    }

    $rows_affected = sqlsrv_rows_affected($result);
    if ($rows_affected > 0) {
        echo json_encode(["status" => 200, "message" => "Comment updated successfully", "file_path" => $POST_PATH]);
    } else {
        echo json_encode(["status" => 404, "message" => "No comment found with the specified ID"]);
    }
} elseif ($POST_TYPE == "deletePost") {
    $POST_ID = $_POST['POST_ID'] ?? null;
    $query = "DELETE FROM dbo.Postmaster WHERE postId = ?";
    $params = array($POST_ID);
    $result = sqlsrv_query($conn, $query, $params);

    if ($result === false) {
        echo json_encode(["status" => 500, "message" => "Post Deletion Failed", "error" => sqlsrv_errors()]);
        exit;
    }

    $rows_affected = sqlsrv_rows_affected($result);
    if ($rows_affected > 0) {
        echo json_encode(["status" => 200, "message" => "Post deleted successfully"]);
    } else {
        echo json_encode(["status" => 404, "message" => "No post found with the specified ID"]);
    }
} elseif ($POST_TYPE == "deletebookedMarked") {
    $POST_ID = $_POST['POST_ID'] ?? null;
    $query = "DELETE FROM dbo.BookedMarkMaster WHERE postId = ? AND phone = ?"; // Fixed syntax error (missing =)
    $params = array($POST_ID, $MOBILE);
    $result = sqlsrv_query($conn, $query, $params);

    if ($result === false) {
        echo json_encode(["status" => 500, "message" => "Bookmark Deletion Failed", "error" => sqlsrv_errors()]);
        exit;
    }

    $rows_affected = sqlsrv_rows_affected($result);
    if ($rows_affected > 0) {
        echo json_encode(["status" => 200, "message" => "Bookmark deleted successfully"]);
    } else {
        echo json_encode(["status" => 404, "message" => "No bookmarked post found with the specified ID"]);
    }
} else {
    echo json_encode(["status" => 400, "message" => "No video file uploaded or invalid POST_TYPE"]);
}

?>