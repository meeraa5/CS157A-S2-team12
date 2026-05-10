package servlets;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.MySQLCon;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp?Error=Please login first");
            return;
        }

        int userId = (int) session.getAttribute("user_id");

        try (Connection con = MySQLCon.getConnection()) {
            con.setAutoCommit(false); // Start Transaction

            try {
                // 1. Get Cart ID
                int cartId = -1;
                try (PreparedStatement ps = con.prepareStatement("SELECT cart_id FROM cart WHERE user_id = ?")) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) cartId = rs.getInt("cart_id");
                    }
                }

                if (cartId == -1) {
                    throw new Exception("No cart found for this user.");
                }

                // 2. Fetch Cart Items and calculate totals
                List<CartLine> cartLines = new ArrayList<>();
                String fetchItemsSql = "SELECT ci.product_id, ci.quantity, p.product_name, p.price, p.quantity_available " +
                                     "FROM cart_items ci JOIN products p ON ci.product_id = p.product_id " +
                                     "WHERE ci.cart_id = ? FOR UPDATE";
                
                BigDecimal orderTotal = BigDecimal.ZERO;
                try (PreparedStatement ps = con.prepareStatement(fetchItemsSql)) {
                    ps.setInt(1, cartId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            CartLine line = new CartLine(
                                rs.getInt("product_id"),
                                rs.getString("product_name"),
                                rs.getInt("quantity"),
                                rs.getInt("quantity_available"),
                                rs.getBigDecimal("price")
                            );
                            cartLines.add(line);
                            orderTotal = orderTotal.add(line.unitPrice.multiply(BigDecimal.valueOf(line.quantity)));
                        }
                    }
                }

                if (cartLines.isEmpty()) {
                    throw new Exception("Cart is empty.");
                }

                // 3. Create the Main Order
                int orderId = -1;
                String orderSql = "INSERT INTO orders (user_id, order_status, total_amount) VALUES (?, 'Completed', ?)";
                try (PreparedStatement ps = con.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, userId);
                    ps.setBigDecimal(2, orderTotal);
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) orderId = keys.getInt(1);
                    }
                }

                // 4. Create Order Items (FIXED: Added total_price)
                String itemSql = "INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(itemSql)) {
                    for (CartLine line : cartLines) {
                        ps.setInt(1, orderId);
                        ps.setInt(2, line.productId);
                        ps.setInt(3, line.quantity);
                        ps.setBigDecimal(4, line.unitPrice);
                        // Calculate total_price for this line item
                        BigDecimal lineTotal = line.unitPrice.multiply(BigDecimal.valueOf(line.quantity));
                        ps.setBigDecimal(5, lineTotal);
                        ps.executeUpdate();

                        // 5. Update Product Inventory
                        try (PreparedStatement ups = con.prepareStatement("UPDATE products SET quantity_available = quantity_available - ? WHERE product_id = ?")) {
                            ups.setInt(1, line.quantity);
                            ups.setInt(2, line.productId);
                            ups.executeUpdate();
                        }
                    }
                }

                // 6. Clear the Cart
                try (PreparedStatement ps = con.prepareStatement("DELETE FROM cart_items WHERE cart_id = ?")) {
                    ps.setInt(1, cartId);
                    ps.executeUpdate();
                }

                con.commit(); // Success!
                response.sendRedirect("order_confirmation.jsp?orderId=" + orderId);

            } catch (Exception e) {
                con.rollback(); // Undo everything on error
                e.printStackTrace();
                response.sendRedirect("cart.jsp?Error=System Error: " + e.getMessage());
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("cart.jsp?Error=Database Connection Error");
        }
    }

    // Helper class to store cart item data
    private static class CartLine {
        int productId, quantity, quantityAvailable;
        String productName;
        BigDecimal unitPrice;

        CartLine(int id, String name, int q, int avail, BigDecimal price) {
            this.productId = id; this.productName = name; this.quantity = q; 
            this.quantityAvailable = avail; this.unitPrice = price;
        }
    }
}