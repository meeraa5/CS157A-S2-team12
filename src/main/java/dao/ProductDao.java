package dao;

import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import util.MySQLCon;
import util.Product;


public class ProductDao {
    private final static String newProductStr = 
    		"INSERT INTO products(product_id, product_name, product_description, price, product_condition, quantity_available, product_status, date_added, low_stock_notice, category_id, created_by_admin_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
// DO NOT CHANGE THESE STATEMENTS THEY NEED PRODUCT ID PLEASE REFERENCE SCHEMA 
    
    private final static String editProductStr = "UPDATE products SET product_name = ?, product_description = ?, price = ?, product_condition = ?, quantity_available = ?, product_status = ?, low_stock_notice = ? WHERE product_id = ?;";
    
    private final static String getProductsStr = "SELECT * FROM products;";

    private final static String getLatestIdStr = "SELECT MAX(product_id) FROM products;";
    
    private final static String deleteStr = "DELETE FROM products WHERE product_id = ?;";

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
            con.close();
            
        } catch (SQLException e) {
        	e.printStackTrace();
        }
        
    } 
    
    public static List<Product> selectAllProducts(){
    	List<Product> products = new ArrayList<>();
    	try {
    		Connection con = MySQLCon.getConnection();
            PreparedStatement listProdPs = con.prepareStatement(getProductsStr);
            ResultSet rs = listProdPs.executeQuery();
            while (rs.next()) {
            	int theId = rs.getInt("product_id");
                String theName = rs.getString("product_name");
                String theInfo = rs.getString("product_description");
                float thePrice = rs.getFloat("price");
                String theCondition = rs.getString("product_condition");
                int theQuantity = rs.getInt("quantity_available");
                String theStatus = rs.getString("product_status");
                LocalDate theDate = rs.getDate("date_added").toLocalDate();
                String theNotice = rs.getString("low_stock_notice");
                int theCategory = rs.getInt("category_id");
                int theAdmin = rs.getInt("created_by_admin_id");
        		Product theProduct = new Product(theId,theName, theInfo, thePrice, theCondition, theQuantity, theStatus, theDate, theNotice, theCategory, theAdmin);
        		products.add(theProduct);
            }
    	} catch (SQLException e) {
			e.printStackTrace();
		}
    	return products;
    }
    
    
    
    public static void editProduct(Product prod) throws SQLException {
    	try {
            Connection con = MySQLCon.getConnection();
            PreparedStatement editProdPs = con.prepareStatement(editProductStr);

            // change these 
            editProdPs.setString(1, prod.getProductName());


            editProdPs.setString(2, prod.getInfo());


            editProdPs.setFloat(3, prod.getPrice());


            editProdPs.setString(4, prod.getCondition());


            editProdPs.setInt(5, prod.getQuantityAvail());


            editProdPs.setString(6, prod.getProductStatus());


            editProdPs.setString(7, prod.getLowStockNotice());
            
            editProdPs.setInt(8, prod.getProductId()); // where product is this

            
            editProdPs.executeUpdate();
            con.close();
            
        } catch (SQLException e) {
        	e.printStackTrace();
        }
    }
    
    public static void deleteProduct(int id) throws SQLException{
    	try {
            Connection con = MySQLCon.getConnection();
            PreparedStatement deleteProdPs = con.prepareStatement(deleteStr);
            
            deleteProdPs.setInt(1, id);
            
            deleteProdPs.executeUpdate();
            con.close();
            
    	} catch (SQLException e) {
         	e.printStackTrace();
        }
    }
}
