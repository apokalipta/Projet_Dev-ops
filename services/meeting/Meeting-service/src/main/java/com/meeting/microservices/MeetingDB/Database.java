package com.meeting.microservices.MeetingDB;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Database {
    private static final String URL = System.getenv().getOrDefault("MEETING_DB_URL", "jdbc:mysql://localhost:3306/Meeting");
    private static final String USER = System.getenv().getOrDefault("MEETING_DB_USERNAME", "root");
    private static final String PASSWORD = System.getenv().getOrDefault("MEETING_DB_PASSWORD", "");
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
        // Default constructor kept for compatibility with existing usage patterns.
    }

    
}
