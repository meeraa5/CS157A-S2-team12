package dao;

import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import util.MySQLCon;
import util.Product;


public class ProductDao {
    private final static String newProductStr = 
    "INSERT INTO products(product_id, product_name, product_description, price, product_condition, quantity_available, product_status, date_added, low_stock_notice, category_id, created_by_admin_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private final static String editProduct = "";

    private final static String getLatestIdStr = "SELECT MAX(product_id) FROM products";

    public static int getLatestId(){ // use for new products
        int theNum = 0;
        
		try {
			Connection con = MySQLCon.getConnection();
	        PreparedStatement latestIdPs;
			latestIdPs = con.prepareStatement(getLatestIdStr);
			ResultSet rs = latestIdPs.executeQuery();
	        if (rs.wasNull()){
	            theNum = 1;
	        }
	        else {
	            theNum = rs.getInt("product_id") + 1;
	        }
		} catch (SQLException e) {
			e.printStackTrace();
		}
        return theNum;
    }

    public static void newProduct(Product prod) throws SQLException {


        try {
            Connection con = MySQLCon.getConnection();
            PreparedStatement newProdPs = con.prepareStatement(newProductStr);
            
            newProdPs.setInt(1, getLatestId());
            prod.setProductId(getLatestId()); // set the id
            newProdPs.setString(2, prod.getProductName());
            newProdPs.setString(3, prod.getInfo());
            newProdPs.setFloat(4, prod.getPrice());
            newProdPs.setString(5, prod.getCondition());
            newProdPs.setInt(6, prod.getQuantityAvail());
            newProdPs.setString(7, prod.getProductStatus());
            newProdPs.setDate(8, java.sql.Date.valueOf(prod.getDateAdded()));
            newProdPs.setString(9, prod.getLowStockNotice());
            newProdPs.setInt(10, prod.getCategoryId());
            newProdPs.setInt(11, prod.getCreatedByAdminId());
            newProdPs.executeUpdate();
            
        } catch (SQLException e) {
        	e.printStackTrace();
        }
        
    } 
}
