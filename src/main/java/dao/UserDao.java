package dao;

import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import util.MySQLCon;
import util.User;

public class UserDao {
	private static final String getSuspended = "SELECT * FROM users WHERE status = 'Deactivated' OR status = 'Suspended';";
	private static final String getActive = "SELECT * FROM users WHERE status = 'Active';";
	private static final String reactivate = "UPDATE users SET status = 'Active' WHERE user_id= ?;";
	private static final String suspend = "UPDATE users SET status = 'Suspended' WHERE user_id= ?;";
	
    public static List<User> selectAllUsers(String status){
    	List<User> susUsers = new ArrayList<>();
    	
    	try {
    		Connection con = MySQLCon.getConnection();
    		PreparedStatement listProdPs;
    		
    		if (status == "suspended") {
    			listProdPs = con.prepareStatement(getSuspended);
        	}
    		else {
    			listProdPs = con.prepareStatement(getActive);
    		}
    		
            
            ResultSet rs = listProdPs.executeQuery();
            while (rs.next()) {
            	int theId = rs.getInt("user_id");
                String theName = rs.getString("full_name");
                String theEmail = rs.getString("sjsu_email");
                String theStatus = rs.getString("status");
           
                User theProduct = new User(theId, theName, theEmail, theStatus);
                susUsers.add(theProduct);
            }
    	} catch (SQLException e) {
			e.printStackTrace();
		}
    	return susUsers;
    }
    
    public static void reactivateUser(int id) throws SQLException { // take in user id
    	try {
            Connection con = MySQLCon.getConnection();
            PreparedStatement reactivateProdPs = con.prepareStatement(reactivate); // switch status to Active based on user id
            
            reactivateProdPs.setInt(1, id);
            
            reactivateProdPs.executeUpdate();
            con.close();
            
    	} catch (SQLException e) {
         	e.printStackTrace();
        }
    }
    
    public static void suspendUser(int id) throws SQLException { // yes i know i couldve made it in the same method as above .. sue me...
    	try {
            Connection con = MySQLCon.getConnection();
            PreparedStatement suspendProdPs = con.prepareStatement(suspend);
            
            suspendProdPs.setInt(1, id);
            
            suspendProdPs.executeUpdate();
            con.close();
            
    	} catch (SQLException e) {
         	e.printStackTrace();
        }
    }
}
