package classroomreservation;

public abstract class User {
    private String userId;
    private String account;
    private String userName;
    private String password;
    private String contactInfo;
    private String userStatus;

    public boolean login(String account, String password) {
        return false;
    }

    public void changePassword(String newPassword) {
    }

    public void enable() {
    }

    public void disable() {
    }
}
