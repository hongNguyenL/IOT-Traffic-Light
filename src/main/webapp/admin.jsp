<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.List, dao.ViolationDAO, model.Violation, Esp32Server.Esp32ServerListener" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    // listV is now loaded by AdminServlet and passed as a request attribute
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - IoT Smart Traffic</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
</head>
<body>
<div id="auth-container">
    <div class="auth-card">
        <h2>🚦 Admin Login</h2>
        <input type="text" id="login-user" placeholder="Username">
        <input type="password" id="login-pass" placeholder="Password">
        <button onclick="handleLogin()" class="btn-mode btn-primary" style="width:100%; margin-top:10px; justify-content: center;">Login</button>
    </div>
</div>

<div id="admin-panel" style="display: none;">
    <div class="sidebar">
        <h2>🚦 IoT Portal</h2>
        <div class="nav-links">
            <button onclick="showSection('dashboard')" id="nav-dashboard" class="active"><span class="icon">🏠</span><span class="text">Dashboard</span></button>
            <button onclick="showSection('control')" id="nav-control"><span class="icon">⚙️</span><span class="text">Settings</span></button>
            <button onclick="showSection('security')" id="nav-security"><span class="icon">📸</span><span class="text">Violations</span></button>
        </div>
        <div class="logout-container">
            <button onclick="handleLogout()" class="btn-danger"><span class="icon">🚪</span><span class="text">Logout</span></button>
        </div>
    </div>
    <div class="main">
        <div id="dashboard" class="section">
            <div class="card" style="text-align:center;">
                <div class="connection-status" style="display: flex; align-items: center;">
                    <div id="status-dot" class="status-dot"></div>
                    <span id="conn-text" style="color:var(--text-muted); font-size: 0.85rem; font-weight: 600;">CONNECTING...</span>
                    <button onclick="toggleVirtualMode()" id="btn-virtual" class="btn-mode" style="margin-left:auto; padding: 6px 12px; font-size: 0.8rem; background: #8b5cf6; color: white;">Enable Virtual Mode</button>
                </div>

                <div class="traffic-container">
                    <div class="traffic-box">
                        <h3 style="color: var(--text-muted); font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.05em;">Intersection 1</h3>
                        <div class="traffic-light">
                            <div id="light1-red" class="light red"></div>
                            <div id="light1-yellow" class="light yellow"></div>
                            <div id="light1-green" class="light green"></div>
                        </div>
                        <div id="timer1-display" class="timer-val">0s</div>
                        <div id="status1-display" style="font-weight:700; margin-top:1rem; color: var(--primary); font-size: 0.9rem;">WAITING...</div>
                    </div>

                    <div class="traffic-box">
                        <h3 style="color: var(--text-muted); font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.05em;">Intersection 2</h3>
                        <div class="traffic-light">
                            <div id="light2-red" class="light red"></div>
                            <div id="light2-yellow" class="light yellow"></div>
                            <div id="light2-green" class="light green"></div>
                        </div>
                        <div id="timer2-display" class="timer-val">0s</div>
                        <div id="status2-display" style="font-weight:700; margin-top:1rem; color: var(--primary); font-size: 0.9rem;">WAITING...</div>
                    </div>
                </div>
                <p id="mode-badge" style="display:none; color:var(--error); font-weight:700; margin-top:20px; background: #fff1f2; padding: 10px; border-radius: 8px; border: 1px solid #fecdd3;">[ ADJUSTING MODE ACTIVE ]</p>
            </div>
        </div>
        
        <div id="control" class="section" style="display:none;">
            <div class="card">
                <h3>🛠 Time Settings (Seconds)</h3>
                <div id="adjust-actions" style="margin-bottom: 2rem;">
                    <button id="btn-start" class="btn-mode btn-primary" style="background: var(--warning);" onclick="toggleAdjustMode(true)">Start Adjusting</button>
                    <button id="btn-finish" class="btn-mode btn-primary" style="background: var(--success); display:none;" onclick="toggleAdjustMode(false)">Save Configuration</button>
                </div>
                <div id="input-fields" style="opacity: 0.5; pointer-events: none; display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 1.5rem;">
                    <div>
                        <label style="display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 0.5rem; color: var(--success);">GREEN LIGHT</label>
                        <input type="number" id="g" value="10" class="auth-card" style="margin: 0; padding: 0.5rem 1rem; text-align: left; max-width: 100px;">
                    </div>
                    <div>
                        <label style="display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 0.5rem; color: var(--warning);">YELLOW LIGHT</label>
                        <input type="number" id="y" value="3" class="auth-card" style="margin: 0; padding: 0.5rem 1rem; text-align: left; max-width: 100px;">
                    </div>
                    <div>
                        <label style="display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 0.5rem; color: var(--error);">RED LIGHT (Auto-calculated)</label>
                        <input type="number" id="r" value="13" class="auth-card" readonly style="margin: 0; padding: 0.5rem 1rem; text-align: left; max-width: 100px; background-color: #f1f5f9; cursor: not-allowed; color: #64748b; font-weight: bold;">
                    </div>
                </div>
            </div>
        </div>

        <div id="security" class="section" style="display:none;">
            <div class="card">
                <div class="search-bar">
                    <div style="flex: 1;">
                        <h3 style="margin: 0;">📸 Violation Logs</h3>
                    </div>
                    <div style="display: flex; gap: 0.5rem; align-items: center;">
                        <input type="date" id="search-date" class="auth-card" style="margin: 0; padding: 0.4rem 0.8rem; font-size: 0.9rem; width: auto;">
                        <input type="text" id="search-plate" class="auth-card" placeholder="License Plate" style="margin: 0; padding: 0.4rem 0.8rem; font-size: 0.9rem; width: 120px;">
                        <select id="search-type" class="auth-card" style="margin: 0; padding: 0.4rem 0.8rem; font-size: 0.9rem; width: auto; background: white;">
                            <option value="">All Types</option>
                            <option value="Car">Car</option>
                            <option value="Motorbike">Motorbike</option>
                            <option value="Truck">Truck</option>
                            <option value="Bus">Bus</option>
                        </select>
                        <button onclick="filterViolations()" class="btn-mode btn-primary">🔍 Filter</button>
                        <button onclick="hienTatCaAnh()" class="btn-mode" style="background: var(--secondary); color: white;">🔄 All</button>
                        <button onclick="deleteAllViolations()" class="btn-mode btn-danger">🗑️ Delete All</button>
                    </div>
                </div>
                <div class="violation-container">
                    <c:forEach items="${listV}" var="v">
                        <fmt:formatDate value="${v.violationTime}" pattern="yyyy-MM-dd HH:mm:ss" var="formattedDate" />
                        <div class="violation-card" data-date="${formattedDate}" data-plate="${v.licensePlate}" data-type="${v.vehicleType}">
                            <img src="${v.imageUrl}" onclick="moAnhPhongTo('${v.imageUrl}', '${v.violationTime}', '${v.licensePlate}', '${v.vehicleType}', '${v.confident}')" onerror="this.src='https://placehold.co/400x300?text=No+Image'">
                            <div class="info">
                                <h4>🚗 ${v.licensePlate}</h4>
                                <div style="font-size: 0.8rem; color: var(--text-muted); display: flex; flex-direction: column; gap: 2px;">
                                    <span>Type: ${v.vehicleType}</span>
                                    <span>Time: ${v.violationTime}</span>
                                    <c:choose>
                                        <c:when test="${not empty v.confident}">
                                            <c:choose>
                                                <c:when test="${v.confident >= 80}">
                                                    <span style="color: #10b981; font-weight: 600;">🎯 Confidence: <fmt:formatNumber value="${v.confident}" maxFractionDigits="1"/>%</span>
                                                </c:when>
                                                <c:when test="${v.confident >= 50}">
                                                    <span style="color: #f59e0b; font-weight: 600;">🎯 Confidence: <fmt:formatNumber value="${v.confident}" maxFractionDigits="1"/>%</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #ef4444; font-weight: 600;">🎯 Confidence: <fmt:formatNumber value="${v.confident}" maxFractionDigits="1"/>%</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: var(--text-muted);">🎯 Confidence: N/A</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <button onclick="deleteViolation(${v.violationId})" class="btn-mode btn-danger" style="margin-top: 8px; width: 100%;">🗑️ Delete</button>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="secModal" class="modal-security" onclick="dongAnhPhongTo()">
    <div class="modal-content" onclick="event.stopPropagation()">
        <span style="position:absolute; top:10px; right:20px; font-size:35px; cursor:pointer;" onclick="dongAnhPhongTo()">&times;</span>
        <img id="secModalImg" src="" style="width:100%; max-height:50vh; object-fit:contain; border-radius:8px;">
        <div style="text-align:left; margin-top:15px; border-top:1px solid #eee; padding-top:10px;">
            <p><strong>🚗 Biển số xe:</strong> <span id="modalPlate" style="color:#2563eb; font-weight:bold;"></span></p>
            <p><strong>🚙 Loại xe:</strong> <span id="modalVehicleType" style="color:#2563eb; font-weight:bold;"></span></p>
            <p><strong>🕒 Thời gian:</strong> <span id="modalTime"></span></p>
            <p><strong>🎯 Confidence:</strong> <span id="modalConfident" style="font-weight:bold;"></span></p>
        </div>
    </div>
