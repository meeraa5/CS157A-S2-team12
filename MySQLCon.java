import java.sql.*;
public class MySQLCon {
	public static void main(String[] args) {
		

		        try {
		            Class.forName("com.mysql.cj.jdbc.Driver");

		       Connection con = DriverManager.getConnection(
		                "jdbc:mysql://localhost:3306/desouza?useSSL=false&serverTimezone=UTC",
		                "root",
		                "11321132"
		            );

		            Statement stmt = con.createStatement();
		            ResultSet rs = stmt.executeQuery("SELECT * FROM Student");

		            while (rs.next()) {
		                System.out.println(
		                    rs.getInt(1) + " " +
		                    rs.getString(2) + " " +
		                    rs.getString(3)
		                );
		            }

		            rs.close();
		            stmt.close();
		            con.close();

		        } catch (Exception e) {
		            e.printStackTrace();
		        }
		
	}

}
