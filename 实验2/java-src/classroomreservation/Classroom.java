package classroomreservation;

public class Classroom {
    private String classroomId;
    private String classroomName;
    private String location;
    private int capacity;
    private String classroomStatus;
    private ClassroomTimeSlot[] timeSlots;

    public boolean isReservable() {
        return false;
    }

    public void enable() {
    }

    public void disable() {
    }

    public void addTimeSlot(ClassroomTimeSlot timeSlot) {
    }
}
