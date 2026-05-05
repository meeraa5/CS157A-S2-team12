<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Login/Sign UP </title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
</head>
<body>
<div class= "login-container">
<h2 id="form-title">Login</h2>
 

<%

String error = request.getParameter("Error");
String success = request.getParameter("Success");

if (error !=null) {
	 %>
     <div class="message"><%= error %></div>
   <%
 }
 if (success != null) {
    %>
 <div class="message success"><%= success %></div>
    
    <%
        } 
  %>


 
<form id="auth-form" action="<%= request.getContextPath() %>/AuthServlet" method="post" onsubmit="return validateForm()">
    <input type="hidden" id="mode" name="mode" value="login">

    <div id="full-name-container" style="display: none;">
        <label for="full_name">Full Name</label>
        <input type="text" id="full_name" name="full_name">
    </div>

    <label for="email">Email</label>
    <input type="email" id="email" name="email" required>

    <label for="password">Password</label>
    <input type="password" id="password" name="password" required>

    <div id="confirm-password-container" style="display: none;">
        <label for="confirm_password">Confirm Password</label>
        <input type="password" id="confirm_password" name="confirm_password">
    </div>
    


    <button type="submit" id="submit-btn">Login</button>
</form>

<p id="toggle-text">
    Do not have an account?
    <a href="#" onclick="toggleMode(); return false;">Sign up</a>
</p>




<script>
    let isLogin = true;
    
    function toggleMode() {
    	isLogin = !isLogin;
    	
    	const formTitle = document.getElementById("form-title");
    	const submitBtn = document.getElementById("submit-btn");
    	const toggleText = document.getElementById("toggle-text");
    	const modeInput = document.getElementById("mode");
    	const confirmContainer = document.getElementById("confirm-password-container");
        const confirmPasswordInput = document.getElementById("confirm_password");
        const fullNameContainer = document.getElementById("full-name-container");
        const fullNameInput = document.getElementById("full_name");


        if (isLogin) {
            formTitle.textContent = "Login";
            submitBtn.textContent = "Login";
            toggleText.innerHTML = `Do not have an account? <a href="#" onclick="toggleMode(); return false;">Sign up</a>`;
            confirmContainer.style.display = "none";
            fullNameContainer.style.display = "none";
            confirmPasswordInput.required = false;
            fullNameInput.required = false;
            modeInput.value = "login";
        } else {
            formTitle.textContent = "Sign Up";
            submitBtn.textContent = "Register Account";
            toggleText.innerHTML = `Already have an account? <a href="#" onclick="toggleMode(); return false;">Login</a>`;
            confirmContainer.style.display = "block";
            fullNameContainer.style.display = "block";
            confirmPasswordInput.required = true;
            fullNameInput.required = true;
            modeInput.value = "signup";
        }
    }	

        function validateForm() {
        	const email = document.getElementById("email").value.trim().toLowerCase();
        	const password = document.getElementById("password").value;
        	const confirmPassword = document.getElementById("confirm_password").value;
        	const mode = document.getElementById("mode").value;
        	const fullName = document.getElementById("full_name").value.trim();

        	
    	if (!(email.endsWith("@sjsu.edu")|| email.endsWith("@my.sjsu.edu"))) {
    		alert("Only with SJSU email addresses are allowed.");
    		return false;
    	
    	}
   
    	if (mode=="signup") {
    			if (password!=confirmPassword){
    				alert("Passwords do not match please try again.")
    				return false; 
    			}
    		}
    	return true;    	
    	 	
    	
    	}
    	
 </script>
</body>
</html>
