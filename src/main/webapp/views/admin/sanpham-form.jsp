<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - ${not empty product ? "Cập Nhật" : "Thêm"} Sản Phẩm Đồ Uống</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        .form-card {
            border-radius: 16px;
            background: #ffffff;
            border: none;
        }
        .size-box {
            background-color: #f8fafc;
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px;
        }
        .preview-img-box {
            width: 100%;
            height: 250px;
            border: 2px dashed var(--border-color);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            background-color: #f8fafc;
        }
        .preview-img-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
    </style>
</head>
<body class="bg-light">
<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4">
            <!-- NÚT QUAY LẠI -->
            <div class="mb-3">
                <a href="${pageContext.request.contextPath}/admin/sanpham" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-1.5 fw-bold" style="border-radius: 6px;">
                    <i class="bi bi-arrow-left"></i> Quay lại danh sách
                </a>
            </div>

            <div class="card form-card p-4 shadow-sm">
                <!-- TIÊU ĐỀ BIỂU MẪU -->
                <h4 class="fw-bold mb-4 text-success border-bottom pb-3">
                    <i class="bi bi-gear-wide-connected me-2 text-success"></i>
                    ${formTitle}
                </h4>

                <form id="productForm" action="${pageContext.request.contextPath}/admin/sanpham" method="POST">
                    <!-- Các trường giá trị ẩn để xác định luồng -->
                    <input type="hidden" name="action" value="${not empty product ? 'edit' : 'create'}">
                    <c:if test="${not empty product}">
                        <input type="hidden" name="maSp" value="${product.maSp}">
                    </c:if>

                    <div class="row g-4">
                        <!-- PHẦN THÔNG TIN CHUNG BÊN TRÁI -->
                        <div class="col-12 col-md-8">
                            <div class="bg-light p-3.5 rounded mb-4" style="border: 1px solid var(--border-color);">
                                <h6 class="fw-bold text-dark mb-3"><i class="bi bi-info-circle-fill text-success"></i> 1. Thông Tin Đồ Uống Cơ Bản</h6>

                                <div class="row g-3">
                                    <!-- Mã sản phẩm (Tự sinh) -->
                                    <div class="col-12 col-md-4">
                                        <label class="form-label fw-bold small text-muted">Mã Đồ Uống</label>
                                        <input type="text" class="form-control form-control-teapos bg-white"
                                               value="${not empty product ? product.maSp : 'SPxxxx (Tự động sinh)'}" readonly style="font-weight: 700; color: #1e293b;">
                                    </div>
                                    <!-- Tên sản phẩm -->
                                    <div class="col-12 col-md-8">
                                        <label for="tenSp" class="form-label fw-bold small text-dark">Tên Đồ Uống <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control form-control-teapos" id="tenSp" name="tenSp"
                                               value="<c:out value="${product.tenSp}"/>" placeholder="Ví dụ: Trà Sữa Khoai Môn Trân Châu..." required autocomplete="off">
                                    </div>
                                    <!-- Danh mục -->
                                    <div class="col-12 col-md-6">
                                        <label for="maDm" class="form-label fw-bold small text-dark">Nhóm Danh Mục <span class="text-danger">*</span></label>
                                        <select class="form-select form-control-teapos" id="maDm" name="maDm" required>
                                            <option value="">-- Chọn danh mục --</option>
                                            <c:forEach var="cat" items="${categories}">
                                                <option value="${cat.maDm}" ${product.maDm == cat.maDm ? 'selected' : ''}>
                                                    <c:out value="${cat.tenDm}"/>
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <!-- Đường dẫn ảnh -->
                                    <div class="col-12 col-md-6">
                                        <label for="hinhAnh" class="form-label fw-bold small text-dark">Đường dẫn Hình ảnh (URL)</label>
                                        <input type="text" class="form-control form-control-teapos" id="hinhAnh" name="hinhAnh"
                                               value="<c:out value="${product.hinhAnh}"/>" placeholder="https://image-url..." onchange="previewImage(this.value)">
                                    </div>
                                    <!-- Mô tả -->
                                    <div class="col-12">
                                        <label for="moTa" class="form-label fw-bold small text-dark">Mô tả chi tiết đồ uống</label>
                                        <textarea class="form-control" id="moTa" name="moTa" rows="3"
                                                  placeholder="Mô tả hương vị, nguyên liệu pha chế, đặc sắc của cốc trà sữa..."><c:out value="${product.moTa}"/></textarea>
                                    </div>
                                </div>
                            </div>

                            <!-- THIẾT LẬP ĐẶC TÍNH SẢN PHẨM -->
                            <div class="bg-light p-3.5 rounded mb-4" style="border: 1px solid var(--border-color);">
                                <h6 class="fw-bold text-dark mb-3"><i class="bi bi-gear-fill text-success"></i> 2. Thiết Lập Đặc Tính & Tùy Chọn Pha Chế</h6>

                                <div class="row g-3 text-start">
                                    <div class="col-6 col-md-3">
                                        <div class="form-check form-switch p-2 rounded bg-white border ps-5">
                                            <input class="form-check-input" type="checkbox" id="choPhepDoiDa" name="choPhepDoiDa" value="1"
                                            ${empty product || product.choPhepDoiDa ? 'checked' : ''}>
                                            <label class="form-check-label fw-semibold text-dark small" for="choPhepDoiDa">Đổi Đá (Ice)</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="form-check form-switch p-2 rounded bg-white border ps-5">
                                            <input class="form-check-input" type="checkbox" id="choPhepDoiDuong" name="choPhepDoiDuong" value="1"
                                            ${empty product || product.choPhepDoiDuong ? 'checked' : ''}>
                                            <label class="form-check-label fw-semibold text-dark small" for="choPhepDoiDuong">Đổi Đường (Sugar)</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="form-check form-switch p-2 rounded bg-white border ps-5">
                                            <input class="form-check-input" type="checkbox" id="isNew" name="isNew" value="1"
                                            ${product.isNew ? 'checked' : ''}>
                                            <label class="form-check-label fw-semibold text-warning small" for="isNew">✨ Nhãn Mới (New)</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="form-check form-switch p-2 rounded bg-white border ps-5">
                                            <input class="form-check-input" type="checkbox" id="isBestseller" name="isBestseller" value="1"
                                            ${product.isBestseller ? 'checked' : ''}>
                                            <label class="form-check-label fw-semibold text-danger small" for="isBestseller">🔥 Bán Chạy (Hot)</label>
                                        </div>
                                    </div>
                                    <div class="col-12 border-top pt-3 mt-3">
                                        <label class="form-label fw-bold small text-dark d-block">Trạng thái bán</label>
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" name="trangThai" id="statusActive" value="1"
                                            ${empty product || product.trangThai ? 'checked' : ''}>
                                            <label class="form-check-label text-success fw-bold" for="statusActive">Đang hoạt động (Mở bán)</label>
                                        </div>
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" name="trangThai" id="statusInactive" value="0"
                                            ${not empty product && not product.trangThai ? 'checked' : ''}>
                                            <label class="form-check-label text-danger" for="statusInactive">Ngừng hoạt động (Tạm dừng bán)</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- PHẦN XEM TRƯỚC HÌNH ẢNH BÊN PHẢI -->
                        <div class="col-12 col-md-4">
                            <div class="bg-light p-3.5 rounded h-100" style="border: 1px solid var(--border-color);">
                                <h6 class="fw-bold text-dark mb-3"><i class="bi bi-image text-success"></i> Xem Trước Hình Ảnh</h6>
                                <div class="preview-img-box mb-3 border shadow-sm">
                                    <img id="imgPreview" src="${not empty product.hinhAnh ? product.hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" alt="Preview">
                                </div>
                                <p class="small text-muted text-center" style="line-height: 1.4;">Đo lường tỉ lệ hiển thị tối ưu là 500x500px tỉ lệ vuông (1:1) để đồ uống hiển thị sắc nét nhất trên cả POS và Website.</p>
                            </div>
                        </div>

                        <!-- PHẦN QUẢN LÝ KÍCH CỠ & GIÁ BÁN (DƯỚI TRẢI NGANG) -->
                        <div class="col-12">
                            <div class="size-box shadow-sm">
                                <h5 class="fw-bold text-dark border-bottom pb-2.5 mb-3 d-flex align-items-center gap-2">
                                    <i class="bi bi-tags-fill text-success"></i>
                                    <span>3. Cấu hình Kích cỡ (Size) và Giá bán chốt của cốc nước</span>
                                </h5>

                                <!-- CÔNG CỤ THÊM NHANH TÊN KÍCH CỠ ĐỘNG BẰNG AJAX -->
                                <div class="row g-2 mb-4 p-3 bg-white rounded border">
                                    <div class="col-12">
                                        <small class="fw-bold text-success d-block mb-1"><i class="bi bi-plus-circle"></i> THÊM TÊN KÍCH CỠ MỚI VÀO HỆ THỐNG (VÍ DỤ: XL, GIANT, KHỔNG LỒ...)</small>
                                    </div>
                                    <div class="col-12 col-md-8">
                                        <input type="text" id="newSizeNameInput" class="form-control form-control-teapos" placeholder="Nhập tên kích cỡ mới muốn thêm (Sẽ tự động viết hoa)...">
                                    </div>
                                    <div class="col-12 col-md-4">
                                        <button type="button" class="btn btn-success w-100 fw-bold py-2" onclick="addNewSizeAjax()"><i class="bi bi-plus-circle"></i> THÊM TÊN SIZE MỚI</button>
                                    </div>
                                </div>

                                <p class="small text-muted">Vui lòng tích chọn kích cỡ khả dụng để thiết lập giá bán và định lượng cho cốc nước. (Hệ thống yêu cầu ít nhất một kích cỡ hoạt động để mở bán món uống thành công).</p>

                                <div class="table-responsive">
                                    <table class="table table-hover align-middle bg-white rounded border overflow-hidden" id="sizesConfigTable">
                                        <thead class="table-success">
                                        <tr class="text-center">
                                            <th style="width: 100px;">Kích Hoạt</th>
                                            <th style="width: 150px;">Kích Cỡ</th>
                                            <th>Đơn Giá Bán Thực Tế (VNĐ) <span class="text-danger">*</span></th>
                                            <th>Định lượng cốc (Thể tích)</th>
                                        </tr>
                                        </thead>
                                        <tbody id="sizesConfigTableBody">
                                        <c:forEach var="sz" items="${sizes}">
                                            <!-- Đối soát khớp xem kích cỡ này đã được cấu hình trước đó chưa (Chế độ Edit) -->
                                            <c:set var="isConfigured" value="false"/>
                                            <c:set var="savedPrice" value=""/>
                                            <c:set var="savedVolume" value=""/>
                                            <c:forEach var="cp" items="${currentPrices}">
                                                <c:if test="${cp.maSize == sz.maSize}">
                                                    <c:set var="isConfigured" value="true"/>
                                                    <c:set var="savedPrice" value="${cp.giaBan}"/>
                                                    <c:set var="savedVolume" value="${cp.dinhLuong}"/>
                                                </c:if>
                                            </c:forEach>

                                            <tr class="text-center" id="row_size_${sz.maSize}">
                                                <td>
                                                    <input type="checkbox" name="size_active_${sz.maSize}" id="size_active_${sz.maSize}"
                                                           class="form-check-input size-check border-success" value="1"
                                                        ${isConfigured ? 'checked' : ''} onchange="toggleSizeFields(${sz.maSize})">
                                                </td>
                                                <td>
                                                    <label class="form-check-label fw-bold text-dark" for="size_active_${sz.maSize}">
                                                        <!-- ĐỒNG BỘ ĐỘNG: Đọc trực tiếp sz.tenSize cực xịn -->
                                                        Size <span class="lbl-ten-size">${sz.tenSize}</span>
                                                    </label>
                                                </td>
                                                <td>
                                                    <div class="input-group input-group-sm mx-auto" style="max-width: 250px;">
                                                        <input type="number" name="size_price_${sz.maSize}" id="size_price_${sz.maSize}"
                                                               class="form-control text-end fw-bold text-success size-price-input"
                                                               value="${savedPrice}" ${isConfigured ? "" : "disabled"} required min="1000" step="1000" placeholder="Nhập giá VNĐ...">
                                                        <span class="input-group-text bg-light text-muted">đ</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <input type="text" name="size_volume_${sz.maSize}" id="size_volume_${sz.maSize}"
                                                           class="form-control form-control-sm mx-auto size-volume-input" style="max-width: 200px;"
                                                           value="<c:out value="${savedVolume}"/>" ${isConfigured ? "" : "disabled"} placeholder="Ví dụ: 350ml, 500ml...">
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <!-- CÁC NÚT ĐIỀU HÀNH CHỐT BIỂU MẪU -->
                        <div class="col-12 d-flex justify-content-end gap-2 border-top pt-4">
                            <a href="${pageContext.request.contextPath}/admin/sanpham" class="btn btn-secondary-teapos px-4 py-2.5 fw-bold">HUỶ BỎ</a>
                            <button type="submit" class="btn-teapos btn-primary-teapos px-5 py-2.5 fw-bold shadow-sm">
                                <i class="bi bi-cloud-download-fill me-1"></i> LƯU SẢN PHẨM
                            </button>
                        </div>

                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    // 1. Tự động bật tắt các ô nhập liệu Giá & Định lượng tương ứng khi bật/tắt checkbox Size
    function toggleSizeFields(maSize) {
        const check = document.getElementById("size_active_" + maSize);
        const priceInput = document.getElementById("size_price_" + maSize);
        const volumeInput = document.getElementById("size_volume_" + maSize);

        if (check.checked) {
            priceInput.disabled = false;
            volumeInput.disabled = false;
            priceInput.focus();
        } else {
            priceInput.disabled = true;
            volumeInput.disabled = true;
            priceInput.value = "";
            volumeInput.value = "";
        }
    }

    // 2. AJAX thêm nhanh kích cỡ mới vào bảng KICH_CO và render trực quan ngay tắp lự
    function addNewSizeAjax() {
        const tenSize = document.getElementById('newSizeNameInput').value.trim();
        if (!tenSize) {
            showToast('warning', 'Vui lòng điền tên kích cỡ mới (Ví dụ: XL)!');
            return;
        }

        Swal.fire({
            title: 'Đang lưu kích cỡ...',
            allowOutsideClick: false,
            didOpen: () => { Swal.showLoading(); }
        });

        // Ghép tự động đường dẫn Ajax chuẩn
        const url = '${pageContext.request.contextPath}/admin/sanpham';
        const params = new URLSearchParams();
        params.append('action', 'addSizeAjax');
        params.append('tenSize', tenSize);

        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
            .then(res => res.json())
            .then(data => {
                Swal.close();
                if (data.status === 'SUCCESS') {
                    const maSize = data.maSize;
                    const normalizedTenSize = data.tenSize;

                    // Kiểm tra xem hàng kích cỡ này đã tồn tại trong bảng form chưa
                    if (document.getElementById('row_size_' + maSize)) {
                        showToast('info', 'Mốc kích cỡ này đã tồn tại trong danh sách chọn bên dưới!');
                        document.getElementById('newSizeNameInput').value = '';
                        return;
                    }

                    // Chèn thêm một Row mới tinh, check sẵn vào bảng cấu hình giá
                    const tbody = document.getElementById('sizesConfigTableBody');
                    const newRow = document.createElement('tr');
                    newRow.className = 'text-center';
                    newRow.id = 'row_size_' + maSize;

                    newRow.innerHTML = `
                    <td>
                        <input type="checkbox" name="size_active_\${maSize}" id="size_active_\address\${maSize}"
                               class="form-check-input size-check border-success" value="1" checked onchange="toggleSizeFields(\${maSize})">
                    </td>
                    <td>
                        <label class="form-check-label fw-bold text-dark" for="size_active_\${maSize}">
                            Size <span class="lbl-ten-size">\${normalizedTenSize}</span>
                        </label>
                    </td>
                    <td>
                        <div class="input-group input-group-sm mx-auto" style="max-width: 250px;">
                            <input type="number" name="size_price_\${maSize}" id="size_price_\${maSize}"
                                   class="form-control text-end fw-bold text-success size-price-input"
                                   required min="1000" step="1000" placeholder="Nhập giá VNĐ...">
                            <span class="input-group-text bg-light text-muted">đ</span>
                        </div>
                    </td>
                    <td>
                        <input type="text" name="size_volume_\${maSize}" id="size_volume_\${maSize}"
                               class="form-control form-control-sm mx-auto size-volume-input" style="max-width: 200px;"
                               placeholder="Ví dụ: 350ml, 500ml...">
                    </td>
                `;

                    tbody.appendChild(newRow);
                    showToast('success', 'Đã khởi tạo mốc kích cỡ ' + normalizedTenSize + ' thành công! Thao tác nhập giá ngay!');
                    document.getElementById('newSizeNameInput').value = '';

                    // Trượt focus tới input giá vừa sinh
                    document.getElementById('size_price_' + maSize).focus();
                } else {
                    Swal.fire({ icon: 'error', title: 'Thao tác lỗi', text: data.message });
                }
            })
            .catch(err => {
                Swal.close();
                console.error('Lỗi kết nối AJAX:', err);
                showToast('error', 'Lỗi kết nối máy chủ!');
            });
    }

    // 3. Tự động xem trước ảnh khi nạp liên kết URL hình ảnh
    function previewImage(url) {
        const preview = document.getElementById("imgPreview");
        if (url && url.trim() !== "") {
            preview.src = url.trim();
        } else {
            preview.src = "https://cdn-icons-png.flaticon.com/512/3177/3177440.png";
        }
    }

    // 4. Thực hiện kiểm định ràng buộc Client-Side trước khi cho nộp dữ liệu lên Server
    document.getElementById("productForm").addEventListener("submit", function(e) {
        const activeChecks = document.querySelectorAll(".size-check:checked");
        if (activeChecks.length === 0) {
            e.preventDefault();
            Swal.fire({
                icon: 'warning',
                title: 'Khuyết thiếu kích cỡ',
                text: 'Hệ thống yêu cầu sản phẩm mới bắt buộc phải bật cấu hình tối thiểu một kích cỡ và giá bán!',
                confirmButtonColor: '#2e7d32'
            });
            return;
        }

        // Ràng buộc giá trị tiền bán lớn hơn 0
        let invalidPrice = false;
        activeChecks.forEach(chk => {
            // bóc tách lấy maSize
            const sizeId = chk.id.replace("size_active_", "");
            const priceEl = document.getElementById("size_price_" + sizeId);
            if (priceEl) {
                const priceVal = parseInt(priceEl.value);
                if (isNaN(priceVal) || priceVal < 1000) {
                    invalidPrice = true;
                }
            }
        });

        if (invalidPrice) {
            e.preventDefault();
            Swal.fire({
                icon: 'warning',
                title: 'Giá bán không hợp lệ',
                text: 'Giá bán của sản phẩm tại các kích cỡ bật bán bắt buộc phải lớn hơn hoặc bằng 1.000đ!',
                confirmButtonColor: '#2e7d32'
            });
        }
    });

    document.addEventListener("DOMContentLoaded", function() {
        <c:if test="${not empty error}">
        Swal.fire({
            icon: 'error',
            title: 'Thao tác lỗi',
            text: '${error}',
            confirmButtonColor: '#2e7d32'
        });
        </c:if>
    });
</script>
</body>
</html>