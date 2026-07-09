package repository;

import model.entity.NhanVien;

public interface INhanVienRepository extends IBaseRepository<NhanVien, String> {
    NhanVien getByTenDangNhap(String username);
    NhanVien getByEmail(String email);
    boolean updateMatKhau(String maNv, String matKhauMoi);
    boolean checkTrungSdtOrEmail(String sdt, String email, String excludeMaNv);
}
