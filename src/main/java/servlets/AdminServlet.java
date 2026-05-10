package servlets;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.MySQLCon;
import dao.RestockHistoryDao;
import dao.UserDao; // Ensure you have a UserDao class in your dao package

@WebServlet("/AdminServlet")
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String switcher = request.getParameter("switcher");

        try (Connection con = MySQLCon.getConnection()) {
            if ("editProduct".equals(switcher)) {
                int id = Integer.parseInt(request.getParameter("id2"));
                String name = request.getParameter("productName2");
                String desc = request.getParameter("info2");
                double price = Double.parseDouble(request.getParameter("price2"));
                int newQty = Integer.parseInt(request.getParameter("quantityAvail3"));
                int oldQty = Integer.parseInt(request.getParameter("quantityAvail2"));

                // 1. Update Product Table
                String sql = "UPDATE products SET product_name=?, product_description=?, price=?, quantity_available=? WHERE product_id=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setString(2, desc);
                    ps.setDouble(3, price);
                    ps.setInt(4, newQty);
                    ps.setInt(5, id);
                    ps.executeUpdate();
                }

                // 2. Restock History Log (Only if stock increased)
                if (newQty > oldQty) {
                    int diff = newQty - oldQty;
                    RestockHistoryDao.newHistory(id, diff);
                }
            }
            // 3. Suspend Account Logic
            else if ("suspendCfm".equals(switcher)) {
                int userId = Integer.parseInt(request.getParameter("id5"));
                String confirm = request.getParameter("yes2");
                
                // Only proceed if the admin typed 'yes' in the confirmation box
                if ("yes".equalsIgnoreCase(confirm)) {
                    UserDao.suspendUser(userId);
                }
            } 
            // 4. Reactivate Account Logic
            else if ("reactivateCfm".equals(switcher)) {
                int userId = Integer.parseInt(request.getParameter("id4"));
                String confirm = request.getParameter("yes3");
                
                // Only proceed if the admin typed 'yes' in the confirmation box
                if ("yes".equalsIgnoreCase(confirm)) {
                    UserDao.reactivateUser(userId);
                }
            }
            // 5. New Product Creation Logic
            else if ("newProd".equals(switcher)) {
                String sql = "INSERT INTO products (product_name, product_description, price, category_id, created_by_admin_id, quantity_available, product_status) VALUES (?, ?, ?, ?, ?, ?, 'Active')";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, request.getParameter("productName"));
                    ps.setString(2, request.getParameter("info"));
                    ps.setDouble(3, Double.parseDouble(request.getParameter("price")));
                    ps.setInt(4, Integer.parseInt(request.getParameter("categoryId")));
                    ps.setInt(5, Integer.parseInt(request.getParameter("createdByAdminId")));
                    ps.setInt(6, Integer.parseInt(request.getParameter("quantityAvail")));
                    ps.executeUpdate();
                }
            }

            // Redirect back to dashboard to refresh view and prevent "Blank Page"
            response.sendRedirect("admin.jsp?msg=success");
            
        } catch (Exception e) {
            e.printStackTrace();
            // Redirect with error detail if something fails
            response.sendRedirect("admin.jsp?msg=error&detail=" + e.getMessage());
        }
    }
}