</div>

<script>
    let config = {GREEN: <%= Esp32ServerListener.timeGreen%>, YELLOW: <%= Esp32ServerListener.timeYellow%>, RED: <%= Esp32ServerListener.timeRed%>};
    let timeLeft1 = 0, timeLeft2 = 0;
    let isAdjusting = false;
    let currentMainColor1 = "", currentMainColor2 = "";
    let isConnected = false;
    let isVirtualMode = false;
    let vPhase = 1;

    // --- HÀM TỰ ĐỘNG TÍNH TOÁN ĐÈN ĐỎ ---
    function autoCalculateRed() {
        const gVal = parseInt(document.getElementById('g').value) || 0;
        const yVal = parseInt(document.getElementById('y').value) || 0;
        document.getElementById('r').value = gVal + yVal;
    }

    function showSection(id) {
        document.querySelectorAll('.section').forEach(sec => sec.style.display = 'none');
        document.getElementById(id).style.display = 'block';
        document.querySelectorAll('.sidebar button').forEach(btn => btn.classList.remove('active'));
        const activeBtn = document.getElementById('nav-' + id);
        if (activeBtn) activeBtn.classList.add('active');
        window.location.hash = id;
    }

async function fetchStatus() {
        if (isAdjusting) {
            setTimeout(fetchStatus, 800);
            return;
        }
        try {
            const res = await fetch('status_api.jsp');
            let rawTxt = (await res.text()).trim().toUpperCase();
            
            // Tách chuỗi theo dấu |
            let parts = rawTxt.split('|');
            let txt = parts[0];       // Đây là chuỗi "D1: XANH, D2: DO, T:10"
            let lockInfo = parts[1] || "FREE";
            let configInfo = parts[2] || "";

            // Cập nhật lại config để đếm giây không bị lệch
            if (configInfo) {
                let c = configInfo.split(',');
                config.GREEN = parseInt(c[0]);
                config.YELLOW = parseInt(c[1]);
                config.RED = config.GREEN + config.YELLOW;
            }

            const btnS = document.getElementById('btn-start');
            if (lockInfo === "LOCKED") {
                btnS.disabled = true;
                btnS.innerText = "Locked: User Adjusting";
                btnS.style.opacity = 0.5;
                document.getElementById('mode-badge').style.display = 'block';
            } else if (btnS.disabled) {
                btnS.disabled = false;
                btnS.innerText = "Start Adjusting";
                btnS.style.opacity = 1;
                document.getElementById('mode-badge').style.display = 'none';
            }

            const dot = document.getElementById('status-dot');
            const connText = document.getElementById('conn-text');

            if (!isVirtualMode) {
                if (txt.includes("LOST CONNECTION")) {
                    setOfflineUI(dot, connText);
                } else {
                    setOnlineUI(dot, connText);
                    let color1 = "", color2 = "";
                    
                    // Kiểm tra màu đèn (Lưu ý: Phải khớp chính xác từng dấu cách với ESP32)
                    if (txt.includes("D1: XANH")) color1 = "GREEN";
                    else if (txt.includes("D1: VANG")) color1 = "YELLOW";
                    else if (txt.includes("D1: DO")) color1 = "RED";

                    if (txt.includes("D2: XANH")) color2 = "GREEN";
                    else if (txt.includes("D2: VANG")) color2 = "YELLOW";
                    else if (txt.includes("D2: DO")) color2 = "RED";

                    let hwTimer = -1;
                    const tMatch = txt.match(/T:(\d+)/);
                    if (tMatch) hwTimer = parseInt(tMatch[1]);
                    
                    // Đồng bộ thời gian Hướng 1
                    updateLightUI(1, color1, hwTimer);
                    
                    // Tự tính thời gian Hướng 2 để không bị giống hệt Hướng 1
                    let t2 = hwTimer;
                    if (color1 === "GREEN") t2 = hwTimer + config.YELLOW;
                    else if (color1 === "RED") t2 = hwTimer - config.YELLOW;
                    
                    updateLightUI(2, color2, t2);
                }
            }
        } catch (e) {
            console.error("Lỗi fetch:", e);
        }
        setTimeout(fetchStatus, 800);
    }
    function setOfflineUI(dot, connText) {
        isConnected = false;
        dot.className = "status-dot offline";
        connText.innerText = "MẤT KẾT NỐI VỚI THIẾT BỊ";
        connText.style.color = "#ef4444";
        document.getElementById('status1-display').innerText = "MẤT KẾT NỐI";
        document.getElementById('status2-display').innerText = "MẤT KẾT NỐI";
        document.querySelectorAll('.light').forEach(l => l.classList.remove('active', 'blinking-red'));
        document.getElementById('timer1-display').innerText = "0s";
        document.getElementById('timer2-display').innerText = "0s";
    }

    function setOnlineUI(dot, connText) {
        isConnected = true;
        dot.className = "status-dot online";
        connText.innerText = "THIẾT BỊ ĐANG ONLINE";
        connText.style.color = "#10b981";
    }
    
    function updateLightUI(idx, color, hwTimer) {
        if (!color) return;
        if (idx === 1) {
            if (color !== currentMainColor1) {
                currentMainColor1 = color;
                document.querySelectorAll('[id^="light1-"]').forEach(l => l.classList.remove('active', 'blinking-red'));
                document.getElementById('light1-' + color.toLowerCase()).classList.add('active');
                document.getElementById('status1-display').innerText = color + " LIGHT";
                timeLeft1 = (hwTimer >= 0) ? hwTimer : config[color];
            } else if (hwTimer >= 0) {
                timeLeft1 = hwTimer;
            }
        }
        if (idx === 2) {
            if (color !== currentMainColor2) {
                currentMainColor2 = color;
                document.querySelectorAll('[id^="light2-"]').forEach(l => l.classList.remove('active', 'blinking-red'));
                document.getElementById('light2-' + color.toLowerCase()).classList.add('active');
                document.getElementById('status2-display').innerText = color + " LIGHT";
                timeLeft2 = (hwTimer >= 0) ? hwTimer : config[color];
            } else if (hwTimer >= 0) {
                timeLeft2 = hwTimer;
            }
        }
    }
    
    function toggleVirtualMode() {
        isVirtualMode = !isVirtualMode;
        const btn = document.getElementById('btn-virtual');
        if (isVirtualMode) {
            btn.innerText = "Disable Virtual Mode";
            btn.style.background = "#ef4444";
            vPhase = 1;
            setVirtualLightState();
        } else {
            btn.innerText = "Enable Virtual Mode";
            btn.style.background = "#8b5cf6";
            timeLeft1 = 0; timeLeft2 = 0;
            currentMainColor1 = ""; currentMainColor2 = "";
        }
    }

    function setVirtualLightState() {
        if (!isVirtualMode) return;
        let c1, c2, t;
        if (vPhase === 1) { c1 = "GREEN"; c2 = "RED"; t = config.GREEN; }
        else if (vPhase === 2) { c1 = "YELLOW"; c2 = "RED"; t = config.YELLOW; }
        else if (vPhase === 3) { c1 = "RED"; c2 = "GREEN"; t = config.GREEN; }
        else if (vPhase === 4) { c1 = "RED"; c2 = "YELLOW"; t = config.YELLOW; }
        updateLightUI(1, c1);
        updateLightUI(2, c2);
        timeLeft1 = t;
        timeLeft2 = t;
        const dot = document.getElementById('status-dot');
        const connText = document.getElementById('conn-text');
        dot.className = "status-dot online";
        connText.innerText = "VIRTUAL MODE ACTIVE";
        connText.style.color = "#8b5cf6";
    }

    async function toggleAdjustMode(start) {
        const btnS = document.getElementById('btn-start');
        const btnF = document.getElementById('btn-finish');
        const box = document.getElementById('input-fields');
        if (start) {
            const lockRes = await fetch('set_adjust_status.jsp?status=true');
            const lockTxt = await lockRes.text();
            if (lockTxt.includes('LOCKED')) {
                alert("Another user is currently adjusting settings!");
                return;
            }
            isAdjusting = true;
            btnS.style.display = 'none'; btnF.style.display = 'inline-block';
            box.style.opacity = '1'; box.style.pointerEvents = 'auto';
            document.getElementById('mode-badge').style.display = 'block';
            document.getElementById('mode-badge').innerText = "[ ADJUSTING MODE ACTIVE ]";
            autoCalculateRed(); // Tính toán lại khi bắt đầu sửa
        } else {
            const gVal = document.getElementById('g').value;
            const yVal = document.getElementById('y').value;
            const rVal = document.getElementById('r').value;
            if (!gVal || !yVal || !rVal) { alert("Vui lòng nhập số!"); return; }
            try {
                const url = "update_config.jsp?g=" + gVal + "&y=" + yVal + "&r=" + rVal + "&t=" + Date.now();
                const res = await fetch(url);
                const txt = await res.text();
                if (txt.includes("OK")) {
                    config.GREEN = parseInt(gVal); config.YELLOW = parseInt(yVal); config.RED = parseInt(rVal);
                    if (isVirtualMode) setVirtualLightState();
                    else {
                        timeLeft1 = config[currentMainColor1];
                        timeLeft2 = config[currentMainColor2];
                    }
                    isAdjusting = false;
                    btnS.style.display = 'inline-block'; btnF.style.display = 'none';
                    box.style.opacity = '0.5'; box.style.pointerEvents = 'none';
                    document.getElementById('mode-badge').style.display = 'none';
                    await fetch('set_adjust_status.jsp?status=false');
                    alert("Thành công!");
                }
            } catch (e) { alert("Lỗi kết nối!"); }
        }
    }

    function filterViolations() {
        const d = document.getElementById('search-date').value;
        const p = document.getElementById('search-plate').value.toLowerCase();
        const t = document.getElementById('search-type').value.toLowerCase();
        document.querySelectorAll('.violation-card').forEach(c => {
            const cardDate = c.getAttribute('data-date') || "";
            const cardPlate = (c.getAttribute('data-plate') || "").toLowerCase();
            const cardType = (c.getAttribute('data-type') || "").toLowerCase();
            const matchDate = d === "" || cardDate.includes(d);
            const matchPlate = p === "" || cardPlate.includes(p);
            const matchType = t === "" || cardType === t;
            c.style.display = (matchDate && matchPlate && matchType) ? 'block' : 'none';
        });
    }

    function hienTatCaAnh() { 
        document.getElementById('search-date').value = "";
        document.getElementById('search-plate').value = "";
        document.getElementById('search-type').value = "";
        document.querySelectorAll('.violation-card').forEach(c => c.style.display = 'block'); 
    }
    
    function deleteViolation(id) {
        if(confirm("Are you sure you want to delete this violation?")) {
            window.location.href = "deleteViolation?id=" + id;
        }
    }

    function deleteAllViolations() {
        const count = document.querySelectorAll('.violation-card').length;
        if (count === 0) { alert("No violations to delete."); return; }
        if (confirm("⚠️ Are you sure you want to DELETE ALL " + count + " violations?")) {
            window.location.href = "deleteAllViolations";
        }
    }

    function moAnhPhongTo(src, t, p, vtype, conf) {
        document.getElementById('secModalImg').src = src;
        document.getElementById('modalPlate').innerText = p;
        document.getElementById('modalVehicleType').innerText = vtype;
        document.getElementById('modalTime').innerText = t;
        let confEl = document.getElementById('modalConfident');
        if (confEl) {
            if (conf && conf !== 'null' && conf !== '') {
                let cVal = parseFloat(conf);
                confEl.innerText = cVal.toFixed(1) + "%";
                confEl.style.color = (cVal >= 80) ? "#10b981" : (cVal >= 50 ? "#f59e0b" : "#ef4444");
            } else {
                confEl.innerText = "N/A"; confEl.style.color = "var(--text-muted)";
            }
        }
        document.getElementById('secModal').style.display = 'flex';
    }

    function dongAnhPhongTo() { document.getElementById('secModal').style.display = 'none'; }

    function handleLogin() {
        const u = document.getElementById('login-user').value;
        const p = document.getElementById('login-pass').value;
        if ((u === "admin" && p === "123") || (u === localStorage.getItem('adminUser') && p === localStorage.getItem('adminPass'))) {
            sessionStorage.setItem('adminLoggedIn', 'true');
            startAdminSession();
        } else alert("Sai tài khoản!");
    }

    function startAdminSession() {
        document.getElementById('auth-container').style.display = 'none';
        document.getElementById('admin-panel').style.display = 'block';
        fetchStatus();
        setInterval(() => {
            if (!isAdjusting) {
                if (isVirtualMode) {
                    if (timeLeft1 > 0) timeLeft1--;
                    if (timeLeft2 > 0) timeLeft2--;
                    if (timeLeft1 <= 0 && timeLeft2 <= 0) {
                        vPhase++; if (vPhase > 4) vPhase = 1;
                        setVirtualLightState();
                    }
                    document.getElementById('timer1-display').innerText = timeLeft1 + "s";
                    document.getElementById('timer2-display').innerText = timeLeft2 + "s";
                } else if (isConnected) {
                    if (timeLeft1 > 0 && !document.getElementById('light1-red').classList.contains('blinking-red')) timeLeft1--;
                    if (timeLeft2 > 0 && !document.getElementById('light2-red').classList.contains('blinking-red')) timeLeft2--;
                    document.getElementById('timer1-display').innerText = timeLeft1 + "s";
                    document.getElementById('timer2-display').innerText = timeLeft2 + "s";
                }
            }
        }, 1000);
    }
    
    function handleLogout() {
        sessionStorage.removeItem('adminLoggedIn');
        location.reload();
    }
    
    window.addEventListener('DOMContentLoaded', () => {
        // GẮN SỰ KIỆN LẮNG NGHE CHO Ô XANH VÀ VÀNG
        document.getElementById('g').addEventListener('input', autoCalculateRed);
        document.getElementById('y').addEventListener('input', autoCalculateRed);

        if (sessionStorage.getItem('adminLoggedIn') === 'true') {
             startAdminSession();
             const hash = window.location.hash.replace('#', '') || 'dashboard';
             showSection(hash);
        }
    });
    
    window.addEventListener('beforeunload', function (e) {
        if (isAdjusting) navigator.sendBeacon('set_adjust_status.jsp?status=false');
    });
</script>
</body>
</html>