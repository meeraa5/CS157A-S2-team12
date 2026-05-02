<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet"%>
<%@ page import="util.MySQLCon"%>

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
			}
		}

		function hideAll() { // this is crude but oh well. hides all divs
			monitor.style.display = "none";
			newProd.style.display = "none";
			editInformation.style.display = "none";
			reactivate.style.display = "none";
			suspend.style.display = "none";
			changeQuantity.style.display = "none";
			restockProducts.style.display = "none";
		}
	</script>

	<%
	Connection con = null;
	PreparedStatement ps = null;
	ResultSet rs = null;
	try {
		con = MySQLCon.getConnection();

		String sql = "SELECT ";

		ps = con.prepareStatement(sql);
		ps.setInt(1, userId);
		rs = ps.executeQuery();

		boolean hasUsers = false;

		while (rs.next()) {
			hasUsers = true;
		}
	} finally {

	}
	%>

	<h2>Management Options</h2>
	<ul>
		<li><a href="#" onclick="toggleVisibility('newProd')">Create
				New Product Listing</a></li>
		<li><a href="#" onclick="toggleVisibility('editInformation')">Edit
				Product Information</a></li>
		<li><a href="#" onclick="toggleVisibility('changeQuantity')">Adjust
				Inventory Quantities</a></li>
		<li><a href="#" onclick="toggleVisibility('restockProducts')">Restock
				Products</a></li>

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

	<div id="adminFunctions" class="admin-functions">
		<div id="newProd" class="admin-functions-box">
			<h2 class="admin-functions-headers">Create New Listing</h2>
			<form id="newProdForm" action="/newProd" method="post">
				
			</form>
		</div>

		<div id="editInformation" class="admin-functions-box">
			<h2 class="admin-functions-headers">Edit Product Information</h2>
		</div>

		<div id="changeQuantity" class="admin-functions-box">
			<h2 class="admin-functions-headers">Adjust Inventory Quantities</h2>
		</div>

		<div id="restockProducts" class="admin-functions-box">
			<h2 class="admin-functions-headers">Restock Products</h2>
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