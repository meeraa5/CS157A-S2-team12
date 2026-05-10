package dao;

import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import util.MySQLCon;

public class UserDao {
    // These match the 'status' column we just added and 'user_id' from your screenshot
    private static final String reactivate = "UPDATE users SET status = 'Active' WHERE user_id = ?;";
    private static final String suspend = "UPDATE users SET status = 'Suspended' WHERE user_id = ?;";
    
    public static void reactivateUser(int id) throws SQLException { 
        try (Connection con = MySQLCon.getConnection();
             PreparedStatement ps = con.prepareStatement(reactivate)) {
            ps.setInt(1, id);
            ps.executeUpdate();
            System.out.println("DEBUG: User " + id + " set to Active");
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
    }
    
    public static void suspendUser(int id) throws SQLException { 
        try (Connection con = MySQLCon.getConnection();
             PreparedStatement ps = con.prepareStatement(suspend)) {
            ps.setInt(1, id);
            ps.executeUpdate();
            System.out.println("DEBUG: User " + id + " set to Suspended");
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
    }
}