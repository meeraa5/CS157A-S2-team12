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

	private static final String newHistoryStr =
			"INSERT INTO restock_history (restock_id, product_id, admin_id, quantity_added, restock_date) VALUES (?, ?, ?, ?, ?)";

	private static final String getAdmin =
			"SELECT created_by_admin_id FROM products WHERE product_id = ?";
	
	private static final String getLatestIdStr = 
			"SELECT MAX(restock_id) FROM restock_history;";


	public static int getLatestResId(){ 
        int theNum = 1;
		try (Connection con = MySQLCon.getConnection();
				PreparedStatement latestIdPs = con.prepareStatement(getLatestIdStr);
				ResultSet rs = latestIdPs.executeQuery()) {
	        if (rs.next()) {
	        	int max = rs.getInt(1);
	        	theNum = max + 1;
            con.close();
            latestIdPs.close();
            rs.close();
	        }
        }
		 catch (SQLException e) {
			e.printStackTrace();
		}
        return theNum;
	}
	
	public static int getAdminId(int prodId) {
		try (Connection con = MySQLCon.getConnection();
				PreparedStatement ps = con.prepareStatement(getAdmin)) {
			
			ps.setInt(1, prodId);
			
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					int adminId = rs.getInt("created_by_admin_id");
					if (!rs.wasNull()) {
						return adminId;
					}
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return 0;
	}

	public static void newHistory(RestockHistory hist) throws SQLException {
		int adminId = getAdminId(hist.getResProductId());
		if (adminId <= 0) {
			throw new SQLException("Cannot record restock: no admin_id for product " + hist.getResProductId());
		}
		try (Connection con = MySQLCon.getConnection();
				PreparedStatement ps = con.prepareStatement(newHistoryStr)) {
			ps.setInt(1, getLatestResId());
			ps.setInt(2, hist.getResProductId());
			ps.setInt(3, adminId);
			ps.setInt(4, hist.getResQuantityAdded());
			ps.setDate(5, java.sql.Date.valueOf(hist.getRestockDate()));
			ps.executeUpdate();
			
		}
	}
}
