package servlets;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

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
            con.setAutoCommit(false);

            try {
                int cartId = getCartId(con, userId);
                if (cartId == -1) {
                    rollbackAndRedirect(con, response, "cart.jsp?Error=Your cart is empty");
                    return;
                }

                List<CartLine> cartLines = getCartLines(con, cartId);
                if (cartLines.isEmpty()) {
                    rollbackAndRedirect(con, response, "cart.jsp?Error=Your cart is empty");
                    return;
                }

                BigDecimal totalAmount = BigDecimal.ZERO;
                for (CartLine line : cartLines) {
                    if (line.quantity > line.quantityAvailable) {
                        rollbackAndRedirect(con, response,
                                "cart.jsp?Error=Not enough inventory for " + encodeRedirectValue(line.productName));
                        return;
                    }
                    totalAmount = totalAmount.add(line.unitPrice.multiply(BigDecimal.valueOf(line.quantity)));
                }

                int orderId = createOrder(con, userId, totalAmount);
                for (CartLine line : cartLines) {
                    createOrderItem(con, orderId, line);
                    updateInventory(con, line);
                }

                clearCart(con, cartId);
                logActivity(con, userId, "Checkout", "Created order #" + orderId + " for $" + totalAmount);

                con.commit();
                response.sendRedirect("order_confirmation.jsp?orderId=" + orderId);
            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
                response.sendRedirect("cart.jsp?Error=Checkout failed. Please try again.");
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("cart.jsp?Error=Database error during checkout");
        }
    }

    private int getCartId(Connection con, int userId) throws Exception {
        String sql = "SELECT cart_id FROM cart WHERE user_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("cart_id") : -1;
            }
        }
    }

    private List<CartLine> getCartLines(Connection con, int cartId) throws Exception {
        String sql = "SELECT ci.product_id, ci.quantity, p.product_name, p.price, p.quantity_available " +
                "FROM cart_items ci " +
                "JOIN products p ON ci.product_id = p.product_id " +
                "WHERE ci.cart_id = ? AND p.product_status = 'Available' " +
                "FOR UPDATE";
        List<CartLine> lines = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lines.add(new CartLine(
                            rs.getInt("product_id"),
                            rs.getString("product_name"),
                            rs.getInt("quantity"),
                            rs.getInt("quantity_available"),
                            rs.getBigDecimal("price")));
                }
            }
        }
        return lines;
    }

    private int createOrder(Connection con, int userId, BigDecimal totalAmount) throws Exception {
        String sql = "INSERT INTO orders (user_id, order_status, total_amount) VALUES (?, 'Completed', ?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setBigDecimal(2, totalAmount);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new IllegalStateException("Order was created without a generated id");
    }

    private void createOrderItem(Connection con, int orderId, CartLine line) throws Exception {
        String sql = "INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, line.productId);
            ps.setInt(3, line.quantity);
            ps.setBigDecimal(4, line.unitPrice);
            ps.setBigDecimal(5, line.unitPrice.multiply(BigDecimal.valueOf(line.quantity)));
            ps.executeUpdate();
        }
    }

    private void updateInventory(Connection con, CartLine line) throws Exception {
        String sql = "UPDATE products " +
                "SET quantity_available = quantity_available - ?, " +
                "product_status = CASE WHEN quantity_available - ? = 0 THEN 'Out_of_Stock' ELSE product_status END, " +
                "low_stock_notice = CASE WHEN quantity_available - ? < 5 THEN 'yes' ELSE 'no' END " +
                "WHERE product_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, line.quantity);
            ps.setInt(2, line.quantity);
            ps.setInt(3, line.quantity);
            ps.setInt(4, line.productId);
            ps.executeUpdate();
        }
    }

    private void clearCart(Connection con, int cartId) throws Exception {
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM cart_items WHERE cart_id = ?")) {
            ps.setInt(1, cartId);
            ps.executeUpdate();
        }
    }

    private void logActivity(Connection con, int userId, String type, String detail) throws Exception {
        String sql = "INSERT INTO activity_log (user_id, activity_type, activity_detail) VALUES (?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, type);
            ps.setString(3, detail);
            ps.executeUpdate();
        }
    }

    private void rollbackAndRedirect(Connection con, HttpServletResponse response, String location) throws Exception {
        con.rollback();
        response.sendRedirect(location);
    }

    private String encodeRedirectValue(String value) {
        return value == null ? "" : URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static class CartLine {
        private final int productId;
        private final String productName;
        private final int quantity;
        private final int quantityAvailable;
        private final BigDecimal unitPrice;

        private CartLine(int productId, String productName, int quantity, int quantityAvailable, BigDecimal unitPrice) {
            this.productId = productId;
            this.productName = productName;
            this.quantity = quantity;
            this.quantityAvailable = quantityAvailable;
            this.unitPrice = unitPrice;
        }
    }
}
