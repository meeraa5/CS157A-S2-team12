package util;
import java.time.LocalDate;

public class RestockHistory {
	private int restockId;
    private int productId;
    private int adminId;
    private int quantityAdded;
    private LocalDate restockDate;
    
    protected RestockHistory() {
	}
    
    public RestockHistory(int restockId, int productId, int adminId, int quantityAdded, LocalDate restockDate) {
    	this.restockId = restockId;
    	this.productId = productId;
    	this.adminId = adminId;
    	this.quantityAdded = quantityAdded;
    	this.restockDate = restockDate;
    }
    
    public RestockHistory(int productId, int quantityAdded,LocalDate restockDate) {
    	this.productId = productId;
    	this.quantityAdded = quantityAdded;
    	this.restockDate = restockDate;
    }

	public int getRestockId() {
		return restockId;
	}

	public void setRestockId(int restockId) {
		this.restockId = restockId;
	}

	public int getResProductId() {
		return productId;
	}

	public void setResProductId(int productId) {
		this.productId = productId;
	}

	public int getResAdminId() {
		return adminId;
	}

	public void setResAdminId(int adminId) {
		this.adminId = adminId;
	}

	public int getResQuantityAdded() {
		return quantityAdded;
	}

	public void setResQuantityAdded(int quantityAdded) {
		this.quantityAdded = quantityAdded;
	}

	public LocalDate getRestockDate() {
		return restockDate;
	}

	public void setRestockDate(LocalDate restockDate) {
		this.restockDate = restockDate;
	}
    
    
    
}
