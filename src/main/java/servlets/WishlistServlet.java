package servlets;

import util.MySQLCon;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/WishlistServlet")
public class WishlistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Map<String, Object>> wishlistItems = new ArrayList<>();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?Error=Please log in first");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");

        Connection con = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            con = MySQLCon.getConnection();

            String sql = "SELECT w.wishlist_item_id, w.user_id, p.product_id, p.product_name, " +
                         "p.product_description, p.price, p.product_condition " +
                         "FROM wishlist_items w " +
                         "JOIN products p ON w.product_id = p.product_id " +
                         "WHERE w.user_id = ? " +
                         "ORDER BY w.added_date DESC";

            stmt = con.prepareStatement(sql);
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("wishlist_item_id", rs.getInt("wishlist_item_id"));
                row.put("user_id", rs.getInt("user_id"));
                row.put("product_id", rs.getInt("product_id"));
                row.put("product_name", rs.getString("product_name"));
                row.put("product_description", rs.getString("product_description"));
                row.put("price", rs.getBigDecimal("price"));
                row.put("product_condition", rs.getString("product_condition"));
                wishlistItems.add(row);
            }

            request.setAttribute("wishlistItems", wishlistItems);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("dbError", "Database error loading wishlist: " + e.getMessage());
            request.setAttribute("wishlistItems", wishlistItems);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }

        request.getRequestDispatcher("/wishlist.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?Error=Please log in first");
            return;
        }

        String action = request.getParameter("action");

        if ("add".equalsIgnoreCase(action)) {
            addItem(request, response);
        } else if ("remove".equalsIgnoreCase(action)) {
            removeItem(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/WishlistServlet");
        }
    }

    private void addItem(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?Error=Please log in first");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");
        String pidStr = request.getParameter("product_id");

        if (pidStr == null || pidStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/WishlistServlet?Error=MissingProductId");
            return;
        }

        Connection con = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;

        try {
            int productId = Integer.parseInt(pidStr);

            con = MySQLCon.getConnection();

            String checkSql = "SELECT wishlist_item_id FROM wishlist_items WHERE user_id = ? AND product_id = ?";
            checkStmt = con.prepareStatement(checkSql);
            checkStmt.setInt(1, userId);
            checkStmt.setInt(2, productId);
            rs = checkStmt.executeQuery();

            if (!rs.next()) {
                String insertSql = "INSERT INTO wishlist_items (user_id, product_id, added_date) VALUES (?, ?, NOW())";
                insertStmt = con.prepareStatement(insertSql);
                insertStmt.setInt(1, userId);
                insertStmt.setInt(2, productId);
                insertStmt.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/WishlistServlet?Error=" +
                    java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (checkStmt != null) checkStmt.close(); } catch (Exception ignored) {}
            try { if (insertStmt != null) insertStmt.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }

        response.sendRedirect(request.getContextPath() + "/WishlistServlet");
    }

    private void removeItem(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?Error=Please log in first");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");
        String widStr = request.getParameter("wishlist_item_id");

        if (widStr == null || widStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/WishlistServlet?Error=MissingWishlistItemId");
            return;
        }

        Connection con = null;
        PreparedStatement stmt = null;

        try {
            int wishlistItemId = Integer.parseInt(widStr);

            con = MySQLCon.getConnection();

            String sql = "DELETE FROM wishlist_items WHERE wishlist_item_id = ? AND user_id = ?";
            stmt = con.prepareStatement(sql);
            stmt.setInt(1, wishlistItemId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/WishlistServlet?Error=" +
                    java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        } finally {
            try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }

        response.sendRedirect(request.getContextPath() + "/WishlistServlet");
    }
}