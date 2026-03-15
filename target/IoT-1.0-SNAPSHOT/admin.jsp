<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.List, dao.ViolationDAO, model.Violation, Esp32Server.Esp32ServerListener" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
            <button onclick="location.reload()" class="btn-danger"><span class="icon">🚪</span><span class="text">Logout</span></button>
        </div>
    </div>
    <div class="main">
        <div id="dashboard" class="section">
            <div class="card" style="text-align:center;">
                <div class="connection-status">
                    <div id="status-dot" class="status-dot"></div>
                    <span id="conn-text" style="color:var(--text-muted); font-size: 0.85rem; font-weight: 600;">CONNECTING...</span>
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
                        <label style="display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 0.5rem; color: var(--error);">RED LIGHT</label>
                        <input type="number" id="r" value="15" class="auth-card" style="margin: 0; padding: 0.5rem 1rem; text-align: left; max-width: 100px;">
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
                        <button onclick="timKiemTheoNgay()" class="btn-mode btn-primary">🔍 Filter</button>
                        <button onclick="hienTatCaAnh()" class="btn-mode" style="background: var(--secondary); color: white;">🔄 All</button>
                    </div>
                </div>
                <div class="violation-container">
                    <c:forEach items="${listV}" var="v">
                        <div class="violation-card" data-date="${v.violationTime}">
                            <img src="${v.imageUrl}" onclick="moAnhPhongTo('${v.imageUrl}', '${v.violationTime}', '${v.licensePlate}', '${v.vehicleType}', '${v.severityLevel}')" onerror="this.src='https://placehold.co/400x300?text=No+Image'">
                            <div class="info">
                                <h4>🚗 ${v.licensePlate}</h4>
                                <div style="font-size: 0.8rem; color: var(--text-muted); display: flex; flex-direction: column; gap: 2px;">
                                    <span>Type: ${v.vehicleType}</span>
                                    <span>Time: ${v.violationTime}</span>
                                </div>
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
        <img id="secModalImg" src="" style="width:100%; border-radius:8px;">
        <div style="text-align:left; margin-top:15px; border-top:1px solid #eee; padding-top:10px;">
            <p><strong>🚗 Biển số xe:</strong> <span id="modalPlate" style="color:#2563eb; font-weight:bold;"></span></p>
            <p><strong>🚙 Loại xe:</strong> <span id="modalVehicleType" style="color:#2563eb; font-weight:bold;"></span></p>
            <p><strong>🕒 Thời gian:</strong> <span id="modalTime"></span></p>
            <p><strong>⚠️ Loại vi phạm:</strong> <span id="modalType" style="color:#ef4444; font-weight:bold;"></span></p>
        </div>
    </div>
</div>

