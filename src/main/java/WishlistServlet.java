import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import util.MySQLCon;

@WebServlet("/WishlistServlet")
public class WishlistServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("user_id") == null) {
			response.sendRedirect("login.jsp?Error=Please login first");
			return;
		}

		int userId = (int) session.getAttribute("user_id");
		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;

		try {
			con = MySQLCon.getConnection();
			String sql = "SELECT wi.wishlist_item_id, wi.product_id, wi.added_date, "
					+ "p.product_name, p.product_description, p.price, p.product_condition, p.product_status "
					+ "FROM wishlist_items wi "
					+ "JOIN products p ON wi.product_id = p.product_id "
					+ "WHERE wi.user_id = ? ORDER BY wi.added_date DESC";
			ps = con.prepareStatement(sql);
			ps.setInt(1, userId);
			rs = ps.executeQuery();

			List<Map<String, Object>> rows = new ArrayList<>();
			while (rs.next()) {
				Map<String, Object> row = new LinkedHashMap<>();
				row.put("wishlist_item_id", rs.getInt("wishlist_item_id"));
				row.put("product_id", rs.getInt("product_id"));
				row.put("added_date", rs.getTimestamp("added_date"));
				row.put("product_name", rs.getString("product_name"));
				row.put("product_description", rs.getString("product_description"));
				row.put("price", rs.getBigDecimal("price"));
				row.put("product_condition", rs.getString("product_condition"));
				row.put("product_status", rs.getString("product_status"));
				rows.add(row);
			}
			request.setAttribute("wishlistItems", rows);
			request.getRequestDispatcher("/wishlist.jsp").forward(request, response);
		} catch (Exception e) {
			e.printStackTrace();
			request.setAttribute("dbError", "Could not load wishlist.");
			try {
				request.setAttribute("wishlistItems", new ArrayList<Map<String, Object>>());
				request.getRequestDispatcher("/wishlist.jsp").forward(request, response);
			} catch (Exception ex) {
				response.sendRedirect("index.jsp?Error=Wishlist unavailable");
			}
		} finally {
			try {
				if (rs != null)
					rs.close();
			} catch (Exception e) {
			}
			try {
				if (ps != null)
					ps.close();
			} catch (Exception e) {
			}
			try {
				if (con != null)
					con.close();
			} catch (Exception e) {
			}
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("user_id") == null) {
			response.sendRedirect("login.jsp?Error=Please login first");
			return;
		}

		int userId = (int) session.getAttribute("user_id");
		String action = request.getParameter("action");
		if (action == null) {
			action = "add";
		}

		Connection con = null;
		PreparedStatement ps = null;

		try {
			con = MySQLCon.getConnection();

			if ("remove".equals(action)) {
				int wishlistItemId = Integer.parseInt(request.getParameter("wishlist_item_id"));
				String deleteSql = "DELETE FROM wishlist_items WHERE wishlist_item_id = ? AND user_id = ?";
				ps = con.prepareStatement(deleteSql);
				ps.setInt(1, wishlistItemId);
				ps.setInt(2, userId);
				ps.executeUpdate();
			} else {
				int productId = Integer.parseInt(request.getParameter("product_id"));
				String insertSql = "INSERT IGNORE INTO wishlist_items (user_id, product_id) VALUES (?, ?)";
				ps = con.prepareStatement(insertSql);
				ps.setInt(1, userId);
				ps.setInt(2, productId);
				ps.executeUpdate();
			}

			response.sendRedirect(request.getContextPath() + "/WishlistServlet");
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/WishlistServlet?Error=could_not_update_wishlist");
		} finally {
			try {
				if (ps != null)
					ps.close();
			} catch (Exception e) {
			}
			try {
				if (con != null)
					con.close();
			} catch (Exception e) {
			}
		}
	}
}
