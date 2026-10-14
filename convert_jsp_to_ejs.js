import fs from 'fs';
import path from 'path';

const SRC_DIR = 'src/main/webapp/views';
const DEST_DIR = 'views';

function convertJspToEjs(content, filePath) {
    let out = content;

    // Remove page directives and taglibs
    out = out.replace(/<%@\s*page[^%>]*%>/gi, '');
    out = out.replace(/<%@\s*taglib[^%>]*%>/gi, '');

    // Convert includes
    // e.g. <jsp:include page="/views/layout/header_portal.jsp" /> or <jsp:include page="pos_modals.jsp" />
    out = out.replace(/<jsp:include\s+page=["']\/views\/(.*?)\.jsp["']\s*\/>/gi, (match, p1) => {
        return `<%- include('../${p1}') %>`;
    });
    out = out.replace(/<jsp:include\s+page=["'](.*?)\.jsp["']\s*\/>/gi, (match, p1) => {
        if (p1.startsWith('/views/')) {
            return `<%- include('../${p1.replace('/views/', '')}') %>`;
        }
        return `<%- include('${p1}') %>`;
    });

    // Replace contextPath
    out = out.replace(/\${pageContext\.request\.contextPath}/g, '');
    out = out.replace(/\${pageContext\.request\.requestURI}/g, 'requestURI');
    out = out.replace(/\${pageContext\.request\.servletPath}/g, 'servletPath');

    // Replace sessionScope
    out = out.replace(/\${sessionScope\.user\.(.*?)}/g, '${(user && user.$1) || ""}');
    out = out.replace(/\${sessionScope\.user}/g, '${user || ""}');
    out = out.replace(/\${sessionScope\.customer\.(.*?)}/g, '${(customer && customer.$1) || ""}');
    out = out.replace(/\${sessionScope\.customer}/g, '${customer || ""}');
    out = out.replace(/\${sessionScope\.customerCartCount}/g, '${cartCount || 0}');
    out = out.replace(/\${requestScope\.(.*?)}/g, '${$1}');

    // Convert c:out
    out = out.replace(/<c:out\s+value=["']\${(.*?)}["']\s*\/>/gi, '<%= $1 %>');
    out = out.replace(/<c:out\s+value=["'](.*?)}["']\s*\/>/gi, '<%= $1 %>');

    // Convert c:set
    out = out.replace(/<c:set\s+var=["'](.*?)["']\s+value=["']\${(.*?)}["']\s*\/>/gi, '<% var $1 = $2; %>');
    out = out.replace(/<c:set\s+var=["'](.*?)["']\s+value=["'](.*?)["']\s*\/>/gi, '<% var $1 = "$2"; %>');

    // Convert fmt:formatNumber
    out = out.replace(/<fmt:formatNumber\s+value=["']\${(.*?)}["'][^>]*\/>/gi, '<%= formatVND($1) %>');

    // Convert c:forEach
    out = out.replace(/<c:forEach\s+var=["'](.*?)["']\s+items=["']\${(.*?)}["'](?:\s+varStatus=["'](.*?)["'])?(?:\s+end=["'](.*?)["'])?\s*>/gi, (m, varName, itemsName, statusName, endVal) => {
        let cleanItems = convertElExpr(itemsName);
        if (endVal !== undefined) {
            return `<% (${cleanItems} || []).slice(0, ${parseInt(endVal) + 1}).forEach(function(${varName}, ${statusName || 'idx'}) { var loop = { first: (${statusName || 'idx'} === 0), index: ${statusName || 'idx'} }; %>`;
        }
        return `<% (${cleanItems} || []).forEach(function(${varName}, ${statusName || 'idx'}) { var loop = { first: (${statusName || 'idx'} === 0), index: ${statusName || 'idx'} }; %>`;
    });
    out = out.replace(/<\/c:forEach>/gi, '<% }); %>');

    // Convert c:choose, c:when, c:otherwise
    out = out.replace(/<c:choose>/gi, '');
    out = out.replace(/<\/c:choose>/gi, '');
    out = out.replace(/<c:when\s+test=["']\${(.*?)}["']\s*>/gi, (m, expr) => {
        return `<% if (${convertElExpr(expr)}) { %>`;
    });
    out = out.replace(/<\/c:when>/gi, '<% } %>');
    out = out.replace(/<c:otherwise>/gi, '<% else { %>');
    out = out.replace(/<\/c:otherwise>/gi, '<% } %>');

    // Convert c:if
    out = out.replace(/<c:if\s+test=["']\${(.*?)}["']\s*>/gi, (m, expr) => {
        return `<% if (${convertElExpr(expr)}) { %>`;
    });
    out = out.replace(/<\/c:if>/gi, '<% } %>');

    // Convert remaining ${...} in templates to <%= ... %>
    // except inside <script> tags or inline JS where ${...} might be template literals or raw JSON output
    // Wait, let's be careful with inline strings like value="${item.id}"
    out = out.replace(/\$\{([^}]+)\}/g, (match, expr) => {
        // If it's already inside <% ... %> don't change
        return `<%= ${convertElExpr(expr)} %>`;
    });

    return out;
}

function convertElExpr(expr) {
    let s = expr.trim();
    // Replace boolean operators
    s = s.replace(/\bempty\s+([a-zA-Z0-9_$.]+)/g, '(!$1 || (Array.isArray($1) && $1.length === 0))');
    s = s.replace(/\bnot\s+empty\s+([a-zA-Z0-9_$.]+)/g, '($1 && (!Array.isArray($1) || $1.length > 0))');
    s = s.replace(/\beq\b/g, '==');
    s = s.replace(/\bne\b/g, '!=');
    s = s.replace(/\band\b/g, '&&');
    s = s.replace(/\bor\b/g, '||');
    s = s.replace(/\bnot\b/g, '!');
    return s;
}

function walkDir(dir, callback) {
    fs.readdirSync(dir).forEach(f => {
        let fullPath = path.join(dir, f);
        if (fs.statSync(fullPath).isDirectory()) {
            walkDir(fullPath, callback);
        } else {
            callback(fullPath);
        }
    });
}

function run() {
    walkDir(SRC_DIR, filePath => {
        if (!filePath.endsWith('.jsp')) return;
        const relativePath = path.relative(SRC_DIR, filePath);
        const destPath = path.join(DEST_DIR, relativePath.replace(/\.jsp$/, '.ejs'));
        fs.mkdirSync(path.dirname(destPath), { recursive: true });
        const content = fs.readFileSync(filePath, 'utf-8');
        const converted = convertJspToEjs(content, filePath);
        fs.writeFileSync(destPath, converted, 'utf-8');
        console.log(`Converted: ${relativePath} -> ${destPath}`);
    });
}

run();
