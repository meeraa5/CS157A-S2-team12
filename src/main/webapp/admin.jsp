<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.MySQLCon, java.time.LocalDate" %>
<%
    // Session and Role Verification
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
    <title>Admin Dashboard | Spartan Exchange</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/styles.css">
    <script>
        function toggleVisibility(id) {
            // Hides all sections before showing the selected one
            const sections = ["reports", "monitor", "newProd", "editInformation", "reactivate", "suspend", "restock"];
            sections.forEach(s => {
                var el = document.getElementById(s);
                if(el) el.style.display = "none";
            });
            var target = document.getElementById(id);
            if(target) target.style.display = "block";
        }

        function changeProduct(name, info, price, quantity, id) {
            document.getElementById("editTable").style.display = "none";
            document.getElementById("changeInfoForm").style.display = "block";
            document.getElementById("productName2").value = name;
            document.getElementById("info2").value = info;
            document.getElementById("price2").value = price;
            // CRITICAL: This fills the 'Old Qty' field so the Servlet can calculate restock
            document.getElementById("quantityAvail2").value = quantity;
            document.getElementById("id2").value = id;
        }

        function changeStatus(id, name, status) {
            if(status === "Deactivated" || status === "Suspended") {
                // Reactivate Logic
                document.getElementById("suspendedTable").style.display = "none";
                document.getElementById("reactivateConfirm").style.display = "block";
                document.getElementById("id4").value = id;
                document.getElementById("userName").value = name;
            } else {
                // Suspend Logic
                document.getElementById("activeTable").style.display = "none";
                document.getElementById("suspendConfirm").style.display = "block";
                document.getElementById("id5").value = id;
                document.getElementById("userName2").value = name;
            }
        }
    </script>
