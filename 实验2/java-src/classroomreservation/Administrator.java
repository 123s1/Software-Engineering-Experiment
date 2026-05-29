package classroomreservation;

public class Administrator extends User {
    public UserManagementRecord addUser(UserManagementService service, TeacherStudentUser user) {
        return null;
    }

    public UserManagementRecord disableUser(UserManagementService service, TeacherStudentUser user) {
        return null;
    }

    public ClassroomManagementRecord addClassroom(ClassroomManagementService service, Classroom classroom) {
        return null;
    }

    public ClassroomManagementRecord deleteClassroom(ClassroomManagementService service, Classroom classroom) {
        return null;
    }

    public ClassroomManagementRecord setAvailableTimeSlot(ClassroomManagementService service, Classroom classroom, ClassroomTimeSlot timeSlot) {
        return null;
    }

    public Reservation[] viewReservations(ReservationService service) {
        return null;
    }
}
