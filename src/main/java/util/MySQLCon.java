package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class MySQLCon {

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            String url = getConfig("DB_URL", "jdbc:mysql://localhost:3306/spartanexchange?useSSL=false&serverTimezone=UTC");
            String user = getConfig("DB_USER", "root");
            String password = getConfig("DB_PASSWORD", "");

            return DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("MySQL JDBC driver was not found. Add mysql-connector-j to Tomcat.", e);
        } catch (SQLException e) {
            throw new IllegalStateException("Unable to connect to MySQL. Check DB_URL, DB_USER, and DB_PASSWORD.", e);
        }
    }

    private static String getConfig(String key, String defaultValue) {
        String value = System.getenv(key);
        if (value == null || value.trim().isEmpty()) {
            value = System.getProperty(key);
        }
        return value == null || value.trim().isEmpty() ? defaultValue : value;
    }
}