<script>
    let config = {GREEN: <%= Esp32ServerListener.timeGreen%>, YELLOW: <%= Esp32ServerListener.timeYellow%>, RED: <%= Esp32ServerListener.timeRed%>};
    let timeLeft1 = 0, timeLeft2 = 0;
    let isAdjusting = false;
    let currentMainColor1 = "", currentMainColor2 = "";
    let isConnected = false;

    function showSection(id) {
        document.querySelectorAll('.section').forEach(sec => sec.style.display = 'none');
        document.getElementById(id).style.display = 'block';
        
        // Update sidebar active state
        document.querySelectorAll('.sidebar button').forEach(btn => btn.classList.remove('active'));
        const activeBtn = document.getElementById('nav-' + id);
        if (activeBtn) activeBtn.classList.add('active');
    }

    /* --- LOGIC DASHBOARD & HEARTBEAT (ĐÃ KHỚP FILE STATUS) --- */
    async function fetchStatus() {

        if (isAdjusting) {
            setTimeout(fetchStatus, 800);
            return;
        }

        try {

            const res = await fetch('status_api.jsp');
            const txt = (await res.text()).trim().toUpperCase();

            const dot = document.getElementById('status-dot');
            const connText = document.getElementById('conn-text');
            const statusDisplay = document.getElementById('status-display');

            // mất kết nối
            if (txt === "LOST CONNECTION") {
                setOfflineUI(dot, connText, statusDisplay);
            }

            // chờ ESP32
            else if (txt.includes("WAITING FOR ESP32")) {
                isConnected = true;
                dot.className = "status-dot online";
                connText.innerText = "SERVER ONLINE - ĐANG ĐỢI ESP32...";
                connText.style.color = "#f59e0b";
            }

            // trạng thái bình thường
            else {

                setOnlineUI(dot, connText);

                // Parse status for D1 and D2
                // Expected format: "D1: XANH, D2: DO" or similar
                let color1 = "", color2 = "";

                if (txt.includes("D1: XANH")) color1 = "GREEN";
                else if (txt.includes("D1: VANG")) color1 = "YELLOW";
                else if (txt.includes("D1: DO")) color1 = "RED";

                if (txt.includes("D2: XANH")) color2 = "GREEN";
                else if (txt.includes("D2: VANG")) color2 = "YELLOW";
                else if (txt.includes("D2: DO")) color2 = "RED";

                // Update UI for Light 1
                if (color1 && color1 !== currentMainColor1) {
                    currentMainColor1 = color1;
                    document.querySelectorAll('[id^="light1-"]').forEach(l => l.classList.remove('active', 'blinking-red'));
                    document.getElementById('light1-' + color1.toLowerCase()).classList.add('active');
                    document.getElementById('status1-display').innerText = color1 + " LIGHT";
                    timeLeft1 = config[color1];
                }

                // Update UI for Light 2
                if (color2 && color2 !== currentMainColor2) {
                    currentMainColor2 = color2;
                    document.querySelectorAll('[id^="light2-"]').forEach(l => l.classList.remove('active', 'blinking-red'));
                    document.getElementById('light2-' + color2.toLowerCase()).classList.add('active');
                    document.getElementById('status2-display').innerText = color2 + " LIGHT";
                    timeLeft2 = config[color2];
                }
            }

        } catch (e) {

            setOfflineUI(
                document.getElementById('status-dot'),
                document.getElementById('conn-text'),
                document.getElementById('status-display')
            );

        }

        // gọi lại sau khi request xong
        setTimeout(fetchStatus, 800);
    }


    function setOfflineUI(dot, connText, statusDisplay) {
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

    /* --- LOGIC CẤU HÌNH & SECURITY GIỮ NGUYÊN --- */
    async function toggleAdjustMode(start) {
        const btnS = document.getElementById('btn-start');
        const btnF = document.getElementById('btn-finish');
        const box = document.getElementById('input-fields');
        if (start) {
            isAdjusting = true;
            btnS.style.display = 'none'; btnF.style.display = 'inline-block';
            box.style.opacity = '1'; box.style.pointerEvents = 'auto';
            await fetch('update_config.jsp?g=0&y=0&r=0');
        } else {
            const gVal = document.getElementById('g').value;
            const yVal = document.getElementById('y').value;
            const rVal = document.getElementById('r').value;
            if (!gVal || !yVal || !rVal) { alert("Vui lòng nhập số!"); return; }
            try {
                console.log("Values send:", gVal, yVal, rVal);  
                const url = "update_config.jsp?g=" + gVal + "&y=" + yVal + "&r=" + rVal + "&t=" + Date.now();
                const res = await fetch(url);


                const txt = await res.text();

                console.log("Server response:", txt);

                if (txt.includes("OK")) {
                    config.GREEN = parseInt(gVal); config.YELLOW = parseInt(yVal); config.RED = parseInt(rVal);
                    timeLeft1 = config[currentMainColor1];
                    timeLeft2 = config[currentMainColor2];

                    isAdjusting = false;
                    btnS.style.display = 'inline-block'; btnF.style.display = 'none';
                    box.style.opacity = '0.5'; box.style.pointerEvents = 'none';
                    alert("Thành công!");
                }
            } catch (e) { alert("Lỗi kết nối!"); }
        }
    }

    function timKiemTheoNgay() {
        const d = document.getElementById('search-date').value;
        document.querySelectorAll('.violation-card').forEach(c => {
            c.style.display = c.getAttribute('data-date').includes(d) ? 'block' : 'none';
        });
    }
    function hienTatCaAnh() { document.querySelectorAll('.violation-card').forEach(c => c.style.display = 'block'); }
    function moAnhPhongTo(src, t, p, vtype, type) {
        document.getElementById('secModalImg').src = src;
        document.getElementById('modalPlate').innerText = p;
        document.getElementById('modalVehicleType').innerText = vtype;
        document.getElementById('modalTime').innerText = t;
        document.getElementById('modalType').innerText = type;
        document.getElementById('secModal').style.display = 'flex';
    }
    function dongAnhPhongTo() { document.getElementById('secModal').style.display = 'none'; }

    function handleLogin() {
        const u = document.getElementById('login-user').value;
        const p = document.getElementById('login-pass').value;
        const isAdmin = (u === "admin" && p === "123");
        const isLocalAdmin = (u === localStorage.getItem('adminUser') && p === localStorage.getItem('adminPass'));
        
        if (isAdmin || isLocalAdmin) {
            document.getElementById('auth-container').style.display = 'none';
            document.getElementById('admin-panel').style.display = 'block';
            fetchStatus();
            setInterval(() => {
                if (!isAdjusting && isConnected) {
                    if (timeLeft1 > 0 && !document.getElementById('light1-red').classList.contains('blinking-red')) {
                        timeLeft1--;
                    }
                    if (timeLeft2 > 0 && !document.getElementById('light2-red').classList.contains('blinking-red')) {
                        timeLeft2--;
                    }
                    document.getElementById('timer1-display').innerText = timeLeft1 + "s";
                    document.getElementById('timer2-display').innerText = timeLeft2 + "s";
                }
            }, 1000);
        } else alert("Sai tài khoản!");
    }
</script>
</body>
</html>