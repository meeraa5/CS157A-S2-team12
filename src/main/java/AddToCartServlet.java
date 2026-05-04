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

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp?Error=Please login first");
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        int productId = Integer.parseInt(request.getParameter("product_id"));

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = MySQLCon.getConnection();

            String productSql = "SELECT quantity_available, product_status FROM products WHERE product_id = ?";
            ps = con.prepareStatement(productSql);
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            if (!rs.next() || rs.getInt("quantity_available") <= 0 || !"Available".equals(rs.getString("product_status"))) {
                response.sendRedirect("index.jsp?Error=Product is not available");
                return;
            }
            int quantityAvailable = rs.getInt("quantity_available");
            rs.close();
            ps.close();

            int cartId;

            String findCartSql = "SELECT cart_id FROM cart WHERE user_id = ?";
            ps = con.prepareStatement(findCartSql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                cartId = rs.getInt("cart_id");
                rs.close();
                ps.close();
            } else {
                rs.close();
                ps.close();

                String createCartSql = "INSERT INTO cart (user_id) VALUES (?)";
                ps = con.prepareStatement(createCartSql);
                ps.setInt(1, userId);
                ps.executeUpdate();
                ps.close();

                ps = con.prepareStatement(findCartSql);
                ps.setInt(1, userId);
                rs = ps.executeQuery();
                rs.next();
                cartId = rs.getInt("cart_id");
                rs.close();
                ps.close();
            }

            String checkItemSql = "SELECT cart_item_id, quantity FROM cart_items WHERE cart_id = ? AND product_id = ?";
            ps = con.prepareStatement(checkItemSql);
            ps.setInt(1, cartId);
            ps.setInt(2, productId);
            rs = ps.executeQuery();

            if (rs.next()) {
                int cartItemId = rs.getInt("cart_item_id");
                int quantity = rs.getInt("quantity");
                rs.close();
                ps.close();

                if (quantity >= quantityAvailable) {
                    response.sendRedirect("cart.jsp?Error=No more inventory available for this product");
                    return;
                }

                String updateSql = "UPDATE cart_items SET quantity = ? WHERE cart_item_id = ?";
                ps = con.prepareStatement(updateSql);
                ps.setInt(1, quantity + 1);
                ps.setInt(2, cartItemId);
                ps.executeUpdate();
                ps.close();
            } else {
                rs.close();
                ps.close();

                String insertItemSql = "INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?)";
                ps = con.prepareStatement(insertItemSql);
                ps.setInt(1, cartId);
                ps.setInt(2, productId);
                ps.setInt(3, 1);
                ps.executeUpdate();
                ps.close();
            }

            response.sendRedirect("index.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?Error=Could not add to cart");
            response.getWriter().println("Error in AddToCartServlet:");
            e.printStackTrace(response.getWriter());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}