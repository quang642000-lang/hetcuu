package repository;

import model.entity.Topping;
import java.util.List;

public interface IToppingRepository extends IBaseRepository<Topping, String> {
    List<Topping> getByTrangThai(boolean status);
    boolean updateTrangThai(String maTp, boolean status);
}
