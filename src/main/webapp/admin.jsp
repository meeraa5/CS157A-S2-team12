<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.time.LocalDate"%>
<%@ page
	import="util.MySQLCon, util.Product, java.util.List, util.RestockHistory, util.Activity, util.User, dao.ProductDao"%>




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

	<header class="navbar">
		<div>
			<h1>Admin Dashboard</h1>
			<p>Welcome, Administrator.</p>
		</div>

		<nav class="nav-links">
			<a href="<%= request.getContextPath() %>/index.jsp"
				class="nav-button">Home</a> <a
				href="<%= request.getContextPath() %>/AuthServlet?action=logout"
				class="nav-button">Logout</a>
		</nav>
	</header>

	<script>
		function toggleVisibility(id) {
			hideAll();
			var theDiv = document.getElementById(id);
			if (theDiv.style.display == "none" || theDiv.style.display == "") {
				theDiv.style.display = "block";
				document.getElementById("switcher").value = id; // changes depending on what adminservlet should do next
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
		}
		
		function changeProduct(name, info, price, quantity, id){
			document.getElementById("editTable").style.display = "none"; // hide the table of products
			document.getElementById("changeInfoForm").style.display = "block";
			
			
			var theName = name;
			var theInfo = info;
			var thePrice = price;
			var theQuantity = quantity;
			var theId = id;
			// doing this just in case hehe...
			
			document.getElementById("productName2").placeholder = theName;
			document.getElementById("info2").placeholder = theInfo;
			document.getElementById("price2").placeholder = thePrice;
			document.getElementById("quantityAvail2").placeholder = theQuantity;
			document.getElementById("id2").placeholder = theId;
			// basically takes the product name, info, price, quantity from the java Product object 
			// then puts as placeholder in the form 
				
			document.getElementById("switcher").value = "editProduct";
			
		}
		
		function deleteP(id, name){
			document.getElementById("editTable").style.display = "none"; // hide the table of products
			document.getElementById("deleteConfirm").style.display = "block";
			
			var theId = id;
			var theName = name;
			
			document.getElementById("id3").placeholder = theId;
			document.getElementById("productName3").placeholder = theName;
		}
		
		function changeStatus(id, name, status){
			var theId = id;
			var theName = name;
			var theStatus = status;
			
			if(theStatus == "Deactivated" || theStatus == "Suspended"){
				document.getElementById("suspendedTable").style.display = "none"; // i named everything suspended but its suspended/deactivated users
				document.getElementById("reactivateConfirm").style.display = "block";
				document.getElementById("switcher").value = "reactivateCfm"; // though it should already be reactivate lmao
				document.getElementById("id4").placeholder = theId;
				document.getElementById("userName").placeholder = theName;
			}
			else if (theStatus == "Active"){
				document.getElementById("activeTable").style.display = "none";
				document.getElementById("suspendConfirm").style.display = "block";
				
				document.getElementById("switcher").value = "suspendCfm";
				
				document.getElementById("id5").placeholder = theId;
				document.getElementById("userName2").placeholder = theName;
			}
			else {
				console.log("either it broke or you're doing something you're not supposed to")
			}
			
		}

	</script>

	<h2>Management Options</h2>
	<ul>
		<li><a href="#" onclick="toggleVisibility('reports')">Analytics
				and Reports</a></li>
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
			<li><a href="#" onclick="toggleVisibility('monitor')">Monitor User Accounts</a></li>
			<li><a href="#" onclick="toggleVisibility('suspend')">Suspend User Account</a></li>
			<li><a href="#" onclick="toggleVisibility('reactivate')">Reactivate User Account</a></li>
		</ul>
	</div>
	<!-- samantha will do admin and admin servlet -->
	<!-- meera did reports  -->

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
				<div class="report-card">
					<strong>Total Registered Users</strong><br><%= totalUsers %></div>
				<div class="report-card">
					<strong>Total Products Listed</strong><br><%= totalProducts %></div>
				<div class="report-card">
					<strong>Completed Transactions</strong><br><%= totalTransactions %></div>
				<div class="report-card">
					<strong>Total Revenue</strong><br>$<%= String.format("%.2f", totalRevenue) %></div>
			</div>

			<h3>Monthly Revenue</h3>
			<table class="data-table">
				<tr>
					<th>Month</th>
					<th>Revenue</th>
				</tr>
				<%
				try (PreparedStatement monthly = reportCon.prepareStatement(
						"SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month, SUM(total_amount) AS revenue " +
						"FROM orders WHERE order_status IN ('Paid', 'Completed') GROUP BY DATE_FORMAT(order_date, '%Y-%m') ORDER BY order_month DESC");
					 ResultSet monthlyRs = monthly.executeQuery()) {
					while (monthlyRs.next()) {
				%>
				<tr>
					<td><%= monthlyRs.getString("order_month") %></td>
					<td>$<%= monthlyRs.getBigDecimal("revenue") %></td>
				</tr>
				<%
					}
				}
				%>
			</table>

			<h3>Most Purchased Products</h3>
			<table class="data-table">
				<tr>
					<th>Product</th>
					<th>Quantity Sold</th>
				</tr>
				<%
				try (PreparedStatement topProducts = reportCon.prepareStatement(
						"SELECT p.product_name, SUM(oi.quantity) AS quantity_sold " +
						"FROM order_items oi JOIN products p ON oi.product_id = p.product_id " +
						"GROUP BY p.product_id, p.product_name ORDER BY quantity_sold DESC LIMIT 5");
					 ResultSet topProductsRs = topProducts.executeQuery()) {
					while (topProductsRs.next()) {
				%>
				<tr>
					<td><%= topProductsRs.getString("product_name") %></td>
					<td><%= topProductsRs.getInt("quantity_sold") %></td>
				</tr>
				<%
					}
				}
				%>
			</table>

			<h3>Least Purchased Products</h3>
			<table class="data-table">
				<tr>
					<th>Product</th>
					<th>Quantity Sold</th>
				</tr>
				<%
					try (PreparedStatement lowProducts = reportCon.prepareStatement(
							"SELECT p.product_name, COALESCE(SUM(oi.quantity), 0) AS quantity_sold "
									+ "FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id "
									+ "GROUP BY p.product_id, p.product_name ORDER BY quantity_sold ASC, p.product_name ASC LIMIT 5");
							ResultSet lowProductsRs = lowProducts.executeQuery()) {
						while (lowProductsRs.next()) {
				%>
				<tr>
					<td><%= lowProductsRs.getString("product_name") %></td>
					<td><%= lowProductsRs.getInt("quantity_sold") %></td>
				</tr>
				<%
					}
				}
				%>
			</table>

			<h3>Low Inventory Alerts</h3>
			<table class="data-table">
				<tr>
					<th>Product</th>
					<th>Quantity Available</th>
					<th>Status</th>
				</tr>
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

		<!-- new product -->
		<div id="newProd" class="admin-functions-box">
			<form id="newProdForm"
				action="<%= request.getContextPath() %>/AdminServlet" method="post">
				<fieldset>
					<legend>
						<h2 class="admin-functions-headers">Create New Listing</h2>
					</legend>
					<label for="productName">Product Name:</label> <input type="text"
						id="productName" name="productName" class="formStuff" required>
					<br> <br> <label for="info">Information:</label><br>
					<textarea id="info" name="info" class="formStuff" required> </textarea>
					<br> <br> <label for="price">Price:</label> <input
						type="text" id="price" name="price" class="formStuff" required>
					<br> <br> <label for="condition">Condition:</label> <select
						name="condition" id="condition" required>
						<option value="New">New</option>
						<option value="Like New">Like New</option>
						<option value="Good">Good</option>
						<option value="Fair">Fair</option>
						<option value="Used">Used</option>
					</select> <br> <br> <label for="quantityAvail">Quantity:</label> <input
						type="text" id="quantityAvail" name="quantityAvail"
						class="formStuff" required> <br> <br> <label
						for="productStatus">Status:</label> <select name="productStatus"
						id="productStatus" required>
						<option value="Available" selected>Available</option>
						<option value="Out_of_Stock">Out of Stock</option>
						<option value="Inactive">Inactive</option>
					</select> <br> <br> 
					<label for="categoryId">Category ID:</label> 
					<input type="text" id="categoryId" name="categoryId" class="formStuff" required> <br> <br> 
					<label for="createdByAdminId">Admin ID:</label> <input type="text" id="createdByAdminId" name="createdByAdminId" class="formStuff" required> <br> <br>
					<input type="hidden" name="switcher" value="newProd">
					<button type="submit">Add New Product</button>
					<!-- eclipse auto format makes me mad -->
				</fieldset>
			</form>
		</div>

		<!-- edit, delete, restock -->
		<div id="editInformation" class="admin-functions-box">
			<h2 class="admin-functions-headers" id="swivel">Edit Product Information</h2>
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

						try 
						(Connection con = MySQLCon.getConnection();
        				PreparedStatement ps = con.prepareStatement("SELECT * FROM products;");
        				ResultSet rs = ps.executeQuery();){

        					while (rs.next()) {
            				int theId = rs.getInt("product_id");
            				String theName = rs.getString("product_name");
            				String theInfo = rs.getString("product_description");
            				float thePrice = rs.getFloat("price");
            				String theCondition = rs.getString("product_condition");
            				int theQuantity = rs.getInt("quantity_available");
            				String theStatus = rs.getString("product_status");
            				LocalDate theDate = rs.getDate("date_added").toLocalDate();
            				String theNotice = rs.getString("low_stock_notice");
            				int theCategory = rs.getInt("category_id");
            				int theAdmin = rs.getInt("created_by_admin_id");
					%>

    <tr>
        <td><%= theId %></td>
        <td><%= theName %></td>
        <td><%= theInfo %></td>
        <td><%= thePrice %></td>
        <td><%= theCondition %></td>
        <td><%= theQuantity %></td>
        <td><%= theStatus %></td>
        <td><%= theDate %></td>
        <td><%= theNotice %></td>
        <td><%= theCategory %></td>
        <td><%= theAdmin %></td>
        <td><a href="#" onclick="changeProduct('<%= theName %>','<%= theInfo %>', '<%= thePrice %>', '<%= theQuantity %>', '<%= theId %>')">Edit</a>
        <a href="#" onclick="deleteP('<%= theId %>', '<%= theName %>')">Delete</a>
        </td>
    </tr>

<%
        }

        rs.close();
        ps.close();
        con.close();

    } catch (Exception e) {
        out.println(e.getMessage());
    }
%>
				</tbody>
			</table>
			<!-- edit products -->
			<div id="changeInfoForm" style="display: none">
				<form action="<%= request.getContextPath() %>/AdminServlet"
					method="post">
					<fieldset>
						<legend>
							<h2 class="admin-functions-headers">Edit Listing</h2>
						</legend>
						<label for="id2">ID:</label> <input type="text" id="id2"
							name="id2" class="formStuff" readonly> <label
							for="productName2">Product Name:</label> <input type="text"
							id="productName2" name="productName2" class="formStuff" required>
						<br> <br> <label for="info2">Information:</label><br>
						<textarea id="info2" name="info2" class="formStuff" required> </textarea>
						<br> <br> <label for="price2">Price:</label> <input
							type="text" id="price2" name="price2" class="formStuff" required>
						<br> <br> <label for="condition2">Condition:</label> <select
							name="condition2" id="condition2" required>
							<option value="New">New</option>
							<option value="Like New">Like New</option>
							<option value="Good">Good</option>
							<option value="Fair">Fair</option>
							<option value="Used">Used</option>
						</select> <br> <br> <label for="quantityAvail2">Old
							Quantity:</label> <input type="text" id="quantityAvail2"
							name="quantityAvail2" class="formStuff" readonly> <br>
						<br> <label for="quantityAvail3">New Quantity:</label> <input
							type="text" id="quantityAvail3" name="quantityAvail3"
							class="formStuff" required> <br> <br> <label
							for="productStatus2">Status:</label> <select
							name="productStatus2" id="productStatus2" required>
							<option value="Available" selected>Available</option>
							<option value="Out_of_Stock">Out of Stock</option>
							<option value="Inactive">Inactive</option>
						</select>
						<input type="hidden" name="switcher" value="editProduct">
						<button type="submit">Change Product</button>
					</fieldset>
				</form>
			</div>
			<!-- delete products -->
			<div id="deleteConfirm" style="display: none">
				<form action="<%= request.getContextPath() %>/AdminServlet"
					method="post">
					<fieldset>
						<legend>
							<h2 class="admin-functions-headers">Confirm Deletion</h2>
						</legend>
						<label for="id3">ID:</label> <input type="text" id="id3"
							name="id3" class="formStuff" readonly> <br> <br>
						<label for="productName3">Product Name:</label> <input type="text"
							id="productName3" name="productName3" class="formStuff" disabled><br>
						<br> <label for="yes">please type <b>yes</b> to
							confirm
						</label> <input type="text" id="yes" name="yes" class="formStuff"
							pattern="[yY][eE][sS]" required>
						<input type="hidden" name="switcher" value="delete">
						<!-- any variant of yes will work -->
						<br> <br>
						<button type="submit">Delete</button>
					</fieldset>
				</form>
			</div>
		</div>

		<!-- show restock history -->
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
					try 
        				(Connection con = MySQLCon.getConnection();
        				PreparedStatement ps = con.prepareStatement("SELECT * FROM restock_history;");
        				ResultSet rs = ps.executeQuery();){

        				while (rs.next()) {
            				int theId = rs.getInt("restock_id");
            				int theProdId = rs.getInt("product_id");
            				int theAdmin = rs.getInt("admin_id");
            				int theQuantity = rs.getInt("quantity_added");
            				LocalDate theDate = rs.getDate("restock_date").toLocalDate();
					%>

    <tr>
        <td><%= theId %></td>
        <td><%= theProdId %></td>
        <td><%= theAdmin %></td>
        <td><%= theQuantity %></td>
        <td><%= theDate %></td>
    </tr>

<%
        }

        rs.close();
        ps.close();
        con.close();

    } catch (Exception e) {
        out.println(e.getMessage());
    }
%>
				</tbody>
			</table>
		</div>

		<!-- Show activity log -->
		<div id="monitor" class="admin-functions-box">
			<h2 class="admin-functions-headers">Monitor Users</h2>
			<table id="monitorTable">
				<thead>
					<tr>
						<th>Log ID</th>
						<th>User ID</th>
						<th>Type</th>
						<th>Time</th>
						<th>Detail</th>
					</tr>
				</thead>

				<%
    			String query = "SELECT * FROM activity_log;";
    			try 
        		(Connection con = MySQLCon.getConnection();
        		PreparedStatement ps = con.prepareStatement(query);
        		ResultSet rs = ps.executeQuery();) {

        while (rs.next()) {
            int theId = rs.getInt("log_id");
            int theUser = rs.getInt("user_id");
            String theType = rs.getString("activity_type");
            LocalDate theTime = rs.getDate("activity_time").toLocalDate();
            String theDetail = rs.getString("activity_detail");
					%>

				<tr>
					<td><%= theId %></td>
					<td><%= theUser %></td>
					<td><%= theType %></td>
					<td><%= theTime %></td>
					<td><%= theDetail %></td>
				</tr>

				<%
        			}
        			rs.close();
        			ps.close();
        			con.close();
    				} catch (Exception e) {
        			out.println(e.getMessage());
    				}
%>

			</table>

		</div>

		<!-- Suspend users -->
		<div id="suspend" class="admin-functions-box">
			<h2 class="admin-functions-headers">Suspend Users</h2>
			<table id="activeTable">
				<thead>
					<tr>
						<th>User ID</th>
						<th>Name</th>
						<th>Email</th>
						<th>Status</th>
					</tr>
				</thead>
				<tbody>
					<%
                        try (Connection con = MySQLCon.getConnection();
                        PreparedStatement ps = con.prepareStatement(
                        "SELECT * FROM users WHERE status = 'Active'");
                        ResultSet rs = ps.executeQuery()) {

                        while (rs.next()) {
                        %>
					<tr>
						<td><%= rs.getInt("user_id") %></td>
						<td><%= rs.getString("full_name") %></td>
						<td><%= rs.getString("sjsu_email") %></td>
						<td><%= rs.getString("status") %></td>
						<td><a href="#" class="reactivateButton"
							onclick="changeStatus('<%= rs.getInt("user_id") %>',
                                '<%= rs.getString("full_name").replace("'", "\\'") %>',
                                '<%= rs.getString("status") %>')">
								Suspend</a></td>
					</tr>
					<%
                        } 
                        con.close();
                        ps.close();
                        rs.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    %>
				</tbody>
			</table>
			<div id="suspendConfirm" style="display: none">
				<form action="<%= request.getContextPath() %>/AdminServlet"
					method="post">
					<fieldset>
						<legend>
							<h2 class="admin-functions-headers">Confirm Suspension</h2>
						</legend>
						<label for="id5">ID:</label> <input type="text" id="id5"
							name="id5" class="formStuff" readonly> <br> <br>
						<label for="userName2">User:</label> <input type="text"
							id="userName2" name="userName2" class="formStuff" disabled><br>
						<br> <label for="yes2">please type <b>yes</b> to
							confirm
						</label> <input type="text" id="yes2" name="yes2" class="formStuff"
							pattern="[yY][eE][sS]" required>
						<input type="hidden" name="switcher" value="suspendCfm">
						<!-- any variant of yes will work -->
						<br> <br>
						<button type="submit">Suspend</button>
					</fieldset>
				</form>
			</div>
		</div>

		<!-- reactivate users -->
		<div id="reactivate" class="admin-functions-box">
			<h2 class="admin-functions-headers">Reactivate Users</h2>
			<table id="suspendedTable">
				<thead>
					<tr>
						<th>User ID</th>
						<th>Name</th>
						<th>Email</th>
						<th>Status</th>
					</tr>
				</thead>
				<tbody>
					<%
                        try (Connection con = MySQLCon.getConnection();
                        PreparedStatement ps = con.prepareStatement(
                        "SELECT * FROM users WHERE status = 'Deactivated' OR status = 'Suspended'");
                        ResultSet rs = ps.executeQuery()) {

                        while (rs.next()) {
                        %>
					<tr>
						<td><%= rs.getInt("user_id") %></td>
						<td><%= rs.getString("full_name") %></td>
						<td><%= rs.getString("sjsu_email") %></td>
						<td><%= rs.getString("status") %></td>
						<td><a href="#" class="reactivateButton"
							onclick="changeStatus('<%= rs.getInt("user_id") %>',
                                '<%= rs.getString("full_name").replace("'", "\\'") %>',
                                '<%= rs.getString("status") %>')">
								Reactivate </a></td>
					</tr>
					<%
                        } con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    %>
				</tbody>
			</table>

			<div id="reactivateConfirm" style="display: none">
				<form action="<%= request.getContextPath() %>/AdminServlet"
					method="post">
					<fieldset>
						<legend>
							<h2 class="admin-functions-headers">Confirm Reactivation</h2>
						</legend>
						<label for="id4">ID:</label> <input type="text" id="id4"
							name="id4" class="formStuff" readonly> <br> <br>
						<label for="userName">User:</label> <input type="text"
							id="userName" name="userName" class="formStuff" disabled><br>
						<br> <label for="yes3">please type <b>yes</b> to
							confirm
						</label> <input type="text" id="yes3" name="yes3" class="formStuff"
							pattern="[yY][eE][sS]" required>
						<input type="hidden" name="switcher" value="reactivateCfm">
						<!-- any variant of yes will work -->
						<br> <br>
						<button type="submit">Reactivate</button>
					</fieldset>
				</form>
			</div>
		</div>


	</div>



</body>
</html>