package repository;

import model.entity.Topping;
import java.util.List;

public interface IToppingRepository extends IBaseRepository<Topping, Integer> {
    List<Topping> getByTrangThai(boolean status);
    boolean updateTrangThai(int maTp, boolean status);
}
