package service;

import model.entity.Topping;
import java.util.List;

public interface IToppingService {
    List<Topping> getAllTopping();
    List<Topping> getActiveTopping();
    Topping getToppingById(String id); // Changed to String
    boolean createTopping(Topping topping);
    boolean updateTopping(Topping topping);
    boolean deleteTopping(String id); // Changed to String
    boolean updateTrangThaiTopping(String maTp, boolean status); // Changed to String
}
