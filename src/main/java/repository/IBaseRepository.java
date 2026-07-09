package repository;

import java.util.List;

public interface IBaseRepository<T, K> {
    List<T> getAll();
    T getById(K id);
    boolean add(T entity);
    boolean update(T entity);
    boolean delete(K id);
}