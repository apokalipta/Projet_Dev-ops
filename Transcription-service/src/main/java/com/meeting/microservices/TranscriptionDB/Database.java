package com.meeting.microservices.TranscriptionDB;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Database {
    private static final String URL = "jdbc:mysql://localhost:3306/Transcription";
    private static final String USER = "root";
    private static final String PASSWORD = "@SQLMaxLu2707!";
    private Connection conn;
    
    public String getURL() {
    	return URL;
    }
    public String getUSER() {
    	return USER;
    }
    public String getPASSWORD() {
    	return PASSWORD;	
    }
    
	public Connection getConn() {
		return conn;
	}
	public void setConn(Connection conn) {
		this.conn = conn;
	}

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
    
    
    
    public Database() {
    	
    }

    
}
