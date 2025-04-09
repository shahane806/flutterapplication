<?php
// Set response header to JSON
header('Content-Type: application/json');

// Include required files for database connection and operations
require_once "../Connection/conn.php";
require_once "../Operations/Operations.php";

// Check if connection is established
if (!$conn) {
    echo json_encode([
        "status" => 500,
        "message" => "Database connection failed",
        "debug" => ["connection_error" => sqlsrv_errors()]
    ]);
    exit;
}

// Initialize variables from POST data with better null handling
$MOBILE = isset($_POST['MOBILE']) && !empty(trim($_POST['MOBILE'])) ? trim($_POST['MOBILE']) : null;
$QUERY = isset($_POST['QUERY']) ? trim($_POST['QUERY']) : '';
$PAGE = isset($_POST['PAGE']) && is_numeric($_POST['PAGE']) ? intval($_POST['PAGE']) : 1;
$PAGE_SIZE = isset($_POST['PAGE_SIZE']) && is_numeric($_POST['PAGE_SIZE']) ? intval($_POST['PAGE_SIZE']) : 10;

// Validate required inputs
if (is_null($MOBILE)) {
    echo json_encode([
        "status" => 400,
        "message" => "Missing or invalid required parameter: MOBILE",
        "debug" => ["received_data" => $_POST]
    ]);
    exit;
}

if (empty($QUERY)) {
    echo json_encode([
        "status" => 400,
        "message" => "Search query cannot be empty",
        "debug" => ["received_data" => $_POST]
    ]);
    exit;
}

// Prepare search term (case-insensitive) with wildcard for broader matching
$searchTerm = '%' . $QUERY . '%';
error_log("Search query: " . $QUERY);
error_log("Mobile: " . $MOBILE);

// Search users (case-insensitive, broader search)
$userSql = "SELECT id, profilePicturePath, profilePictureSize, bio, phone, createdAt, updatedAt, userName
            FROM [dbo].[userProfile] 
            WHERE (UPPER(userName) LIKE UPPER(?) OR UPPER(phone) LIKE UPPER(?))
            ORDER BY userName
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

$userParams = [$searchTerm, $searchTerm, ($PAGE - 1) * $PAGE_SIZE, $PAGE_SIZE];
$stmtUsers = sqlsrv_prepare($conn, $userSql, $userParams);

if ($stmtUsers === false) {
    error_log("User query preparation failed: " . print_r(sqlsrv_errors(), true));
    echo json_encode([
        "status" => 500,
        "message" => "Query preparation failed for user search",
        "debug" => [
            "sql" => $userSql,
            "params" => $userParams,
            "error" => sqlsrv_errors()
        ]
    ]);
    exit;
}

if (sqlsrv_execute($stmtUsers) === false) {
    error_log("User query execution failed: " . print_r(sqlsrv_errors(), true));
    echo json_encode([
        "status" => 500,
        "message" => "Query execution failed for user search",
        "debug" => [
            "sql" => $userSql,
            "params" => $userParams,
            "error" => sqlsrv_errors()
        ]
    ]);
    exit;
}

// Collect user results
$users = [];
while ($row = sqlsrv_fetch_array($stmtUsers, SQLSRV_FETCH_ASSOC)) {
    $users[] = [
        'id' => $row['id'],
        'profilePicturePath' => $row['profilePicturePath'] ?? '',
        'profilePictureSize' => $row['profilePictureSize'] ?? '',
        'bio' => $row['bio'] ?? '',
        'phone' => $row['phone'],
        'createdAt' => $row['createdAt'] instanceof DateTime ? $row['createdAt']->format('Y-m-d H:i:s') : ($row['createdAt'] ?? ''),
        'updatedAt' => $row['updatedAt'] instanceof DateTime ? $row['updatedAt']->format('Y-m-d H:i:s') : ($row['updatedAt'] ?? ''),
        'userName' => $row['userName'] ?? ''
    ];
}
error_log("Users found: " . count($users));

// Count total users
$countUserSql = "SELECT COUNT(*) as total 
                FROM [dbo].[userProfile]
                WHERE (UPPER(userName) LIKE UPPER(?) OR UPPER(phone) LIKE UPPER(?))";
$countUserParams = [$searchTerm, $searchTerm];
$stmtCountUsers = sqlsrv_query($conn, $countUserSql, $countUserParams);

if ($stmtCountUsers === false) {
    error_log("User count query failed: " . print_r(sqlsrv_errors(), true));
    $totalUsers = 0;
} else {
    $totalUsers = sqlsrv_fetch_array($stmtCountUsers, SQLSRV_FETCH_ASSOC)['total'] ?? 0;
}
$totalUserPages = ceil($totalUsers / $PAGE_SIZE);
error_log("Total users: " . $totalUsers);

