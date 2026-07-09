package repository;

import model.entity.KichCo;

public interface IKichCoRepository extends IBaseRepository<KichCo, Integer> {
    KichCo getByTenSize(String tenSize);
}
