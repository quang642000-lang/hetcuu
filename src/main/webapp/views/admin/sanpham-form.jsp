<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <c:set var="maSp" value="SPxxxx (Tự động sinh)" />
    <c:set var="tenSp" value="" />
    <c:set var="maDm" value="" />
    <c:set var="hinhAnh" value="" />
    <c:set var="moTa" value="" />
    <c:set var="choPhepDoiDa" value="true" />
    <c:set var="choPhepDoiDuong" value="true" />
    <c:set var="isNew" value="false" />
    <c:set var="isBestseller" value="false" />
    <c:set var="trangThai" value="true" />

    <c:if test="${not empty product}">
        <c:set var="maSp" value="${product.maSp}" />
        <c:set var="tenSp" value="${product.tenSp}" />
        <c:set var="maDm" value="${product.maDm}" />
        <c:set var="hinhAnh" value="${product.hinhAnh}" />
        <c:set var="moTa" value="${product.moTa}" />
        <c:set var="choPhepDoiDa" value="${product.choPhepDoiDa}" />
        <c:set var="choPhepDoiDuong" value="${product.choPhepDoiDuong}" />
        <c:set var="isNew" value="${product.getIsNew()}" />
        <c:set var="isBestseller" value="${product.getIsBestseller()}" />
        <c:set var="trangThai" value="${product.trangThai}" />
    </c:if>

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
                    <c:out value="${formTitle}" />
                </h4>

                <form id="productForm" action="${pageContext.request.contextPath}/admin/sanpham" method="POST" enctype="multipart/form-data">
                    <!-- Các trường giá trị ẩn để xác định luồng -->
                    <input type="hidden" name="action" id="formAction" value="${not empty product ? 'edit' : 'create'}">
                    <input type="hidden" name="maSp" id="formMaSp" value="${not empty product ? maSp : ''}">

                    <div class="row g-4">
                        <!-- PHẦN THÔNG TIN CHUNG BÊN TRÁI -->
                        <div class="col-12 col-md-8">
                            <div class="bg-light p-3.5 rounded mb-4" style="border: 1px solid var(--border-color);">
                                <h6 class="fw-bold text-dark mb-3"><i class="bi bi-info-circle-fill text-success"></i> 1. Thông Tin Đồ Uống Cơ Bản</h6>

                                <div class="row g-3">
                                    <!-- Mã sản phẩm (Tự sinh hoặc tải từ biến an toàn) -->
                                    <div class="col-12 col-md-4">
                                        <label class="form-label fw-bold small text-muted">Mã Đồ Uống</label>
                                        <input type="text" class="form-control form-control-teapos bg-white"
                                               value="${maSp}" readonly style="font-weight: 700; color: #1e293b;">
                                    </div>
                                    <!-- Tên sản phẩm -->
                                    <div class="col-12 col-md-8">
                                        <label for="tenSp" class="form-label fw-bold small text-dark">Tên Đồ Uống <span class="text-danger">*</span></label>
                                        <!-- SỬA LỖI TRÁNH QUOTE SYMBOL EXPECTED: Sử dụng ${tenSp} thay cho <c:out> lồng attribute -->
                                        <input type="text" class="form-control form-control-teapos" id="tenSp" name="tenSp"
                                               value="${tenSp}" placeholder="Ví dụ: Trà Sữa Khoai Môn Trân Châu..." required autocomplete="off">
                                    </div>
                                    <!-- Danh mục -->
                                    <div class="col-12 col-md-6">
                                        <label for="maDm" class="form-label fw-bold small text-dark">Nhóm Danh Mục <span class="text-danger">*</span></label>
                                        <select class="form-select form-control-teapos" id="maDm" name="maDm" required>
                                            <option value="">-- Chọn danh mục --</option>
                                            <c:forEach var="cat" items="${categories}">
                                                <option value="${cat.maDm}" ${maDm == cat.maDm ? 'selected' : ''}>
                                                    <c:out value="${cat.tenDm}"/>
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <!-- NÂNG CẤP: CHO PHÉP PICK FILE CHỌN ẢNH TỪ MÁY TÍNH -->
                                    <div class="col-12 col-md-6">
                                        <label class="form-label fw-bold small text-dark">Hình ảnh Đồ uống</label>
                                        <ul class="nav nav-pills border-0 bg-light p-1 rounded mb-2" id="sanphamImgTab" style="font-size: 11px; max-width: fit-content;">
                                            <li class="nav-item">
                                                <button class="nav-link active py-1 px-3 border-0 fw-bold btn-img-tab" id="tab_file" type="button" onclick="switchUploadType('file')">TẢI TỪ MÁY TÍNH</button>
                                            </li>
                                            <li class="nav-item">
                                                <button class="nav-link py-1 px-3 border-0 fw-bold btn-img-tab" id="tab_url" type="button" onclick="switchUploadType('url')">DÁN LINK URL</button>
                                            </li>
                                        </ul>
                                        <input type="hidden" name="uploadType" id="uploadType" value="file">
                                        <input type="hidden" name="currentHinhAnh" id="currentHinhAnh" value="${hinhAnh}">
                                        <div id="fileUploadGroup">
                                            <input type="file" class="form-control form-control-teapos" name="hinhAnhFile" accept="image/*" onchange="previewSelectedImage(this)">
                                        </div>
                                        <div id="urlUploadGroup" style="display: none;">
                                            <input type="text" class="form-control form-control-teapos" id="hinhAnhUrl" name="hinhAnhUrl" value="${hinhAnh}" placeholder="https://image-url..." onchange="previewUrlImage(this.value)">
                                        </div>
                                    </div>

                                    <!-- Mô tả -->
                                    <div class="col-12">
                                        <label for="moTa" class="form-label fw-bold small text-dark">Mô tả chi tiết đồ uống</label>
                                        <textarea class="form-control" id="moTa" name="moTa" rows="3"
                                                  placeholder="Mô tả hương vị, nguyên liệu pha chế, đặc sắc của cốc trà sữa...">${moTa}</textarea>
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
                                                ${choPhepDoiDa == 'true' || choPhepDoiDa == true ? 'checked' : ''}>
                                            <label class="form-check-label fw-semibold text-dark small" for="choPhepDoiDa">Đổi Đá (Ice)</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="form-check form-switch p-2 rounded bg-white border ps-5">
                                            <input class="form-check-input" type="checkbox" id="choPhepDoiDuong" name="choPhepDoiDuong" value="1"
                                                ${choPhepDoiDuong == 'true' || choPhepDoiDuong == true ? 'checked' : ''}>
                                            <label class="form-check-label fw-semibold text-dark small" for="choPhepDoiDuong">Đổi Đường (Sugar)</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="form-check form-switch p-2 rounded bg-white border ps-5">
                                            <input class="form-check-input" type="checkbox" id="isNew" name="isNew" value="1"
                                                ${isNew == 'true' || isNew == true ? 'checked' : ''}>
                                            <label class="form-check-label fw-semibold text-warning small" for="isNew">✨ Nhãn Mới (New)</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="form-check form-switch p-2 rounded bg-white border ps-5">
                                            <input class="form-check-input" type="checkbox" id="isBestseller" name="isBestseller" value="1"
                                                ${isBestseller == 'true' || isBestseller == true ? 'checked' : ''}>
                                            <label class="form-check-label fw-semibold text-danger small" for="isBestseller">🔥 Bán Chạy (Hot)</label>
                                        </div>
                                    </div>
                                    <div class="col-12 border-top pt-3 mt-3">
                                        <label class="form-label fw-bold small text-dark d-block">Trạng thái bán của sản phẩm mẹ</label>
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" name="trangThai" id="statusActive" value="1"
                                                ${trangThai == 'true' || trangThai == true ? 'checked' : ''}>
                                            <label class="form-check-label text-success fw-bold" for="statusActive">Đang hoạt động (Mở bán)</label>
                                        </div>
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" name="trangThai" id="statusInactive" value="0"
                                                ${trangThai == 'false' || trangThai == false ? 'checked' : ''}>
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
                                    <img id="imgPreview" src="${not empty hinhAnh ? hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" alt="Preview">
                                </div>
                                <p class="small text-muted text-center" style="line-height: 1.4;">Đo lường tỉ lệ hiển thị tối ưu là 500x500px tỉ lệ vuông (1:1) để đồ uống hiển thị sắc nét nhất trên cả POS và Website.</p>
                            </div>
                        </div>

                        <!-- PHẦN QUẢN LÝ KÍCH CỠ & GIÁ BÁN -->
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
                                        <thead class="table-success text-center">
                                        <tr>
                                            <th style="width: 100px;">Kích Hoạt</th>
                                            <th style="width: 120px;">Kích Cỡ</th>
                                            <th>Đơn Giá Bán Thực Tế (VNĐ) <span class="text-danger">*</span></th>
                                            <th>Định lượng cốc (Thể tích)</th>
                                            <th style="width: 180px;">Trạng Thái Mở Bán</th>
                                            <th style="width: 100px;">Thao Tác</th>
                                        </tr>
                                        </thead>
                                        <tbody id="sizesConfigTableBody">
                                        <c:forEach var="sz" items="${sizes}">
                                            <c:set var="isConfigured" value="false"/>
                                            <c:set var="savedPrice" value=""/>
                                            <c:set var="savedVolume" value=""/>
                                            <c:set var="sizeStatus" value="true"/>

                                            <c:forEach var="cp" items="${currentPrices}">
                                                <c:if test="${cp.maSize == sz.maSize}">
                                                    <c:set var="isConfigured" value="true"/>
                                                    <c:set var="savedPrice" value="${cp.giaBan}"/>
                                                    <c:set var="savedVolume" value="${cp.dinhLuong}"/>
                                                    <c:set var="sizeStatus" value="${cp.trangThai}"/>
                                                </c:if>
                                            </c:forEach>

                                            <tr class="text-center" id="row_size_${sz.maSize}">
                                                <td>
                                                    <input type="checkbox" name="size_active_${sz.maSize}" id="size_active_${sz.maSize}"
                                                           class="form-check-input size-check border-success" value="1"
                                                        ${isConfigured == 'true' ? 'checked' : ''} onchange="toggleSizeFields(${sz.maSize})">
                                                </td>
                                                <td>
                                                    <label class="form-check-label fw-bold text-dark" for="size_active_${sz.maSize}">
                                                        Size <span class="lbl-ten-size">${sz.tenSize}</span>
                                                    </label>
                                                </td>
                                                <td>
                                                    <div class="input-group input-group-sm mx-auto" style="max-width: 200px;">
                                                        <input type="number" name="size_price_${sz.maSize}" id="size_price_${sz.maSize}"
                                                               class="form-control text-end fw-bold text-success size-price-input"
                                                               value="${savedPrice}" ${isConfigured == 'true' ? "" : "disabled"} required min="1000" step="1000" placeholder="Nhập giá VNĐ...">
                                                        <span class="input-group-text bg-light text-muted">đ</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <input type="text" name="size_volume_${sz.maSize}" id="size_volume_${sz.maSize}"
                                                           class="form-control form-control-sm mx-auto size-volume-input" style="max-width: 150px;"
                                                           value="${savedVolume}" ${isConfigured == 'true' ? "" : "disabled"} placeholder="Ví dụ: 350ml, 500ml...">
                                                </td>
                                                <td>
                                                    <div class="form-check form-switch d-inline-block ps-5">
                                                        <input class="form-check-input size-status-switch" type="checkbox"
                                                               name="size_status_${sz.maSize}" id="size_status_${sz.maSize}" value="1"
                                                            ${isConfigured == 'false' || sizeStatus == 'true' || sizeStatus == true ? 'checked' : ''} ${isConfigured == 'true' ? '' : 'disabled'}>
                                                        <label class="form-check-label fw-semibold text-muted small" id="lbl_status_${sz.maSize}" for="size_status_${sz.maSize}">
                                                                ${isConfigured == 'false' || sizeStatus == 'true' || sizeStatus == true ? 'Mở bán' : 'Ngừng bán'}
                                                        </label>
                                                    </div>
                                                </td>
                                                <td>
                                                    <button type="button" class="btn btn-sm btn-outline-danger"
                                                            onclick="deleteSizeRow(${sz.maSize}, '${sz.tenSize}')">
                                                        <i class="bi bi-trash-fill"></i> Xóa
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <!-- CÁC NÚT ĐIỀU HÀNH -->
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
    function switchUploadType(type) {
        document.getElementById('uploadType').value = type;
        const btnFile = document.getElementById('tab_file');
        const btnUrl = document.getElementById('tab_url');
        if (type === 'file') {
            btnFile.classList.add('active', 'bg-success', 'text-white');
            btnUrl.classList.remove('active', 'bg-success', 'text-white');
            document.getElementById('fileUploadGroup').style.display = 'block';
            document.getElementById('urlUploadGroup').style.display = 'none';
            const fileIn = document.querySelector('input[name="hinhAnhFile"]');
            previewSelectedImage(fileIn);
        } else {
            btnUrl.classList.add('active', 'bg-success', 'text-white');
            btnFile.classList.remove('active', 'bg-success', 'text-white');
            document.getElementById('fileUploadGroup').style.display = 'none';
            document.getElementById('urlUploadGroup').style.display = 'block';
            previewUrlImage(document.getElementById('hinhAnhUrl').value);
        }
    }

    function previewSelectedImage(input) {
        const preview = document.getElementById('imgPreview');
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
            }
            reader.readAsDataURL(input.files[0]);
        } else {
            const curImg = document.getElementById('currentHinhAnh').value;
            preview.src = (curImg && curImg !== "") ? curImg : "https://cdn-icons-png.flaticon.com/512/3177/3177440.png";
        }
    }

    function previewUrlImage(url) {
        const preview = document.getElementById('imgPreview');
        if (url && url.trim() !== "") {
            preview.src = url.trim();
        } else {
            const curImg = document.getElementById('currentHinhAnh').value;
            preview.src = (curImg && curImg !== "") ? curImg : "https://cdn-icons-png.flaticon.com/512/3177/3177440.png";
        }
    }

    function toggleSizeFields(maSize) {
        const check = document.getElementById("size_active_" + maSize);
        const priceInput = document.getElementById("size_price_" + maSize);
        const volumeInput = document.getElementById("size_volume_" + maSize);
        const statusSwitch = document.getElementById("size_status_" + maSize);
        const lblStatus = document.getElementById("lbl_status_" + maSize);

        if (check.checked) {
            priceInput.disabled = false;
            volumeInput.disabled = false;
            statusSwitch.disabled = false;
            statusSwitch.checked = true;
            if (lblStatus) {
                lblStatus.innerText = 'Mở bán';
            }
            priceInput.focus();
        } else {
            priceInput.disabled = true;
            volumeInput.disabled = true;
            statusSwitch.disabled = true;
            statusSwitch.checked = false;
            if (lblStatus) {
                lblStatus.innerText = 'Ngừng bán';
            }
            priceInput.value = "";
            volumeInput.value = "";
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
        document.querySelectorAll('.size-status-switch').forEach(el => {
            el.addEventListener('change', function() {
                const maSize = this.id.replace("size_status_", "");
                const lbl = document.getElementById("lbl_status_" + maSize);
                if (lbl) {
                    lbl.innerText = this.checked ? "Mở bán" : "Ngừng bán";
                }
            });
        });

        // Khởi tạo tab upload
        const curImg = document.getElementById('currentHinhAnh').value;
        switchUploadType((curImg && curImg.startsWith('http')) ? 'url' : 'file');
    });

    function addNewSizeAjax() {
        const tenSizeInput = document.getElementById('newSizeNameInput');
        const tenSize = tenSizeInput.value.trim();
        if (!tenSize) {
            showToast('warning', 'Vui lòng điền tên kích cỡ mới (Ví dụ: XL)!');
            return;
        }

        Swal.fire({
            title: 'Đang lưu kích cỡ...',
            allowOutsideClick: false,
            didOpen: function() { Swal.showLoading(); }
        });

        const url = getContextPath() + '/admin/sanpham';
        const params = new URLSearchParams();
        params.append('action', 'addSizeAjax');
        params.append('tenSize', tenSize);

        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
            .then(function(res) { return res.json(); })
            .then(function(data) {
                Swal.close();
                if (data.status === 'SUCCESS') {
                    const maSize = data.maSize;
                    const normalizedTenSize = data.tenSize;

                    if (document.getElementById('row_size_' + maSize)) {
                        showToast('info', 'Mốc kích cỡ này đã tồn tại trong danh sách chọn bên dưới!');
                        tenSizeInput.value = '';
                        return;
                    }

                    const tbody = document.getElementById('sizesConfigTableBody');
                    const newRow = document.createElement('tr');
                    newRow.className = 'text-center';
                    newRow.id = 'row_size_' + maSize;

                    let rowHtml = '';
                    rowHtml += '<td>';
                    rowHtml += '<input type="checkbox" name="size_active_' + maSize + '" id="size_active_' + maSize + '" ';
                    rowHtml += 'class="form-check-input size-check border-success" value="1" checked onchange="toggleSizeFields(' + maSize + ')">';
                    rowHtml += '</td>';
                    rowHtml += '<td>';
                    rowHtml += '<label class="form-check-label fw-bold text-dark" for="size_active_' + maSize + '">';
                    rowHtml += 'Size <span class="lbl-ten-size">' + normalizedTenSize + '</span>';
                    rowHtml += '</label>';
                    rowHtml += '</td>';
                    rowHtml += '<td>';
                    rowHtml += '<div class="input-group input-group-sm mx-auto" style="max-width: 200px;">';
                    rowHtml += '<input type="number" name="size_price_' + maSize + '" id="size_price_' + maSize + '" ';
                    rowHtml += 'class="form-control text-end fw-bold text-success size-price-input" required min="1000" step="1000" placeholder="Nhập giá VNĐ...">';
                    rowHtml += '<span class="input-group-text bg-light text-muted">đ</span>';
                    rowHtml += '</div>';
                    rowHtml += '</td>';
                    rowHtml += '<td>';
                    rowHtml += '<input type="text" name="size_volume_' + maSize + '" id="size_volume_' + maSize + '" ';
                    rowHtml += 'class="form-control form-control-sm mx-auto size-volume-input" style="max-width: 150px;" placeholder="Ví dụ: 350ml, 500ml...">';
                    rowHtml += '</td>';
                    rowHtml += '<td>';
                    rowHtml += '<div class="form-check form-switch d-inline-block ps-5">';
                    rowHtml += '<input class="form-check-input size-status-switch" type="checkbox" name="size_status_' + maSize + '" id="size_status_' + maSize + '" value="1" checked>';
                    rowHtml += '<label class="form-check-label fw-semibold text-muted small" id="lbl_status_' + maSize + '" for="size_status_' + maSize + '">Mở bán</label>';
                    rowHtml += '</div>';
                    rowHtml += '</td>';
                    rowHtml += '<td>';
                    rowHtml += '<button type="button" class="btn btn-sm btn-outline-danger" onclick="deleteSizeRow(' + maSize + ', \'' + normalizedTenSize + '\')">';
                    rowHtml += '<i class="bi bi-trash-fill"></i> Xóa';
                    rowHtml += '</button>';
                    rowHtml += '</td>';

                    newRow.innerHTML = rowHtml;
                    tbody.appendChild(newRow);

                    document.getElementById("size_status_" + maSize).addEventListener('change', function() {
                        document.getElementById("lbl_status_" + maSize).innerText = this.checked ? "Mở bán" : "Ngừng bán";
                    });

                    showToast('success', 'Đã thêm thành công mốc kích cỡ ' + normalizedTenSize + ' vào biểu mẫu!');
                    tenSizeInput.value = '';
                    document.getElementById('size_price_' + maSize).focus();
                } else {
                    Swal.fire({ icon: 'error', title: 'Thao tác thất bại', text: data.message, confirmButtonColor: '#2e7d32' });
                }
            })
            .catch(function(err) {
                Swal.close();
                console.error('Lỗi kết nối AJAX:', err);
                showToast('error', 'Lỗi kết nối máy chủ!');
            });
    }

    function deleteSizeRow(maSize, tenSize) {
        const action = document.getElementById("formAction").value;
        const maSp = document.getElementById("formMaSp").value;

        if (action === 'create' || !maSp) {
            const row = document.getElementById("row_size_" + maSize);
            if (row) {
                const check = document.getElementById("size_active_" + maSize);
                if (check) {
                    check.checked = false;
                }
                row.remove();
                showToast('success', 'Đã gỡ bỏ kích cỡ Size ' + tenSize + ' khỏi biểu mẫu.');
            }
            return;
        }

        Swal.fire({
            title: 'Đang kiểm tra lịch sử bán...',
            allowOutsideClick: false,
            didOpen: function() { Swal.showLoading(); }
        });

        const checkUrl = getContextPath() + '/admin/sanpham?action=checkSizeOrder&maSp=' + maSp + '&maSize=' + maSize;
        fetch(checkUrl)
            .then(function(res) { return res.json(); })
            .then(function(data) {
                Swal.close();
                if (data.status === 'HAS_ORDERS') {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Không thể xóa cứng cấu hình!',
                        html: 'Kích cỡ <strong>Size ' + tenSize + '</strong> của sản phẩm này đã phát sinh giao dịch trong lịch sử hóa đơn bán nước! Để tránh gây lỗi sập cấu trúc dữ liệu, hệ thống tự động tắt trạng thái của kích cỡ này sang <strong>Ngừng bán</strong> để ẩn khỏi thực đơn.',
                        confirmButtonColor: '#10b981',
                        confirmButtonText: 'Đã hiểu'
                    }).then(function() {
                        const sw = document.getElementById("size_status_" + maSize);
                        if (sw) {
                            sw.checked = false;
                            const lbl = document.getElementById("lbl_status_" + maSize);
                            if (lbl) {
                                lbl.innerText = "Ngừng bán";
                            }
                        }
                        const activeChk = document.getElementById("size_active_" + maSize);
                        if (activeChk) {
                            activeChk.checked = true;
                            toggleSizeFields(maSize);
                        }
                    });
                } else if (data.status === 'NO_ORDERS') {
                    Swal.fire({
                        title: 'Xóa mốc kích cỡ?',
                        html: 'Mốc <strong>Size ' + tenSize + '</strong> chưa hề phát sinh giao dịch bán lẻ nào. Bạn có chắc muốn xóa vĩnh viễn mốc này khỏi sản phẩm (và cả bảng master kích cỡ nếu muốn)?',
                        icon: 'question',
                        showCancelButton: true,
                        showDenyButton: true,
                        confirmButtonColor: '#ef4444',
                        denyButtonColor: '#10b981',
                        cancelButtonColor: '#64748b',
                        confirmButtonText: 'Chỉ gỡ khỏi món',
                        denyButtonText: 'Xóa vĩnh viễn hệ thống',
                        cancelButtonText: 'Hủy bỏ'
                    }).then(function(result) {
                        if (result.isConfirmed) {
                            // Chỉ gỡ khỏi món
                            const check = document.getElementById("size_active_" + maSize);
                            if (check) {
                                check.checked = false;
                            }
                            const row = document.getElementById("row_size_" + maSize);
                            if (row) {
                                row.remove();
                            }
                            showToast('success', 'Đã gỡ bỏ mốc kích cỡ Size ' + tenSize + ' khỏi sản phẩm.');
                        } else if (result.isDenied) {
                            // Xóa vĩnh viễn khỏi hệ thống KICH_CO
                            Swal.fire({
                                title: 'Đang xóa vĩnh viễn kích cỡ...',
                                allowOutsideClick: false,
                                didOpen: function() { Swal.showLoading(); }
                            });

                            const delUrl = getContextPath() + '/admin/sanpham?action=deleteSizeMasterAjax&maSize=' + maSize;
                            fetch(delUrl)
                                .then(res => res.json())
                                .then(resData => {
                                    Swal.close();
                                    if (resData.status === 'SUCCESS') {
                                        const row = document.getElementById("row_size_" + maSize);
                                        if (row) {
                                            row.remove();
                                        }
                                        showToast('success', 'Đã xóa vĩnh viễn kích cỡ Size ' + tenSize + ' khỏi toàn bộ hệ thống!');
                                    } else {
                                        Swal.fire({ icon: 'error', title: 'Lỗi', text: resData.message });
                                    }
                                })
                                .catch(err => {
                                    Swal.close();
                                    showToast('error', 'Không thể kết nối máy chủ!');
                                });
                        }
                    });
                } else {
                    showToast('error', data.message || 'Lỗi kiểm toán mốc size!');
                }
            })
            .catch(function(err) {
                Swal.close();
                console.error('Lỗi kiểm toán AJAX:', err);
                showToast('error', 'Lỗi kết nối kiểm soát cơ sở dữ liệu!');
            });
    }

    function getContextPath() {
        return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    }

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

        let invalidPrice = false;
        activeChecks.forEach(function(chk) {
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