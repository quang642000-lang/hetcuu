package service;

import model.entity.DanhMuc;
import java.util.List;

public interface IDanhMucService {

    /**
     * Lấy toàn bộ danh sách danh mục (kể cả danh mục đang tạm đóng).
     * @return Danh sách đối tượng DanhMuc
     */
    List<DanhMuc> getAllDanhMuc();

    /**
     * Lấy danh sách danh mục đang hoạt động (trang_thai = true) để hiển thị lên Menu bán hàng.
     * @return Danh sách đối tượng DanhMuc hoạt động
     */
    List<DanhMuc> getActiveDanhMuc();

    /**
     * Lấy chi tiết danh mục theo mã danh mục.
     * @param id Mã danh mục cần tìm
     * @return Đối tượng DanhMuc hoặc null nếu không tồn tại
     */
    DanhMuc getDanhMucById(int id);

    /**
     * Thêm mới danh mục đồ uống.
     * Quy tắc nghiệp vụ: Tên danh mục không được phép trùng lặp trong hệ thống.
     * @param danhMuc Đối tượng danh mục chứa thông tin thêm mới
     * @return true nếu thêm thành công, false nếu thất bại hoặc trùng tên
     */
    boolean createDanhMuc(DanhMuc danhMuc);

    /**
     * Cập nhật thông tin danh mục.
     * Quy tắc nghiệp vụ: Tên danh mục cập nhật không được trùng với các danh mục khác.
     * @param danhMuc Đối tượng danh mục chứa thông tin cập nhật
     * @return true nếu cập nhật thành công, false nếu thất bại hoặc trùng tên
     */
    boolean updateDanhMuc(DanhMuc danhMuc);

    /**
     * Xóa danh mục khỏi hệ thống.
     * Quy tắc nghiệp vụ: Chỉ cho phép xóa nếu danh mục này chưa phát sinh liên kết với bất kỳ sản phẩm nào.
     * @param id Mã danh mục cần xóa
     * @return true nếu xóa thành công, false nếu thất bại hoặc vi phạm ràng buộc
     */
    boolean deleteDanhMuc(int id);

    /**
     * Kiểm tra tên danh mục có bị trùng lặp hay không.
     * @param tenDm Tên danh mục cần kiểm tra
     * @param excludeId Mã danh mục cần bỏ qua (dùng khi cập nhật), truyền null nếu là thêm mới
     * @return true nếu tên bị trùng, false nếu tên hợp lệ
     */
    boolean isTenDanhMucDuplicate(String tenDm, Integer excludeId);
}