package servlets;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import util.MySQLCon;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp?Error=Please login first");
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        int productId = Integer.parseInt(request.getParameter("productId"));

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = MySQLCon.getConnection();

            int cartId= -1;
            

            String findCartSql = "SELECT cart_id FROM cart WHERE user_id = ?";
            ps = con.prepareStatement(findCartSql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                cartId = rs.getInt("cart_id");
                
            }
            rs.close();
            ps.close();
            
            
            if(cartId ==-1) {
                response.sendRedirect("cart.jsp?Error=Cart not found");
                return;
            }
            
            
            String action = request.getParameter("action");
            
            
            if ("increment".equals(action)) {

                String updateSql = "UPDATE cart_items ci " +
                        "JOIN products p ON ci.product_id = p.product_id " +
                        "SET ci.quantity = ci.quantity + 1 " +
                        "WHERE ci.cart_id = ? AND ci.product_id = ? AND ci.quantity < p.quantity_available";
                ps = con.prepareStatement(updateSql);
                ps.setInt(1, cartId);
                ps.setInt(2, productId);
                int updatedRows = ps.executeUpdate();
                ps.close();
                if (updatedRows == 0) {
                    response.sendRedirect("cart.jsp?Error=No more inventory available for this product");
                    return;
                }

            } else if ("decrement".equals(action)) {

                String checkSql = "SELECT quantity FROM cart_items WHERE cart_id = ? AND product_id = ?";
                ps = con.prepareStatement(checkSql);
                ps.setInt(1, cartId);
                ps.setInt(2, productId);
                rs = ps.executeQuery();

                if (rs.next()) {
                    int quantity = rs.getInt("quantity");
                   rs.close();
                    ps.close();

                    if (quantity > 1) {
                        String updateSql = "UPDATE cart_items SET quantity = quantity - 1 WHERE cart_id = ? AND product_id = ?";
                        ps = con.prepareStatement(updateSql);
                        ps.setInt(1, cartId);
                        ps.setInt(2, productId);
                        ps.executeUpdate();
                        ps.close();
                    } else {
                        String deleteSql = "DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?";
                        ps = con.prepareStatement(deleteSql);
                        ps.setInt(1, cartId);
                        ps.setInt(2, productId);
                        ps.executeUpdate();
                        ps.close();
                    }
                } else {
                    rs.close();
                    ps.close();
                }

            } else if ("remove".equals(action)) {

                String deleteSql = "DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?";
                ps = con.prepareStatement(deleteSql);
                ps.setInt(1, cartId);
                ps.setInt(2, productId);
                ps.executeUpdate();
                ps.close();
            }

            response.sendRedirect("cart.jsp");


    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("cart.jsp?Error=Could not update cart");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (con != null) con.close(); } catch (Exception e) {}
    }
    }
}

         