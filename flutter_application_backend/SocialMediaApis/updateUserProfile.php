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
$USERNAME = isset($_POST['USERNAME']) ? trim($_POST['USERNAME']) : '';
$MOBILE = isset($_POST['MOBILE']) ? trim($_POST['MOBILE']) : '';
$FUNCTION_TYPE = isset($_POST['FUNCTION_TYPE']) ? trim($_POST['FUNCTION_TYPE']) : '';
$POST_FILE = isset($_FILES['PROFILE_PICTURE']) ? $_FILES['PROFILE_PICTURE'] : null;

// Function to check if profile exists
function profileExists($conn, $mobile) {
    $query = "SELECT COUNT(*) as count FROM dbo.userProfile WHERE phone = ?";
    $params = array($mobile);
    $result = sqlsrv_query($conn, $query, $params);
    if ($result === false) {
        return false;
    }
    $row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC);
    sqlsrv_free_stmt($result);
    return $row['count'] > 0;
}

// Validate required fields based on whether profile exists
if (in_array($FUNCTION_TYPE, ['insertUserProfileData', 'updateUserProfileData'])) {
    if (empty($MOBILE)) {
        echo json_encode(["status" => 400, "message" => "Mobile number is required"]);
        exit;
    }

    $profileExists = profileExists($conn, $MOBILE);
    if ($FUNCTION_TYPE === 'insertUserProfileData' || !$profileExists) {
        // For initial insert or if no profile exists, all fields are required
        if (empty($BIO) || empty($USERNAME) || !$POST_FILE || $POST_FILE['error'] === UPLOAD_ERR_NO_FILE) {
            echo json_encode(["status" => 400, "message" => "Missing required fields for initial profile creation"]);
            exit;
        }
    } else {
        // For updates, allow partial updates if profile exists
        if (empty($BIO) && empty($USERNAME) && (!$POST_FILE || $POST_FILE['error'] === UPLOAD_ERR_NO_FILE)) {
            echo json_encode(["status" => 400, "message" => "At least one field (bio, username, or profile picture) must be provided for update"]);
            exit;
        }
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
            $query = "INSERT INTO dbo.userProfile (profilePicturePath, profilePictureSize, bio, phone, userName) VALUES (?, ?, ?, ?, ?)";
            $params = array($targetFilePath, $fileSize, $BIO, $MOBILE, $USERNAME);
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

        // Fetch existing profile data
        $existingQuery = "SELECT profilePicturePath, bio, userName FROM dbo.userProfile WHERE phone = ?";
        $existingParams = array($MOBILE);
        $existingResult = sqlsrv_query($conn, $existingQuery, $existingParams);
        if ($existingResult === false) {
            echo json_encode(["status" => 500, "message" => "Failed to fetch existing profile", "error" => sqlsrv_errors()]);
            exit;
        }
        $existingRow = sqlsrv_fetch_array($existingResult, SQLSRV_FETCH_ASSOC);
        sqlsrv_free_stmt($existingResult);

        if (!$existingRow) {
            echo json_encode(["status" => 404, "message" => "Profile not found"]);
            exit;
        }

        // Use existing values if new ones aren't provided
        $newBio = $BIO !== '' ? $BIO : $existingRow['bio'];
        $newUsername = $USERNAME !== '' ? $USERNAME : $existingRow['userName'];
        $newFilePath = $existingRow['profilePicturePath'];
        $newFileSize = null;

        if ($POST_FILE && $POST_FILE['error'] !== UPLOAD_ERR_NO_FILE) {
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
                $newFilePath = $targetFilePath;
                $newFileSize = $fileSize;
            } else {
                echo json_encode(["status" => 500, "message" => "Error uploading file"]);
                exit;
            }
        }

        $query = "UPDATE dbo.userProfile SET profilePicturePath = ?, profilePictureSize = ?, bio = ?, userName = ? WHERE phone = ?";
        $params = array($newFilePath, $newFileSize ?? $existingRow['profilePictureSize'], $newBio, $newUsername, $MOBILE);
        $result = sqlsrv_query($conn, $query, $params);

        if ($result === false) {
            if ($newFilePath !== $existingRow['profilePicturePath']) {
                unlink($newFilePath);
            }
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
            "file_path" => $newFilePath
        ]);
        break;

    case "getUserProfileData":
        if (!$MOBILE) {
            echo json_encode(["status" => 400, "message" => "Mobile number required"]);
            exit;
        }

        $query = "SELECT profilePicturePath, profilePictureSize, bio, phone, userName FROM dbo.userProfile WHERE phone = ?";
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