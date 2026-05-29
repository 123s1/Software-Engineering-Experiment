package classroomreservation;

public class TeacherStudentUser extends User {
    private String identityType;
    private Reservation[] reservations;

    public Classroom[] searchAvailableClassrooms(ReservationService service) {
        return null;
    }

    public Reservation reserveClassroom(ReservationService service, Classroom classroom, ClassroomTimeSlot timeSlot, String purpose) {
        return null;
    }

    public void addReservation(Reservation reservation) {
    }
}
