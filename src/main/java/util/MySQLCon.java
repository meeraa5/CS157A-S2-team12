package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class MySQLCon {

    private static final String URL =
        "jdbc:mysql://localhost:3306/spartanexchange?useSSL=false&serverTimezone=UTC";

    private static final String USER = "root";
    private static final String PASSWORD = "11321132";

    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        System.out.println("CONNECTED TO DB");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}