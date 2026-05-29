package classroomreservation;

public class UserManagementRecord {
    public String recordId;
    public Administrator operator;
    public User targetUser;
    public String operationType; // "ENABLE", "DISABLE"
    public String operationTime;
    public String remarks;
}
