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

//Mainly UI structure, displaying results and styling without the actual use of database yet 
//Plan to add like picture of SJSU to make it more appeasing in terms of looks  (Background Image)
 

<%
//Decision making 
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
        } //This is mainly a condition to determine what message to display or recieve either success or error
  %>


 
<form id="auth-form" action="<%= request.getContextPath() %>/AuthServlet" method="post" onsubmit="return validateForm()">Bu
 <input type="hidden" id="mode" name="mode" value="login"> //User login or registration
  
<label for="email">Email</label>
 <input type="email" id="email" name="email" required> //User email @sjsu.edu required


 <label for="password">Password</label>
<input type="password" id="password" name="password" required> //Password by the user
        
        
 <div id="confirm-password-container" style="display: none;">
 <label for="confirm_password">Confirm Password</label> //Comfirm password must be same as the password entered 
        <input type="password" id="confirm_password" name="confirm_password">
 </div>
 <button type = "submit" id="submit-btn">Login</button>
 </form> 
<p id= "toggle-text">
Do not have an account?
 <a href="#" onclick="toggleMode(); return false;">Sign up</a>
</p>
</div>

//This is just main authentication for login or registration 
//It collects user credentials from AuthServlet.java 




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
    
    	if(isLogin) {
    		formTitle.textContent ="Login";
    		submitBtn.textContent="Login";
    		toggleText.innerHTML = `Do not have an account? <a href="#" onclick="toggleMode(); return false;">Sign up</a>`;
    		confirmContainer.style.display = "none";
    		confirmPasswordInput.required.required=true;
            modeInput.value = "login";	
    	}else{
    		formTitle.textContent = "Sign UP";
            submitBtn.textContent = "Register Account";
            toggleText.innerHTML = `Already have an account? <a href="#" onclick="toggleMode(); return false;">Login</a>`;
    		confirmContainer.style.display="block";
    		confirmPasswordInput.required=false;
    		modeInput.value= "signup"
    		
    	}
    }	
//Validation from this function is not enough Auth is still needed for account authentication 
        function validateForm() {
        	const email = document.getElementById("email").value.trim().toLowerCase();
        	const password = document.getElementById("password").value;
        	const confirmPassword = document.getElementById("confirm_password").value;
        	const mode = document.getElementById("mode").value;
        	//Functionality for registration 
    	
    	//Ensures for SJSU email restriction
    	if (!(email.endsWith("@sjsu.edu")|| email.endsWith("@my.sjsu.edu"))) {
    		alert("Only with SJSU email addresses are allowed.");
    		return false;
    	
    	}
   
    	if (mode=="signup") {
    			if (password!=confirmPassword){
    				alert("Passwords do not match please try again.")
    				return false; //Condition that ensures that the passwords match when registering account 
    				
    			}
    		}
    	return true;    	
    	 	
    	
    	}
    	
 </script>
</body>
</html>
