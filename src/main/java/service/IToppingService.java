package service;

import model.entity.Topping;
import java.util.List;

public interface IToppingService {

    List<Topping> getAllTopping();

    List<Topping> getActiveTopping();

    Topping getToppingById(int id);

    boolean createTopping(Topping topping);

    boolean updateTopping(Topping topping);

    /**
     * Xóa Topping khỏi hệ thống.
     * Nghiệp vụ: Áp dụng xóa mềm chuyển trạng thái bằng 0 để bảo toàn lịch sử chốt đơn hóa đơn.
     * @param id Mã Topping cần xóa
     * @return true nếu thực thi thành công
     */
    boolean deleteTopping(int id);

    /**
     * Cập nhật trạng thái hoạt động của Topping nhanh (Ví dụ: Hết trân châu trắng -> Bấm tắt trạng thái ngay lập tức).
     * @param maTp Mã Topping
     * @param status Trạng thái mới (true: Hoạt động, false: Ngừng bán)
     * @return true nếu cập nhật thành công
     */
    boolean updateTrangThaiTopping(int maTp, boolean status);
}