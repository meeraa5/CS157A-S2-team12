package servlets;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.RequestDispatcher;

import dao.ActivityDao;
import dao.ProductDao;
import dao.RestockHistoryDao;
import dao.UserDao;
import util.Activity;
import util.Product;
import util.RestockHistory;
import util.User;

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


		if (switcher == "newProd") {
			makeNewProd(request, response);
		}


		else if (switcher == "editInformation") { // value is edit information but its mainly to show the products oops
			showNewProd(request, response);

		}


		else if (switcher == "editProduct") { // real edit product method
			editProduct(request, response);
		}


		else if (switcher == "delete") {
			deleteProduct(request, response);
		}


		else if (switcher == "monitor") {
			showActivity(request, response);
		}
		
		else if (switcher == "restock") {
			showRestockHistory(request, response);
		}


		else if (switcher == "suspend") {
			showActiveUsers(request,response);
		}


		else if (switcher == "reactivate") {
			showSuspendedUsers(request, response);
		}
		
		else if (switcher == "reactivateCfm") {
			reactivate(request, response);
		}
		else if (switcher == "suspendCfm") {
			suspend(request, response);
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
	
	private void makeNewProd(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
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
		ProductDao.newProduct(theProduct); // put the new product into the database
		response.sendRedirect("admin.jsp"); // refresh page? and clears the form i hope..
	}
	
	private void showProducts(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<Product> theProducts = ProductDao.selectAllProducts(); // get a list of all the products
		request.setAttribute("theProducts", theProducts); // set attribute
		RequestDispatcher send = request.getRequestDispatcher("admin.jsp"); // make an object to send to admin page
		send.forward(request, response);
	}
	
	private void showRestockHistory(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<RestockHistory> theHistory = RestockHistoryDao.selectAllHistory(); // get a list of all the restock history
		request.setAttribute("theHistory", theHistory); // set attribute
		RequestDispatcher send = request.getRequestDispatcher("admin.jsp"); // make an object to send to admin page
		send.forward(request, response);
	}
	
	private void showActivity(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<Activity> logs = ActivityDao.selectAllLogs(); // get a list of all the logs
		request.setAttribute("logs", logs); // set attribute
		RequestDispatcher send = request.getRequestDispatcher("admin.jsp"); // make an object to send to admin page
		send.forward(request, response);
	}
	
	private void showSuspendedUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<User> sus = UserDao.selectAllUsers("suspended"); // get a list of all the suspended users
		request.setAttribute("sus", sus); // set attribute
		RequestDispatcher send = request.getRequestDispatcher("admin.jsp"); // make an object to send to admin page
		send.forward(request, response);
	}
	
	private void showActiveUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		List<User> sus = UserDao.selectAllUsers("active"); // get a list of all the suspended users
		request.setAttribute("theActive", sus); // set attribute
		RequestDispatcher send = request.getRequestDispatcher("admin.jsp"); // make an object to send to admin page
		send.forward(request, response);
	}
	
	private void editProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
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
        ProductDao.editProduct(edit);
        RestockHistory entry = new RestockHistory(theID, added, theDate);
        response.sendRedirect("admin.jsp");
	}
	
	private void deleteProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		int theID = Integer.parseInt(request.getParameter("id3"));
		ProductDao.deleteProduct(theID);
		response.sendRedirect("admin.jsp");
	}
	
	private void reactivate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		int userID = Integer.parseInt(request.getParameter("id4"));
		UserDao.reactivateUser(userID);
		response.sendRedirect("admin.jsp");
	}
	
	private void suspend(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		int userID = Integer.parseInt(request.getParameter("id5"));
		UserDao.suspendUser(userID);
		response.sendRedirect("admin.jsp");
	}
}
