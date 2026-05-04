package servlets;

import java.io.IOException;
import java.time.LocalDate;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		response.getWriter().append("Served at: ").append(request.getContextPath());
		try {
			switch(request.getServletPath()) {
			case "/newProd":
				makeNewProd(request, response);
				break;
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
        float thePrice = request.getParameter("price");
        String theCondition = request.getParameter("condition");
        int theQuantity = request.getParameter("quantityAvail");
        String theStatus = request.getParameter("productStatus");
        LocalDate theDate = LocalDate.now();
		String theNotice = "no"; // low stock notice
        int theCategory = request.getParameter("categoryId");
        int theAdmin = request.getParameter("createdByAdminId");

		if (theQuantity < 5){
			theNotice = "yes";
		}

		Product theProduct = new Product(theName, theInfo, thePrice, theCondition, theQuantity, theStatus, theDate, theNotice, theCategory, theAdmin);
		ProductDao.newProduct(theProduct);
		response.sendRedirect("admin.jsp"); // refresh page? and clears the form i hope..
	}

}
