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
			var theDiv = document.getElementById(id);
			if (theDiv.style.display == "none") {
				theDiv.style.display = "block";
			} else {
				theDiv.style.display = "none";
			}
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
		<li><a href="#" onclick="toggleVisibility('new-prod')">Create
				New Product Listing</a></li>
		<li><a href="#" onclick="toggleVisibility('edit-information')">Edit
				Product Information</a></li>
		<li><a href="#" onclick="toggleVisibility('adust-quantity')">Adjust
				Inventory Quantities</a></li>
		<li><a href="#" onclick="toggleVisibility('restock-products')">Restock
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
	<!-- there were two of this user management div so i (samantha) deleted it -->
	<!-- samantha will do admin and admin servlet -->

	<div class="admin-functions">
		<div id="new-prod" class="admin-functions-box">
			<h2 class="admin-functions-headers">Create New Listing</h2>
			<p>test</p>
		</div>

		<div id="edit-information"></div>

		<div id="adjust-quantity"></div>

		<div id="restock-products"></div>

		<div id="monitor"></div>

		<div id="suspend"></div>

		<div id="reactivate"></div>
	</div>



</body>
</html>