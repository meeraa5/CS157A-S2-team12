<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet"%>
<%@ page import="util.MySQLCon, util.Product, java.util.List, util.RestockHistory"%>




<%
String role = (String) session.getAttribute("role");

if (role == null || !role.equals("admin")) {
	response.sendRedirect("login.jsp?Error=Access denied");
	return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/styles.css">
</head>
<body>

	<div class="navbar" style="display: block;">
		<h1>Admin Dashboard</h1>
		<p>Welcome, Administrator.</p>
	</div>

	<script>
		function toggleVisibility(id) {
			hideAll();
			var theDiv = document.getElementById(id);
			if (theDiv.style.display == "none" || theDiv.style.display == "") {
				theDiv.style.display = "block";
				switcher.value = id; // changes depending on what adminservlet should do next
			}
		}

		function hideAll() { // this is crude but oh well. hides all divs
			document.getElementById("reports").style.display = "none"; // oh i see you added your div here
			document.getElementById("monitor").style.display = "none";
			document.getElementById("newProd").style.display = "none";
			document.getElementById("editInformation").style.display = "none";
			document.getElementById("reactivate").style.display = "none";
			document.getElementById("suspend").style.display = "none";
			document.getElementById("restock").style.display = "none";
			// changing this was redundant but i'll leave it
		}
		
		function changeProduct(id){
			document.getElementById("editTable").style.display = "none"; // hide the table of products
			var theForm = document.getElementById(id); // id of the specific form we want to see
			theForm.style.display = "block"; // show the edit or delete confirm form
			
			var theProductName = document.getElementById("theName").value;
			var theProductInfo = document.getElementById("theInfo").value;
			var theProductPrice = document.getElementById("thePrice").value;
			var theProductQuantity = document.getElementById("theQuantity").value;
			var theProductId = document.getElementById("theID").value;
			
			if (id == "changeInfo") {
				document.getElementById("productName2").placeholder = theProductName;
				document.getElementById("info2").placeholder = theProductInfo;
				document.getElementById("price2").placeholder = theProductPrice;
				document.getElementById("quantityAvail2").placeholder = theProductQuantity;
				document.getElementById("id2").placeholder = theProductId;
				// basically takes the product name, info, price, quantity from the java Product object 
				// then puts as placeholder in the form 
				
				document.getElementById("switcher").value = "editProduct";
			}
			else {
				document.getElementById("switcher").value = "delete";
				document.getElementById("id3").placeholder = theProductId;
				document.getElementById("productName3").placeholder = theProductName;
			}
			
		}

	</script>
	<input type="hidden" id = "switcher" name = "switcher" value="none"> <!-- tells AdminServlet what to use -->
	<h2>Management Options</h2>
	<ul>
		<li><a href="#" onclick="toggleVisibility('reports')">Analytics and Reports</a></li>
		<li><a href="#" onclick="toggleVisibility('newProd')">Create
				New Product Listing</a></li>
		<li><a href="#" onclick="toggleVisibility('editInformation')">Edit
				Product Information and Adjust Inventory Quantity</a></li>
		<li><a href="#" onclick="toggleVisibility('restock')">Restock History</a></li>

	</ul>

	<br>


	<div class="section">
		<h2>User Management</h2>
		<ul>
			<li><a href="#" onclick="toggleVisibility('monitor')">Monitor
					User Accounts</a></li>
			<li><a href="#" onclick="toggleVisibility('suspend')">Suspend
					User Account</a></li>
			<li><a href="#" onclick="toggleVisibility('reactivate')">Reactivate
					User Account</a></li>
		</ul>
	</div>
	<!-- samantha will do admin and admin servlet -->
	<!-- meera did reports div -->

	<div id="adminFunctions" class="admin-functions">
		<div id="reports" class="admin-functions-box">
			<h2 class="admin-functions-headers">Analytics and Reports</h2>
			<%
			try (Connection reportCon = MySQLCon.getConnection()) {
				int totalUsers = 0;
				int totalProducts = 0;
				int totalTransactions = 0;
				double totalRevenue = 0;

				try (PreparedStatement countUsers = reportCon.prepareStatement("SELECT COUNT(*) FROM users");
					 ResultSet countUsersRs = countUsers.executeQuery()) {
					if (countUsersRs.next()) {
						totalUsers = countUsersRs.getInt(1);
					}
				}

				try (PreparedStatement countProducts = reportCon.prepareStatement("SELECT COUNT(*) FROM products");
					 ResultSet countProductsRs = countProducts.executeQuery()) {
					if (countProductsRs.next()) {
						totalProducts = countProductsRs.getInt(1);
					}
				}

				try (PreparedStatement countOrders = reportCon.prepareStatement("SELECT COUNT(*), COALESCE(SUM(total_amount), 0) FROM orders WHERE order_status IN ('Paid', 'Completed')");
					 ResultSet countOrdersRs = countOrders.executeQuery()) {
					if (countOrdersRs.next()) {
						totalTransactions = countOrdersRs.getInt(1);
						totalRevenue = countOrdersRs.getDouble(2);
					}
				}
			%>
			<div class="report-grid">
				<div class="report-card"><strong>Total Registered Users</strong><br><%= totalUsers %></div>
				<div class="report-card"><strong>Total Products Listed</strong><br><%= totalProducts %></div>
				<div class="report-card"><strong>Completed Transactions</strong><br><%= totalTransactions %></div>
				<div class="report-card"><strong>Total Revenue</strong><br>$<%= String.format("%.2f", totalRevenue) %></div>
			</div>

			<h3>Monthly Revenue</h3>
			<table class="data-table">
				<tr><th>Month</th><th>Revenue</th></tr>
				<%
				try (PreparedStatement monthly = reportCon.prepareStatement(
						"SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month, SUM(total_amount) AS revenue " +
						"FROM orders WHERE order_status IN ('Paid', 'Completed') GROUP BY DATE_FORMAT(order_date, '%Y-%m') ORDER BY order_month DESC");
					 ResultSet monthlyRs = monthly.executeQuery()) {
					while (monthlyRs.next()) {
				%>
				<tr><td><%= monthlyRs.getString("order_month") %></td><td>$<%= monthlyRs.getBigDecimal("revenue") %></td></tr>
				<%
					}
				}
				%>
			</table>

			<h3>Most Purchased Products</h3>
			<table class="data-table">
				<tr><th>Product</th><th>Quantity Sold</th></tr>
				<%
				try (PreparedStatement topProducts = reportCon.prepareStatement(
						"SELECT p.product_name, SUM(oi.quantity) AS quantity_sold " +
						"FROM order_items oi JOIN products p ON oi.product_id = p.product_id " +
						"GROUP BY p.product_id, p.product_name ORDER BY quantity_sold DESC LIMIT 5");
					 ResultSet topProductsRs = topProducts.executeQuery()) {
					while (topProductsRs.next()) {
				%>
				<tr><td><%= topProductsRs.getString("product_name") %></td><td><%= topProductsRs.getInt("quantity_sold") %></td></tr>
				<%
					}
				}
				%>
			</table>

			<h3>Least Purchased Products</h3>
			<table class="data-table">
				<tr><th>Product</th><th>Quantity Sold</th></tr>
				<%
				try (PreparedStatement lowProducts = reportCon.prepareStatement(
						"SELECT p.product_name, COALESCE(SUM(oi.quantity), 0) AS quantity_sold " +
						"FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id " +
						"GROUP BY p.product_id, p.product_name ORDER BY quantity_sold ASC, p.product_name ASC LIMIT 5");
					 ResultSet lowProductsRs = lowProducts.executeQuery()) {
					while (lowProductsRs.next()) {
				%>
				<tr><td><%= lowProductsRs.getString("product_name") %></td><td><%= lowProductsRs.getInt("quantity_sold") %></td></tr>
				<%
					}
				}
				%>
			</table>

			<h3>Low Inventory Alerts</h3>
			<table class="data-table">
				<tr><th>Product</th><th>Quantity Available</th><th>Status</th></tr>
				<%
				try (PreparedStatement lowInventory = reportCon.prepareStatement(
						"SELECT product_name, quantity_available, product_status FROM products WHERE quantity_available < 5 ORDER BY quantity_available ASC");
					 ResultSet lowInventoryRs = lowInventory.executeQuery()) {
					while (lowInventoryRs.next()) {
				%>
				<tr>
					<td><%= lowInventoryRs.getString("product_name") %></td>
					<td><%= lowInventoryRs.getInt("quantity_available") %></td>
					<td><%= lowInventoryRs.getString("product_status") %></td>
				</tr>
				<%
					}
				}
				%>
			</table>
			<%
			} catch (Exception e) {
				e.printStackTrace();
			%>
			<p>Error loading analytics.</p>
			<%
			}
			%>
		</div>

		<div id="newProd" class="admin-functions-box">
			<form id="newProdForm" action="<%= request.getContextPath() %>/AdminServlet" method="post">
				<fieldset>
					<legend>
						<h2 class="admin-functions-headers">Create New Listing</h2>
					</legend>
					<label for="productName">Product Name:</label> <input type="text"
						id="productName" name="productName" class="formStuff" required>
					<br>
					<br> <label for="info">Information:</label><br>
					<textarea id="info" name="info" class="formStuff" required> </textarea>
					<br>
					<br> <label for="price">Price:</label> <input type="text"
						id="price" name="price" class="formStuff" required> 
					<br>
					<br> <label for="condition">Condition:</label> 
					<select name="condition" id="condition" required>
    					<option value="New">New</option>
    					<option value="Like New">Like New</option>
    					<option value="Good">Good</option>
    					<option value="Fair">Fair</option>
    					<option value="Used">Used</option>
  					</select> 
					<br>
					<br> <label for="quantityAvail">Quantity:</label> <input
						type="text" id="quantityAvail" name="quantityAvail"
						class="formStuff" required> 
					<br>
					<br> <label for="productStatus">Status:</label> 
					<select name="productStatus" id="productStatus" required>
    					<option value="Available" selected>Available</option>
    					<option value="Out_of_Stock">Out of Stock</option>
    					<option value="Inactive">Inactive</option>
  					</select>
					<br>
					<br> <label for="categoryId">Category ID:</label> <input
						type="text" id="categoryId" name="categoryId" class="formStuff"
						required> 
					<br>
					<br> <label for="createdByAdminId">Admin ID:</label> <input
						type="text" id="createdByAdminId" name="createdByAdminId"
						class="formStuff" required> 
					<br>
					<br>

					<button type="submit">Add New Product</button> <!-- eclipse auto format makes me mad -->
				</fieldset>
			</form>
		</div>

		<div id="editInformation" class="admin-functions-box">
			<h2 class="admin-functions-headers" id ="swivel">Edit Product Information</h2>
			<table id="editTable">
				<thead>
					<tr>
						<th>ID</th>
            			<th>Name</th>
            			<th>Information</th>
            			<th>Price</th>
            			<th>Condition</th>
            			<th>Quantity</th>
            			<th>Status</th>
            			<th>Date</th>
            			<th>Low Stock?</th>
            			<th>Category ID</th>
            			<th>Admin ID</th>
            			<th>Change</th>
					</tr>
				</thead>
				<tbody>
					<% 
						try {
						List<Product> theProducts = request.getAttribute("theProducts");
						for (Product product : theProducts){
					%>
						<tr>
							<td><%= product.getProductId() %></td>
							<td><%= product.getProductName() %></td>
							<td><%= product.getInfo() %></td>
							<td><%= product.getPrice() %></td>
							<td><%= product.getCondition() %></td>
							<td><%= product.getQuantityAvail() %></td>
							<td><%= product.getProductStatus() %></td>
							<td><%= product.getDateAdded() %></td>
							<td><%= product.getLowStockNotice() %></td>
							<td><%= product.getCategoryId() %></td>
							<td><%= product.getCreatedByAdminId() %></td>
							<td>
								<input type="hidden" id="theName" name="theName" value="<%= product.getProductName() %>">
								<input type="hidden" id="theInfo" name="theInfo" value="<%= product.getInfo() %>">
								<input type="hidden" id="thePrice" name="thePrice" value="<%= product.getPrice() %>">
								<input type="hidden" id="theQuantity" name="theQuantity" value="<%= product.getQuantityAvail() %>">
								<input type="hidden" id="theID" name="theID" value="<%= product.getProductId() %>">
								<a href="#" id="changeInfo" onclick="changeProduct('changeInfoForm')">Info</a>
								<a href="#" id="delete" onclick="changeProduct('deleteConfirm')">Delete</a>
							</td>
							
						</tr>
						<% }} catch (Exception e) {
							e.printStackTrace();
						} %>
				</tbody>
			</table>
			<div id="changeInfoForm" style = "display: none">
				<form action="<%= request.getContextPath() %>/AdminServlet" method="post">
					<fieldset>
					<legend>
						<h2 class="admin-functions-headers">Edit Listing</h2>
					</legend>
					<label for="id2">ID:</label> <input type="text"
						id="id2" name="id2" class="formStuff" readonly>
					<label for="productName2">Product Name:</label> <input type="text"
						id="productName2" name="productName2" class="formStuff" required>
					<br>
					<br> <label for="info2">Information:</label><br>
					<textarea id="info2" name="info2" class="formStuff" required> </textarea>
					<br>
					<br> <label for="price2">Price:</label> <input type="text"
						id="price2" name="price2" class="formStuff" required> 
					<br>
					<br> <label for="condition2">Condition:</label> 
					<select name="condition2" id="condition2" required>
    					<option value="New">New</option>
    					<option value="Like New">Like New</option>
    					<option value="Good">Good</option>
    					<option value="Fair">Fair</option>
    					<option value="Used">Used</option>
  					</select> 
					<br>
					<br> <label for="quantityAvail2">Old Quantity:</label> <input
						type="text" id="quantityAvail2" name="quantityAvail2"
						class="formStuff" readonly> <br><br>
					<label for="quantityAvail3">New Quantity:</label> <input
						type="text" id="quantityAvail3" name="quantityAvail3"
						class="formStuff" required> 
					<br>
					<br> <label for="productStatus2">Status:</label> 
					<select name="productStatus2" id="productStatus2" required>
    					<option value="Available" selected>Available</option>
    					<option value="Out_of_Stock">Out of Stock</option>
    					<option value="Inactive">Inactive</option>
  					</select>
  					<button type="submit">Change Product</button>
  					</fieldset>
				</form>
			</div>
			<div id="deleteConfirm" style="display:none">
				<form action="<%= request.getContextPath() %>/AdminServlet" method="post">
				<fieldset>
					<legend>
						<h2 class="admin-functions-headers">Confirm Deletion</h2>
					</legend>
					<label for="id3">ID:</label> <input type="text"
						id="id3" name="id3" class="formStuff" readonly> <br> <br>
					<label for="productName3">Product Name:</label> <input type="text"
						id="productName3" name="productName3" class="formStuff" disabled><br> <br>
					<label for="yes">please type <b>yes</b> to confirm</label> <input type="text"
						id="yes" name="yes" class="formStuff" pattern="[yY][eE][sS]" required> <!-- any variant of yes will work -->
					<br>
					<br> 
  					<button type="submit">Delete</button>
  					</fieldset>
				</form>
			</div>
		</div>
		
		<div id="restock" class="admin-functions-box">
			<h2 class="admin-functions-headers">Restock History</h2>
			<table id="restockTable">
				<thead>
					<tr>
						<th>Restock ID</th>
            			<th>Product ID</th>
            			<th>Admin ID</th>
            			<th>Quantity Added</th>
            			<th>Date</th>
					</tr>
				</thead>
				<tbody>
					<% 
						try {
						List<RestockHistory> theHistory = request.getAttribute("theHistory");
						for (RestockHistory history : theHistory){
					%>
						<tr>
							<td><%= history.getRestockId()%></td>
							<td><%= history.getResProductId() %></td>
							<td><%= history.getResAdminId() %></td>
							<td><%= history.getResQuantityAdded() %></td>
							<td><%= history.getRestockDate() %></td>
							
						</tr>
						<% }} catch (Exception e) {
							e.printStackTrace();
						} %>
				</tbody>
			</table>
		</div>


		<div id="monitor" class="admin-functions-box">
			<h2 class="admin-functions-headers">Monitor Users</h2>
		</div>

		<div id="suspend" class="admin-functions-box">
			<h2 class="admin-functions-headers">Suspend Users</h2>
		</div>

		<div id="reactivate" class="admin-functions-box">
			<h2 class="admin-functions-headers">Reactivate Users</h2>
		</div>
	</div>



</body>
</html>