package util;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * JDBC helper — same pattern as AddToCartServlet. Configure DB via env vars or defaults.
 */
public final class MySQLCon {

	private static final String JDBC_URL = System.getenv().getOrDefault("SPARTAN_JDBC_URL",
			"jdbc:mysql://127.0.0.1:3306/spartanexchange?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true");
	private static final String JDBC_USER = System.getenv().getOrDefault("SPARTAN_DB_USER", "root");
	private static final String JDBC_PASS = System.getenv().getOrDefault("SPARTAN_DB_PASS", "");

	private MySQLCon() {
	}

	public static Connection getConnection() throws Exception {
		Class.forName("com.mysql.cj.jdbc.Driver");
		return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS);
	}
}
