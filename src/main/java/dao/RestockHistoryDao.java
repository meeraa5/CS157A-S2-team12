package dao;

import java.sql.*;
import util.MySQLCon;

public class RestockHistoryDao {

    public static void newHistory(int prodId, int qtyAdded) {
        // Fallback admin ID (ensure this ID exists in your 'users' or 'admins' table)
        int adminId = 1; 

        // Query to find the actual admin who owns this product
        String findAdmin = "SELECT created_by_admin_id FROM products WHERE product_id = ?";
        String insertSql = "INSERT INTO restock_history (product_id, admin_id, quantity_added, restock_date) VALUES (?, ?, ?, NOW())";

        try (Connection con = MySQLCon.getConnection()) {
            // 1. Try to get the real admin ID
            try (PreparedStatement ps = con.prepareStatement(findAdmin)) {
                ps.setInt(1, prodId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int foundId = rs.getInt("created_by_admin_id");
                        if (foundId > 0) adminId = foundId;
                    }
                }
            }

            // 2. Insert the history
            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setInt(1, prodId);
                ps.setInt(2, adminId);
                ps.setInt(3, qtyAdded);
                
                int rows = ps.executeUpdate();
                System.out.println("Restock History Inserted: " + rows + " row(s).");
            }
        } catch (SQLException e) {
            System.err.println("RESTOCK DAO ERROR: " + e.getMessage());
            e.printStackTrace();
        }
    }
}