</head>
<body>

    <header class="navbar">
        <div>
            <h1>Admin Dashboard</h1>
            <p>Welcome, Administrator.</p>
        </div>
        <nav class="nav-links">
            <a href="<%= request.getContextPath() %>/index.jsp" class="nav-button">Home</a> 
            <a href="AuthServlet?action=logout" class="nav-button">Logout</a>
        </nav>
    </header>

    <div class="admin-nav-container">
        <ul class="admin-menu">
            <li><a href="#" onclick="toggleVisibility('reports')">Analytics</a></li>
            <li><a href="#" onclick="toggleVisibility('newProd')">New Product</a></li>
            <li><a href="#" onclick="toggleVisibility('editInformation')">Edit Inventory</a></li>
            <li><a href="#" onclick="toggleVisibility('restock')">Restock History</a></li>
            <li><a href="#" onclick="toggleVisibility('monitor')">Activity Logs</a></li>
            <li><a href="#" onclick="toggleVisibility('suspend')">Suspend User</a></li>
            <li><a href="#" onclick="toggleVisibility('reactivate')">Reactivate User</a></li>
        </ul>
    </div>

    <div id="adminFunctions" class="admin-functions">

        <div id="reports" class="admin-functions-box" style="display:none;">
            <h2>Analytics</h2>
            <%
                try (Connection con = MySQLCon.getConnection(); Statement st = con.createStatement()) {
                    ResultSet rsUsers = st.executeQuery("SELECT COUNT(*) FROM users");
                    int totalUsers = rsUsers.next() ? rsUsers.getInt(1) : 0;
                    ResultSet rsRev = st.executeQuery("SELECT SUM(total_amount) FROM orders WHERE order_status IN ('Paid', 'Completed')");
                    double revenue = rsRev.next() ? rsRev.getDouble(1) : 0.0;
            %>
            <div class="report-grid">
                <p><strong>Total Users:</strong> <%= totalUsers %></p>
                <p><strong>Revenue:</strong> $<%= String.format("%.2f", revenue) %></p>
            </div>
            <% } catch(Exception e) { out.println(e.getMessage()); } %>
        </div>

        <div id="newProd" class="admin-functions-box" style="display:none;">
            <h2>Create Listing</h2>
            <form action="AdminServlet" method="post">
                <input type="hidden" name="switcher" value="newProd">
                <label>Product Name:</label> <input type="text" name="productName" required><br><br>
                <label>Info:</label><br><textarea name="info" required></textarea><br><br>
                <label>Price:</label> <input type="text" name="price" required><br><br>
                <label>Category ID:</label> <input type="text" name="categoryId" required><br><br>
                <label>Admin ID:</label> <input type="text" name="createdByAdminId" required><br><br>
                <label>Initial Quantity:</label> <input type="text" name="quantityAvail" required><br><br>
                <button type="submit">Add New Product</button>
            </form>
        </div>

        <div id="editInformation" class="admin-functions-box" style="display:none;">
            <h2>Product Inventory</h2>
            <table id="editTable" class="data-table">
                <thead><tr><th>ID</th><th>Name</th><th>Stock</th><th>Action</th></tr></thead>
                <tbody>
                <%
                    try (Connection con = MySQLCon.getConnection(); Statement st = con.createStatement();
                         ResultSet rs = st.executeQuery("SELECT * FROM products")) {
                        while(rs.next()){
                %>
                    <tr>
                        <td><%= rs.getInt("product_id") %></td>
                        <td><%= rs.getString("product_name") %></td>
                        <td><%= rs.getInt("quantity_available") %></td>
                        <td><button onclick="changeProduct('<%= rs.getString("product_name") %>','<%= rs.getString("product_description") %>', '<%= rs.getFloat("price") %>', '<%= rs.getInt("quantity_available") %>', '<%= rs.getInt("product_id") %>')">Edit</button></td>
                    </tr>
                <% } } catch(Exception e) { out.print(e.getMessage()); } %>
                </tbody>
            </table>

            <div id="changeInfoForm" style="display:none;">
                <form action="AdminServlet" method="post">
                    <input type="hidden" name="switcher" value="editProduct">
                    <input type="hidden" name="id2" id="id2">
                    <h3>Edit Details</h3>
                    <label>Name:</label> <input type="text" id="productName2" name="productName2" required><br><br>
                    <label>Description:</label><br><textarea id="info2" name="info2" required></textarea><br><br>
                    <label>Price:</label> <input type="text" id="price2" name="price2" required><br><br>
                    <label>Old Qty:</label> <input type="text" id="quantityAvail2" name="quantityAvail2" readonly style="background:#eee;"><br><br>
                    <label>New Qty:</label> <input type="text" name="quantityAvail3" placeholder="Enter new total" required><br><br>
                    <button type="submit">Save Changes</button>
                    <button type="button" onclick="location.reload()">Cancel</button>
                </form>
            </div>
        </div>

        <div id="restock" class="admin-functions-box" style="display:none;">
            <h2>Restock History</h2>
            <table class="data-table">
                <thead><tr><th>Prod ID</th><th>Qty Added</th><th>Date</th></tr></thead>
                <%
                    try (Connection con = MySQLCon.getConnection(); Statement st = con.createStatement();
                         ResultSet rs = st.executeQuery("SELECT * FROM restock_history ORDER BY restock_date DESC")) {
                        while(rs.next()){
                %>
                <tr>
                    <td><%= rs.getInt("product_id") %></td>
                    <td><%= rs.getInt("quantity_added") %></td>
                    <td><%= rs.getTimestamp("restock_date") %></td>
                </tr>
                <% } } catch(Exception e) {} %>
            </table>
        </div>

        <div id="monitor" class="admin-functions-box" style="display:none;">
            <h2>Activity Logs</h2>
            <table class="data-table">
                <thead><tr><th>Log ID</th><th>Type</th><th>Time</th></tr></thead>
                <%
                    try (Connection con = MySQLCon.getConnection(); Statement st = con.createStatement();
                         ResultSet rs = st.executeQuery("SELECT * FROM activity_log ORDER BY log_id DESC")) {
                        while(rs.next()){
                %>
                <tr>
                    <td><%= rs.getInt("log_id") %></td>
                    <td><%= rs.getString("activity_type") %></td>
                    <td><%= rs.getTimestamp("activity_time") %></td>
                </tr>
                <% } } catch(Exception e) {} %>
            </table>
        </div>

        <div id="suspend" class="admin-functions-box" style="display:none;">
            <h2>Suspend Users</h2>
            <table id="activeTable" class="data-table">
                <thead><tr><th>ID</th><th>Name</th><th>Status</th><th>Action</th></tr></thead>
                <%
                    try (Connection con = MySQLCon.getConnection(); Statement st = con.createStatement();
                         ResultSet rs = st.executeQuery("SELECT * FROM users WHERE status = 'Active'")) {
                        while(rs.next()){
                %>
                <tr>
                    <td><%= rs.getInt("user_id") %></td>
                    <td><%= rs.getString("full_name") %></td>
                    <td><%= rs.getString("status") %></td>
                    <td><button onclick="changeStatus('<%= rs.getInt("user_id") %>','<%= rs.getString("full_name") %>','Active')">Suspend</button></td>
                </tr>
                <% } } catch(Exception e) {} %>
            </table>
            <div id="suspendConfirm" style="display:none; border:1px solid red; padding:10px;">
                <form action="AdminServlet" method="post">
                    <input type="hidden" name="switcher" value="suspendCfm">
                    <input type="hidden" name="id5" id="id5">
                    <p>Confirm suspension for: <input type="text" id="userName2" disabled style="border:none; font-weight:bold;"></p>
                    <label>Type 'yes' to confirm:</label>
                    <input type="text" name="yes2" pattern="[yY][eE][sS]" placeholder="Type 'yes'" required>
                    <br><br>
                    <button type="submit">Confirm Suspension</button>
                    <button type="button" onclick="location.reload()">Cancel</button>
                </form>
            </div>
        </div>

        <div id="reactivate" class="admin-functions-box" style="display:none;">
            <h2>Reactivate Users</h2>
            <table id="suspendedTable" class="data-table">
                <thead><tr><th>ID</th><th>Name</th><th>Status</th><th>Action</th></tr></thead>
                <%
                    try (Connection con = MySQLCon.getConnection(); Statement st = con.createStatement();
                         ResultSet rs = st.executeQuery("SELECT * FROM users WHERE status != 'Active'")) {
                        while(rs.next()){
                %>
                <tr>
                    <td><%= rs.getInt("user_id") %></td>
                    <td><%= rs.getString("full_name") %></td>
                    <td><%= rs.getString("status") %></td>
                    <td><button onclick="changeStatus('<%= rs.getInt("user_id") %>','<%= rs.getString("full_name") %>','Suspended')">Reactivate</button></td>
                </tr>
                <% } } catch(Exception e) {} %>
            </table>
            <div id="reactivateConfirm" style="display:none; border:1px solid green; padding:10px;">
                <form action="AdminServlet" method="post">
                    <input type="hidden" name="switcher" value="reactivateCfm">
                    <input type="hidden" name="id4" id="id4">
                    <p>Confirm reactivation for: <input type="text" id="userName" disabled style="border:none; font-weight:bold;"></p>
                    <label>Type 'yes' to confirm:</label>
                    <input type="text" name="yes3" pattern="[yY][eE][sS]" placeholder="Type 'yes'" required>
                    <br><br>
                    <button type="submit">Confirm Reactivation</button>
                    <button type="button" onclick="location.reload()">Cancel</button>
                </form>
            </div>
        </div>

    </div>
</body>
</html>