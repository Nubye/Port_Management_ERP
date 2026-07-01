package operations;

import java.util.ArrayList;
import model.SecurityLog;

public interface SecurityLog_Operation {
    void openSession(SecurityLog securityLog);
    void closeSession(SecurityLog securityLog);
    ArrayList<SecurityLog> getSecurityLogs(String username, String role, String fromDate, String toDate);
}