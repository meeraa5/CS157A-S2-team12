package dao;

import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import util.Activity;
import util.MySQLCon;
import util.Product;

public class ActivityDao {
	private final static String getActivityStr = "SELECT * FROM activity_log;";
	
    public static List<Activity> selectAllLogs(){
    	List<Activity> logs = new ArrayList<>();
    	try {
    		Connection con = MySQLCon.getConnection();
            PreparedStatement listActPs = con.prepareStatement(getActivityStr);
            
            ResultSet rs = listActPs.executeQuery();
            while (rs.next()) {
            	int theId = rs.getInt("log_id");
                int theUser = rs.getInt("user_id");
                String theType = rs.getString("activity_type");
                LocalDate theTime = rs.getDate("activity_time").toLocalDate();
                String theDetail = rs.getString("activity_detail");
                
                Activity theLog = new Activity(theId, theUser, theType, theTime, theDetail);
        		logs.add(theLog);
            }
    	} catch (SQLException e) {
			e.printStackTrace();
		}
    	return logs;
    }
}
