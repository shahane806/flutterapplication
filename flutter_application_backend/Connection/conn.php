<?php

// Include the env_loader.php file to load environment variables
require_once 'F:\MegaProject\Flutter Application\flutter_application_backend\env_loader.php';
require_once 'F:\MegaProject\Flutter Application\flutter_application_backend\Operations\Operations.php';
// Load the .env file for environment variables
try {
    loadEnv('F:\MegaProject\Flutter Application\flutter_application_backend\.env'); // Load environment variables from the .env file
} catch (Exception $e) {
    die("Error: " . $e->getMessage()); // Error handling if .env file is not loaded
}

$dbHelper = new DatabaseHelper();
$dbHelper -> setConfig($_ENV['SERVER_NAME'],$_ENV['DATABASE_NAME'],$_ENV['DATABASE_USER'],$_ENV['DATABASE_PASSWORD']);
$conn = $dbHelper -> connectionDatabase();
