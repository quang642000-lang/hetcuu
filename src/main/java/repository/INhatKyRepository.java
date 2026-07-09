package repository;

import model.entity.NhatKyHoatDong;
import java.util.List;

public interface INhatKyRepository {
    boolean addLog(NhatKyHoatDong log);
    List<NhatKyHoatDong> getAllLogs();
    List<NhatKyHoatDong> getLogsByNhanVien(String maNv);
}
