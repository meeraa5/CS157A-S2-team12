package dao;

import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import util.MySQLCon;
import util.RestockHistory;

public class RestockHistoryDao {
    private final static String newHistoryStr = 
    		"INSERT INTO restock_history(restock_id, product_id, admin_id, quantity_added, restock_id) VALUES (?, ?, ?, ?, ?,);";   
    private final static String getLatestHist = "SELECT MAX(restock_id) FROM restock_history;";
    private final static String getAdmin = "SELECT created_by_admin_id FROM products WHERE product_id = ?";
    
    public static int getLatestId(){ // use for new restock
        int theNum = 0;
        
		try {
			Connection con = MySQLCon.getConnection();
	        PreparedStatement latestIdPs;
			latestIdPs = con.prepareStatement(getLatestHist);
			ResultSet rs = latestIdPs.executeQuery();
	        if (rs.getNext()){
	            theNum = rs.getInt("restock_id") + 1;
	        }
		} catch (SQLException e) {
			e.printStackTrace();
		}
        return theNum;
    }
    
    public static int getAdminId(int prod_id){ // use for new restock
        int theNum = 0;
        
		try {
			Connection con = MySQLCon.getConnection();
	        PreparedStatement adminIdPs;
			adminIdPs = con.prepareStatement(getAdmin);
			adminIdPs.setInt(1, prod_id);
			
			ResultSet rs = adminIdPs.executeQuery();
			
	        theNum = rs.getInt("created_by_admin_id");
	        con.close();
	        
		} catch (SQLException e) {
			e.printStackTrace();
		}
        return theNum;
    }
    
    public static void newHistory(RestockHistory hist) throws SQLException {
    	try {
            Connection con = MySQLCon.getConnection();
            PreparedStatement newHistPs = con.prepareStatement(newHistoryStr);
            
            newHistPs.setInt(1, getLatestId());
            hist.setRestockId(getLatestId()); // set the id
            
            newHistPs.setInt(2, hist.getResProductId());
            newHistPs.setInt(3, getAdminId(hist.getResProductId()));
            hist.setResAdminId(getAdminId(hist.getResProductId())); // set admin id
            
            newHistPs.setInt(4, hist.getResQuantityAdded());
            
            newHistPs.setDate(5, java.sql.Date.valueOf(hist.getRestockDate()));
            newHistPs.executeUpdate();
            con.close();
            
            
    	} catch (SQLException e) {
        	e.printStackTrace();
        }
    }
    
}