// Search posts (case-insensitive, broader search)
$postSql = "SELECT p.id, p.postPath, p.postType, p.content, p.phone, p.createdAt, u.userName
            FROM [dbo].[Postmaster] p
            LEFT JOIN [dbo].[userProfile] u ON p.phone = u.phone
            WHERE (UPPER(p.content) LIKE UPPER(?) OR UPPER(u.userName) LIKE UPPER(?))
            ORDER BY p.createdAt DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

$postParams = [$searchTerm, $searchTerm, ($PAGE - 1) * $PAGE_SIZE, $PAGE_SIZE];
$stmtPosts = sqlsrv_prepare($conn, $postSql, $postParams);

if ($stmtPosts === false) {
    error_log("Post query preparation failed: " . print_r(sqlsrv_errors(), true));
    echo json_encode([
        "status" => 500,
        "message" => "Query preparation failed for post search",
        "debug" => [
            "sql" => $postSql,
            "params" => $postParams,
            "error" => sqlsrv_errors()
        ]
    ]);
    exit;
}

if (sqlsrv_execute($stmtPosts) === false) {
    error_log("Post query execution failed: " . print_r(sqlsrv_errors(), true));
    echo json_encode([
        "status" => 500,
        "message" => "Query execution failed for post search",
        "debug" => [
            "sql" => $postSql,
            "params" => $postParams,
            "error" => sqlsrv_errors()
        ]
    ]);
    exit;
}

// Collect post results
$posts = [];
while ($row = sqlsrv_fetch_array($stmtPosts, SQLSRV_FETCH_ASSOC)) {
    $posts[] = [
        'id' => $row['id'],
        'postPath' => $row['postPath'] ?? '',
        'postType' => $row['postType'] ?? '',
        'content' => $row['content'] ?? '',
        'phone' => $row['phone'] ?? '',
        'username' => $row['userName'] ?? '',
        'createdAt' => $row['createdAt'] instanceof DateTime ? $row['createdAt']->format('Y-m-d H:i:s') : ($row['createdAt'] ?? '')
    ];
}
error_log("Posts found: " . count($posts));

// Count total posts
$countPostSql = "SELECT COUNT(*) as total 
                FROM [dbo].[Postmaster] p
                LEFT JOIN [dbo].[userProfile] u ON p.phone = u.phone
                WHERE (UPPER(p.content) LIKE UPPER(?) OR UPPER(u.userName) LIKE UPPER(?))";
$countPostParams = [$searchTerm, $searchTerm];
$stmtCountPosts = sqlsrv_query($conn, $countPostSql, $countPostParams);

if ($stmtCountPosts === false) {
    error_log("Post count query failed: " . print_r(sqlsrv_errors(), true));
    $totalPosts = 0;
} else {
    $totalPosts = sqlsrv_fetch_array($stmtCountPosts, SQLSRV_FETCH_ASSOC)['total'] ?? 0;
}
$totalPostPages = ceil($totalPosts / $PAGE_SIZE);
error_log("Total posts: " . $totalPosts);

// Prepare response with detailed debug info
$response = [
    "status" => 200,
    "message" => "Search results retrieved successfully",
    "data" => [
        "users" => $users,
        "posts" => $posts
    ],
    "debug" => [
        "query" => $QUERY,
        "mobile" => $MOBILE,
        "user_count" => count($users),
        "post_count" => count($posts),
        "total_users" => $totalUsers,
        "total_posts" => $totalPosts,
        "user_sql" => $userSql,
        "post_sql" => $postSql
    ],
    "pagination" => [
        "users" => [
            "currentPage" => $PAGE,
            "totalPages" => $totalUserPages,
            "totalItems" => $totalUsers,
            "pageSize" => $PAGE_SIZE
        ],
        "posts" => [
            "currentPage" => $PAGE,
            "totalPages" => $totalPostPages,
            "totalItems" => $totalPosts,
            "pageSize" => $PAGE_SIZE
        ]
    ]
];

// Log the full response
error_log("Search response: " . json_encode($response));

// Return response
echo json_encode($response);

// Free statements and close connection
sqlsrv_free_stmt($stmtUsers);
sqlsrv_free_stmt($stmtPosts);
if ($stmtCountUsers !== false) sqlsrv_free_stmt($stmtCountUsers);
if ($stmtCountPosts !== false) sqlsrv_free_stmt($stmtCountPosts);
sqlsrv_close($conn);
?>