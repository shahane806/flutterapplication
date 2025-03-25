<?php
header('Content-Type: application/json');

require_once "../Connection/conn.php";
require_once "../Operations/Operations.php";

// Check database connection
if (!$conn) {
    echo json_encode(["status" => 500, "message" => "Database connection failed"]);
    exit;
}

// Get POST data with proper sanitization
$BIO = isset($_POST['USER_BIO']) ? trim($_POST['USER_BIO']) : '';
$MOBILE = isset($_POST['MOBILE']) ? trim($_POST['MOBILE']) : '';
$FUNCTION_TYPE = isset($_POST['FUNCTION_TYPE']) ? trim($_POST['FUNCTION_TYPE']) : '';
$POST_FILE = isset($_FILES['PROFILE_PICTURE']) ? $_FILES['PROFILE_PICTURE'] : null;

// Validate required fields for insert/update operations
if (in_array($FUNCTION_TYPE, ['insertUserProfileData', 'updateUserProfileData'])) {
    if (empty($MOBILE) || empty($BIO) || !$POST_FILE || $POST_FILE['error'] === UPLOAD_ERR_NO_FILE) {
        echo json_encode(["status" => 400, "message" => "Missing required fields"]);
        exit;
    }
}

switch ($FUNCTION_TYPE) {
    case "insertUserProfileData":
        // File upload handling
        $uploadDir = "uploads/profileData/" . $MOBILE . "/";
        if (!file_exists($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        $fileName = basename($POST_FILE['name']);
        $targetFilePath = $uploadDir . $fileName;
        $fileSize = $POST_FILE['size'];
        $counter = 1;

        // Handle duplicate filenames
        while (file_exists($targetFilePath)) {
            $targetFilePath = $uploadDir . $counter . '_' . $fileName;
            $counter++;
        }

        // Move uploaded file and insert into database
        if (move_uploaded_file($POST_FILE['tmp_name'], $targetFilePath)) {
            $query = "INSERT INTO dbo.userProfile (profilePicturePath, profilePictureSize, bio, phone) VALUES (?, ?, ?, ?)";
            $params = array($targetFilePath, $fileSize, $BIO, $MOBILE);
            $result = sqlsrv_query($conn, $query, $params);

            if ($result === false) {
                unlink($targetFilePath); // Clean up uploaded file on DB failure
                echo json_encode([
                    "status" => 500, 
                    "message" => "Database insertion failed", 
                    "error" => sqlsrv_errors()
                ]);
                exit;
            }

            echo json_encode([
                "status" => 200, 
                "message" => "Profile created successfully", 
                "file_path" => $targetFilePath
            ]);
        } else {
            echo json_encode(["status" => 500, "message" => "Error uploading file"]);
        }
        break;

    case "updateUserProfileData":
        if (!$MOBILE) {
            echo json_encode(["status" => 400, "message" => "Mobile number required for update"]);
            exit;
        }

        $uploadDir = "uploads/profileData/" . $MOBILE . "/";
        if (!file_exists($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        $fileName = basename($POST_FILE['name']);
        $targetFilePath = $uploadDir . $fileName;
        $fileSize = $POST_FILE['size'];
        $counter = 1;

        while (file_exists($targetFilePath)) {
            $targetFilePath = $uploadDir . $counter . '_' . $fileName;
            $counter++;
        }

        if (move_uploaded_file($POST_FILE['tmp_name'], $targetFilePath)) {
            $query = "UPDATE dbo.userProfile SET profilePicturePath = ?, profilePictureSize = ?, bio = ? WHERE phone = ?";
            $params = array($targetFilePath, $fileSize, $BIO, $MOBILE);
            $result = sqlsrv_query($conn, $query, $params);

            if ($result === false) {
                unlink($targetFilePath);
                echo json_encode([
                    "status" => 500, 
                    "message" => "Database update failed", 
                    "error" => sqlsrv_errors()
                ]);
                exit;
            }

            echo json_encode([
                "status" => 200, 
                "message" => "Profile updated successfully", 
                "file_path" => $targetFilePath
            ]);
        } else {
            echo json_encode(["status" => 500, "message" => "Error uploading file"]);
        }
        break;

    case "getUserProfileData":
        if (!$MOBILE) {
            echo json_encode(["status" => 400, "message" => "Mobile number required"]);
            exit;
        }

        $query = "SELECT profilePicturePath, profilePictureSize, bio, phone FROM dbo.userProfile WHERE phone = ?";
        $params = array($MOBILE);
        $result = sqlsrv_query($conn, $query, $params);

        if ($result === false) {
            echo json_encode([
                "status" => 500, 
                "message" => "Database query failed", 
                "error" => sqlsrv_errors()
            ]);
            exit;
        }

        $row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC);
        if ($row) {
            echo json_encode([
                "status" => 200,
                "message" => "Profile retrieved successfully",
                "data" => $row
            ]);
        } else {
            echo json_encode([
                "status" => 404,
                "message" => "Profile not found"
            ]);
        }
        sqlsrv_free_stmt($result);
        break;

    default:
        echo json_encode(["status" => 400, "message" => "Invalid function type"]);
        break;
}


?>