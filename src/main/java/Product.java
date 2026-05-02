import java.time.LocalDate;
public class Product {
	private int productId;
	private String productName;
	private String info;
	private int price;
	private String condition;
	private int quantityAvail;
	private String productStatus;
	private LocalDate dateAdded;
	private String lowStockNotice;
	private int userId;
	private int categoryId;
    private int createdByAdminId;

	protected Product() {
	}

	public Product(
			int productId,
			String productName,
			String info, int price,
			String condition,
			int quantityAvail,
			String productStatus,
			LocalDate dateAdded,
			String lowStockNotice, 
			int userId,
			int categoryId,
			int createdByAdminId
			) { // i hate when parameters are like this but it's easier to see
		// create product entity to easily (at least i hope so) create and delete products
		this.productId = productId;
		this.productName = productName;
		this.info = info;
		this.price = price;
		this.condition = condition;
		this.quantityAvail = quantityAvail;
		this.productStatus = productStatus;
		this.dateAdded = dateAdded;
		this.lowStockNotice = lowStockNotice;
		this.userId = userId;
		this.categoryId = categoryId;
		this.createdByAdminId =  createdByAdminId;

	}
	
	// getters and setters to edit products
	
	

	public int getProductId() {
		return productId;
	}

	public void setProductId(int productId) {
		this.productId = productId;
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public String getInfo() {
		return info;
	}

	public void setInfo(String info) {
		this.info = info;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public String getCondition() {
		return condition;
	}

	public void setCondition(String condition) {
		this.condition = condition;
	}

	public int getQuantityAvail() {
		return quantityAvail;
	}

	public void setQuantityAvail(int quantityAvail) {
		this.quantityAvail = quantityAvail;
	}

	public String getProductStatus() {
		return productStatus;
	}

	public void setProductStatus(String productStatus) {
		this.productStatus = productStatus;
	}

	public LocalDate getDateAdded() {
		return dateAdded;
	}

	public void setDateAdded(LocalDate dateAdded) {
		this.dateAdded = dateAdded;
	}

	public String getLowStockNotice() {
		return lowStockNotice;
	}

	public void setLowStockNotice(String lowStockNotice) {
		this.lowStockNotice = lowStockNotice;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public int getCategoryId() {
		return categoryId;
	}

	public void setCategoryId(int categoryId) {
		this.categoryId = categoryId;
	}

	public int getCreatedByAdminId() {
		return createdByAdminId;
	}

	public void setCreatedByAdminId(int createdByAdminId) {
		this.createdByAdminId = createdByAdminId;
	}
	
	


}
