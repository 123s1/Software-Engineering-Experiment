package classroomreservation;

public class ClassroomManagementRecord {
    public String recordId;
    public Administrator operator;
    public Classroom targetClassroom;
    public String operationType; // "ADD", "DELETE", "SET_TIMESLOT"
    public String operationTime;
    public String remarks;
}
