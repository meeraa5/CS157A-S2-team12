package dao;

import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;


import util.MySQLCon;
import util.User;

public class UserDao {
	private static final String reactivate = "UPDATE users SET status = 'Active' WHERE user_id= ?;";
	private static final String suspend = "UPDATE users SET status = 'Suspended' WHERE user_id= ?;";
	
    
    public static void reactivateUser(int id) throws SQLException { // take in user id
    	try
            (Connection con = MySQLCon.getConnection();
            PreparedStatement reactivateProdPs = con.prepareStatement(reactivate);){ // switch status to Active based on user id
            
            reactivateProdPs.setInt(1, id);
            
            reactivateProdPs.executeUpdate();
            
            reactivateProdPs.close();
            con.close();
            
    	} catch (SQLException e) {
         	e.printStackTrace();
        }
    }
    
    public static void suspendUser(int id) throws SQLException { // yes i know i couldve made it in the same method as above .. sue me...
    	try
            (Connection con = MySQLCon.getConnection();
            PreparedStatement suspendProdPs = con.prepareStatement(suspend);){
            
            suspendProdPs.setInt(1, id);
            
            suspendProdPs.executeUpdate();
            
            suspendProdPs.close();
            con.close();
            
    	} catch (SQLException e) {
         	e.printStackTrace();
        }
    }
}
