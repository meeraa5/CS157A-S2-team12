package servlets;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.ProductDao;
import dao.UserDao;
import util.Product;
import util.RestockHistory;

/**
 * Servlet implementation class AdminServlet
 */
@WebServlet("/AdminServlet")
public class AdminServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

    /**
     * Default constructor. 
     */
    public AdminServlet() {

    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 * basically when user clicks a specific function on admin page
	 * changes the value of switcher which tells servlet which method to use
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String switcher = request.getParameter("switcher");

		try {
			if ("newProd".equals(switcher)) {
				makeNewProd(request, response);
			}
			else if ("editProduct".equals(switcher)) {
				editProduct(request, response);
			}
			else if ("delete".equals(switcher)) {
				deleteProduct(request, response);
			}
			else if ("reactivateCfm".equals(switcher)) {
				reactivate(request, response);
			}
			else if ("suspendCfm".equals(switcher)) {
				suspend(request, response);
			}
		} catch (SQLException exception) {
			throw new ServletException(exception);
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
	
	private void makeNewProd(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// get the info from the site
		String theName = request.getParameter("productName");
        String theInfo = request.getParameter("info");
        float thePrice = Float.parseFloat(request.getParameter("price"));
        String theCondition = request.getParameter("condition");
        int theQuantity = Integer.parseInt(request.getParameter("quantityAvail"));
        String theStatus = request.getParameter("productStatus");
        LocalDate theDate = LocalDate.now();
		String theNotice = "no"; // low stock notice
        int theCategory = Integer.parseInt(request.getParameter("categoryId"));
        int theAdmin = Integer.parseInt(request.getParameter("createdByAdminId"));

		if (theQuantity < 5){ // change the notice if its low stock
			theNotice = "yes";
		}

		Product theProduct = new Product(0,theName, theInfo, thePrice, theCondition, theQuantity, theStatus, theDate, theNotice, theCategory, theAdmin);
		try {
			ProductDao.newProduct(theProduct);
		} catch (SQLException e) {
			throw new ServletException(e);
		}
		response.sendRedirect("admin.jsp");
	}
	
	
	private void editProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException{
		int added = Integer.parseInt(request.getParameter("quantityAvail3")) - Integer.parseInt(request.getParameter("quantityAvail2"));
		LocalDate theDate = LocalDate.now();
		
		int theID = Integer.parseInt(request.getParameter("id2"));
		String theName = request.getParameter("productName2");
        String theInfo = request.getParameter("info2");
        float thePrice = Float.parseFloat(request.getParameter("price2"));
        String theCondition = request.getParameter("condition2");
        int theQuantity = Integer.parseInt(request.getParameter("quantityAvail3"));
        String theStatus = request.getParameter("productStatus2");
        String theNotice = "no"; // low stock notice
        if (theQuantity < 5){ // change the notice if its low stock
			theNotice = "yes";
		}
        Product edit = new Product(theID, theName, theInfo, thePrice, theCondition, theQuantity, theStatus, theNotice);
        try {
			ProductDao.editProduct(edit);
			if (added > 0) {
				RestockHistory entry = new RestockHistory(theID, added, theDate);
				RestockHistoryDao.newHistory(entry);
			}
		} catch (SQLException e) {
			throw new ServletException(e);
		}
        response.sendRedirect("admin.jsp");
	}
	
	private void deleteProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException{
		int theID = Integer.parseInt(request.getParameter("id3"));
		try {
			ProductDao.deleteProduct(theID);
		} catch (SQLException e) {
			throw new ServletException(e);
		}
		response.sendRedirect("admin.jsp");
	}
	
	private void reactivate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException{
		int userID = Integer.parseInt(request.getParameter("id4"));
		try {
			UserDao.reactivateUser(userID);
		} catch (SQLException e) {
			throw new ServletException(e);
		}
		response.sendRedirect("admin.jsp");
	}
	
	private void suspend(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException{
		int userID = Integer.parseInt(request.getParameter("id5"));
		try {
			UserDao.suspendUser(userID);
		} catch (SQLException e) {
			throw new ServletException(e);
		}
		response.sendRedirect("admin.jsp");
	}
}
