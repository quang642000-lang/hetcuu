package service;

import model.entity.SanPham;
import model.entity.SanPhamKichCo;
import java.util.List;

public interface ISanPhamService {

    List<SanPham> getAllSanPham();

    SanPham getSanPhamById(String id);

    /**
     * Lấy danh sách sản phẩm theo mã danh mục.
     * @param maDm Mã danh mục
     * @return Danh sách sản phẩm thuộc danh mục
     */
    List<SanPham> getSanPhamByDanhMuc(int maDm);

    /**
     * Lấy danh sách sản phẩm nổi bật (Bestsellers) để hiển thị trên Website Portal.
     * @return Danh sách sản phẩm Bestseller
     */
    List<SanPham> getBestsellers();

    /**
     * Lấy danh sách sản phẩm mới (New Arrivals) để hiển thị trên Website Portal.
     * @return Danh sách sản phẩm mới
     */
    List<SanPham> getNewArrivals();

    /**
     * Tìm kiếm sản phẩm theo tên hoặc mã sản phẩm.
     * @param keyword Từ khóa tìm kiếm
     * @return Danh sách sản phẩm khớp với từ khóa
     */
    List<SanPham> searchSanPham(String keyword);

    /**
     * Thêm mới sản phẩm đi kèm với danh sách các kích cỡ (Size S, M, L) và đơn giá của chúng.
     * Nghiệp vụ: Phải thực thi đồng thời trong một Transaction để đảm bảo tính toàn vẹn.
     * Quy tắc: Một sản phẩm khi tạo mới bắt buộc phải có ít nhất một cấu hình kích cỡ và giá bán đi kèm.
     * @param sanPham Đối tượng sản phẩm mẹ
     * @param sizes Danh sách các thực thể cấu hình kích cỡ, định lượng và giá bán tương ứng
     * @return true nếu lưu thành công toàn bộ, false nếu xảy ra bất kỳ lỗi nào
     */
    boolean createSanPham(SanPham sanPham, List<SanPhamKichCo> sizes);

    /**
     * Cập nhật thông tin sản phẩm và các biến thể kích cỡ đi kèm.
     * Nghiệp vụ: Xóa toàn bộ cấu hình kích cỡ cũ của sản phẩm này và nạp lại danh sách kích cỡ mới cập nhật trong Transaction.
     * @param sanPham Đối tượng sản phẩm mẹ cần cập nhật
     * @param sizes Danh sách cấu hình kích cỡ mới
     * @return true nếu cập nhật thành công, false nếu thất bại
     */
    boolean updateSanPham(SanPham sanPham, List<SanPhamKichCo> sizes);

    /**
     * Xóa sản phẩm khỏi hệ thống.
     * Quy tắc nghiệp vụ: Áp dụng Soft Delete (Xóa mềm - Chuyển trang_thai = false) để tránh gây lỗi khóa ngoại với các hóa đơn cũ trong quá khứ.
     * @param id Mã sản phẩm cần xóa
     * @return true nếu xóa mềm thành công
     */
    boolean deleteSanPham(String id);

    /**
     * Lấy toàn bộ các biến thể kích cỡ kèm giá bán của một sản phẩm mẹ.
     * @param maSp Mã sản phẩm mẹ
     * @return Danh sách các cấu hình biến thể giá
     */
    List<SanPhamKichCo> getSizesBySanPham(String maSp);
}