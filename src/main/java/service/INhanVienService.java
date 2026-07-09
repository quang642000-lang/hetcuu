package service;

import model.entity.NhanVien;
import java.util.List;

public interface INhanVienService {

    List<NhanVien> getAllNhanVien();

    NhanVien getNhanVienById(String id);

    /**
     * Đăng nhập hệ thống phân hệ nhân viên (Admin hoặc Nhân viên thu ngân POS) [14].
     * Cơ chế bảo mật nâng cao chống tấn công Brute-force:
     * - Sử dụng bộ nhớ đệm an toàn `ConcurrentHashMap` lưu vết số lần nhập sai theo từng Username trong RAM.
     * - Nếu người dùng nhập sai mật khẩu liên tiếp quá 5 lần, hệ thống tự động khóa tài khoản tạm thời trong vòng đúng 5 phút [1].
     * - Mọi lượt đăng nhập thành công hay thất bại đều được lưu trữ vết bảo mật trong nhật ký hệ thống.
     * @param username Tên đăng nhập của nhân viên
     * @param password Mật khẩu gốc (sẽ được băm SHA-256 để đối chiếu)
     * @param ipAddress Địa chỉ IP của thiết bị thực hiện thao tác đăng nhập [15]
     * @return Đối tượng NhanVien nếu đăng nhập thành công và không bị khóa quyền
     */
    NhanVien loginNhanVien(String username, String password, String ipAddress);

    boolean createNhanVien(NhanVien nhanVien);

    boolean updateNhanVien(NhanVien nhanVien);

    /**
     * Ngừng hoạt động nhân viên (Áp dụng xóa mềm chuyển trạng thái về ngừng hoạt động).
     */
    boolean deleteNhanVien(String id);

    /**
     * Đổi mật khẩu chủ động cho nhân viên.
     */
    boolean changePassword(String maNv, String oldPassword, String newPassword);

    /**
     * Đặt lại mật khẩu mặc định cho nhân viên (Chức năng dành cho Admin) [16].
     * Mật khẩu mới được băm SHA-256 tự động.
     * @param maNv Mã nhân viên cần đặt lại mật khẩu
     * @param newPassword Mật khẩu mới được chỉ định
     * @return true nếu cập nhật thành công
     */
    boolean resetPasswordByAdmin(String maNv, String newPassword);

    /**
     * Kiểm tra xem tài khoản nhân viên hiện tại có đang bị khóa tạm thời do nhập sai quá 5 lần hay không.
     * @param username Tên đăng nhập cần kiểm tra
     * @return true nếu tài khoản đang trong trạng thái khóa 5 phút
     */
    boolean isAccountLocked(String username);

    /**
     * Lấy thời gian còn lại (tính bằng giây) trước khi tài khoản nhân viên được tự động mở khóa.
     * @param username Tên đăng nhập
     * @return Số giây còn lại để mở khóa, trả về 0 nếu tài khoản không bị khóa
     */
    long getRemainingLockTime(String username);
}