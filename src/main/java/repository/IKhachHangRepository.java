package repository;

import model.entity.KhachHang;

public interface IKhachHangRepository extends IBaseRepository<KhachHang, String> {
    KhachHang getBySdt(String sdt);
    KhachHang getByEmail(String email);
    boolean congDiemTichLuy(String maKh, int diemCong);
    boolean truDiemTichLuy(String maKh, int diemTru);
    boolean checkTrungSdtOrEmail(String sdt, String email, String excludeMaKh);
    boolean updateMatKhau(String maKh, String matKhauMoi);
}
