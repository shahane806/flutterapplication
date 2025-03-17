<?php

class DatabaseHelper {
    // Define private class properties
    private $serverName;
    private $databaseName;
    private $userName;
    private $password;
    public $conn;
    // Set the configuration for the database connection
    public function setConfig($sn, $dn, $un, $p) {
        // Assign values to the class properties using $this
        $this->serverName = $sn;
        $this->databaseName = $dn;
        $this->userName = $un;
        $this->password = $p;
    }
   
    // Method to establish a connection to the database
    public function connectionDatabase() {
        // Set up connection options using the class properties
        $connectionOptions = [
            "Database" => $this->databaseName, // Connect to the specific database
            "UID" => $this->userName,          // Username for authentication
            "PWD" => $this->password,          // Password for authentication
            "CharacterSet" => "UTF-8",         // Character set for the connection
        ];
        
        // Establish the connection using the sqlsrv_connect function
        $conn = sqlsrv_connect($this->serverName, $connectionOptions);
    
        // Check if the connection is successful
        if ($conn === false) {
            // If connection fails, display an error message
            // die(print("Database Not Connected!"));
        } else {
            // If connection is successful, display a success message
            // print("Database Connected!");
            return $conn;
        }
    }
}



