package util;

import java.time.LocalDate;

public class Activity {
	private int logId;
	private Integer userId;
	private String activityType;
	private LocalDate activityTime;
	private String activityDetail;

	protected Activity() {
	}

	public Activity(int logId, Integer userId, String activityType, LocalDate activityTime, String activityDetail) {
		this.logId = logId;
		this.userId = userId;
		this.activityType = activityType;
		this.activityTime = activityTime;
		this.activityDetail = activityDetail;
	}

	public int getLogId() {
		return logId;
	}

	public void setLogId(int logId) {
		this.logId = logId;
	}

	public Integer getUserId() {
		return userId;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	public String getActivityType() {
		return activityType;
	}

	public void setActivityType(String activityType) {
		this.activityType = activityType;
	}

	public LocalDate getActivityTime() {
		return activityTime;
	}

	public void setActivityTime(LocalDate activityTime) {
		this.activityTime = activityTime;
	}

	public String getActivityDetail() {
		return activityDetail;
	}

	public void setActivityDetail(String activityDetail) {
		this.activityDetail = activityDetail;
	}
	
	
}
