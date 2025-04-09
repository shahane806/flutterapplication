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

// Initialize variables from POST data
$MOBILE = $_POST['MOBILE'] ?? null;
$postId = $_POST['postId'] ?? null;
$postPath = $_POST['postPath'] ?? null;
$reportedUser = $_POST['reportedUser'] ?? null;
$reportedMessage = $_POST['reportedMessage'] ?? null;

// Validate required inputs
$requiredFields = ['MOBILE', 'postId', 'postPath', 'reportedMessage'];
foreach ($requiredFields as $field) {
    if (!isset($_POST[$field]) || empty(trim($_POST[$field]))) {
        echo json_encode(["status" => 400, "message" => "Missing required parameter: $field"]);
        exit;
    }
}

// Prepare SQL query to insert into ReportPostMaster
$sql = "
    INSERT INTO dbo.ReportPostMaster (postId, postPath, phone, reportedUser, reportedMessage)
    VALUES (?, ?, ?, ?, ?)
";

// Prepare parameters (reportedAt will use default GETDATE())
$params = array($postId, $postPath, $MOBILE, $reportedUser, $reportedMessage);

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


echo json_encode([
    "status" => 200,
    "message" => "Report inserted successfully",
]);

sqlsrv_close($conn);
?>