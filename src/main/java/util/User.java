package util;

import java.time.LocalDate;

public class User {

    private int userId;
    private String fullName;
    //private String preferredName;
    private String sjsuEmail;
    private String contactDetails;
    //private LocalDate createdDate;
    private String status;
    
    protected User() {
    }
    
    public User(
    		int userId,
    		String fullName,
    		//String preferredName,
            String sjsuEmail,
            String contactDetails,
            //LocalDate createdDate,
            String status
    		) {

    this.userId = userId;
    this.fullName = fullName;
    //this.preferredName = preferredName;
    this.sjsuEmail = sjsuEmail;
    this.contactDetails = contactDetails;
    //this.createdDate = createdDate;
    this.status = status;
    }
    
    public User(
    		int userId,
    		String fullName,
    		//String preferredName,
            String sjsuEmail,
            //LocalDate createdDate,
            String status
    		) {

    this.userId = userId;
    this.fullName = fullName;
    //this.preferredName = preferredName;
    this.sjsuEmail = sjsuEmail;
    //this.createdDate = createdDate;
    this.status = status;
    }

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public String getFullName() {
		return fullName;
	}

	public void setFullName(String fullName) {
		this.fullName = fullName;
	}

	/*
	 * public String getPreferredName() { return preferredName; }
	 * 
	 * public void setPreferredName(String preferredName) { this.preferredName =
	 * preferredName; }
	 */

	public String getSjsuEmail() {
		return sjsuEmail;
	}

	public void setSjsuEmail(String sjsuEmail) {
		this.sjsuEmail = sjsuEmail;
	}

	public String getContactDetails() {
		return contactDetails;
	}

	public void setContactDetails(String contactDetails) {
		this.contactDetails = contactDetails;
	}

	/*
	 * public LocalDate getCreatedDate() { return createdDate; }
	 * 
	 * public void setCreatedDate(LocalDate createdDate) { this.createdDate =
	 * createdDate; }
	 */

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}	
    
    

}
