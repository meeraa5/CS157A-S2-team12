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

import dao.ProductDao;
import util.Product;

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


		else if (switcher == "editInformation") {
			showNewProd(request, response);

		}


		else if (switcher == "changeQuantity") {
			
		}


		else if (switcher == "restockProducts") {

		}


		else if (switcher == "monitor") {

		}


		else if (switcher == "suspend") {

		}


		else if (switcher == "reactivate") {

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
}
