package service.impl;

import model.entity.Topping;
import repository.IToppingRepository;
import repository.impl.ToppingRepoImpl;
import service.IToppingService;
import java.util.List;

public class ToppingServiceImpl implements IToppingService {
    private static ToppingServiceImpl instance;
    private final IToppingRepository toppingRepository;

    private ToppingServiceImpl() {
        this.toppingRepository = ToppingRepoImpl.getInstance();
    }

    public static synchronized ToppingServiceImpl getInstance() {
        if (instance == null) {
            instance = new ToppingServiceImpl();
        }
        return instance;
    }

    @Override
    public List<Topping> getAllTopping() {
        return toppingRepository.getAll();
    }

    @Override
    public List<Topping> getActiveTopping() {
        return toppingRepository.getByTrangThai(true);
    }

    @Override
    public Topping getToppingById(int id) {
        return toppingRepository.getById(id);
    }

    @Override
    public boolean createTopping(Topping topping) {
        return toppingRepository.add(topping);
    }

    @Override
    public boolean updateTopping(Topping topping) {
        return toppingRepository.update(topping);
    }

    @Override
    public boolean deleteTopping(int id) {
        return toppingRepository.delete(id);
    }

    @Override
    public boolean updateTrangThaiTopping(int maTp, boolean status) {
        return toppingRepository.updateTrangThai(maTp, status);
    }
}
