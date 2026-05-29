package classroomreservation;

public class ClassroomTimeSlot {
    private String slotId;
    private String useDate;
    private int startSection;
    private int endSection;
    private String slotStatus;
    private Classroom classroom;

    public boolean isAvailable() {
        return false;
    }

    public void markReserved() {
    }

    public void release() {
    }

    public void setClassroom(Classroom classroom) {
    }
}
