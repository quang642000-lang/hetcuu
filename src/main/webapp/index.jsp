<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Chuyển hướng tự động sang Servlet trang chủ Portal của khách hàng
    response.sendRedirect(request.getContextPath() + "/home");
%>