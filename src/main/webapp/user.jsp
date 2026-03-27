<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Esp32Server.Esp32ServerListener" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard - Smart Traffic</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
</head>
<body style="display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; padding: 20px;">
    <div class="selection-card" style="max-width: 600px;">
        <div class="connection-status">
            <div id="status-dot" class="status-dot"></div>
            <span id="conn-text" style="color:var(--text-muted); font-size: 0.85rem; font-weight: 600;">CONNECTING...</span>
        </div>
        
        <h2 style="margin-bottom: 2rem;">🚦 Pedestrian Traffic Monitor</h2>

        <div class="traffic-container">
            <div class="traffic-box">
                <h3 style="color: var(--text-muted); font-size: 0.9rem; text-transform: uppercase;">Intersection 1</h3>
                <div class="traffic-light">
                    <div id="light1-red" class="light red"></div>
                    <div id="light1-yellow" class="light yellow"></div>
                    <div id="light1-green" class="light green"></div>
                </div>
                <div id="timer1-display" class="timer-val">0s</div>
            </div>

            <div class="traffic-box">
                <h3 style="color: var(--text-muted); font-size: 0.9rem; text-transform: uppercase;">Intersection 2</h3>
                <div class="traffic-light">
                    <div id="light2-red" class="light red"></div>
                    <div id="light2-yellow" class="light yellow"></div>
                    <div id="light2-green" class="light green"></div>
                </div>
                <div id="timer2-display" class="timer-val">0s</div>
            </div>
        </div>

        <div style="display: flex; gap: 10px; margin-top: 2rem; width: 100%;">
            <button onclick="requestCrossing(1)" class="btn-mode btn-primary" style="flex: 1; padding: 1rem; font-size: 1rem; justify-content: center;">
                 ✋ Cross Intersection 1
            </button>
            <button onclick="requestCrossing(2)" class="btn-mode btn-primary" style="flex: 1; padding: 1rem; font-size: 1rem; justify-content: center;">
                 ✋ Cross Intersection 2
            </button>
        </div>
        
        <p id="request-status" style="margin-top: 1rem; color: var(--success); font-weight: 600; display: none;">Request Sent! Please wait for the green light.</p>
    </div>

<script>
    let config = {GREEN: <%= Esp32ServerListener.timeGreen%>, YELLOW: <%= Esp32ServerListener.timeYellow%>, RED: <%= Esp32ServerListener.timeRed%>};
    let timeLeft1 = 0, timeLeft2 = 0;
    let currentMainColor1 = "", currentMainColor2 = "";
    let lastHwTimer = -1;
    let isConnected = false;

    async function fetchStatus() {
        try {
            const res = await fetch('status_api.jsp');
            const rawTxt = (await res.text()).trim().toUpperCase();
            
            // Parts: STATUS | LOCKED | configData | AGE
            const parts = rawTxt.split('|');
            const txt = parts[0];
            const configInfo = parts[2] || "";

            const dot = document.getElementById('status-dot');
            const connText = document.getElementById('conn-text');

            if (txt.includes("LOST CONNECTION") || txt === "") {
                setOfflineUI(dot, connText);
            } else {
                setOnlineUI(dot, connText);

                // Cập nhật cấu hình thời gian nếu có
                if (configInfo) {
                    let c = configInfo.split(',');
                    config.GREEN = parseInt(c[0]);
                    config.YELLOW = parseInt(c[1]);
                    config.RED = config.GREEN + config.YELLOW;
                }

                handleHardwareUpdate(txt);
            }
        } catch (e) {
            console.error("Fetch error:", e);
        }
    }

    let socket;
    function connectWS() {
        const wsUrl = (location.protocol === "https:" ? "wss://" : "ws://") + location.host + "<%=request.getContextPath()%>/traffic";
        socket = new WebSocket(wsUrl);

        socket.onmessage = (event) => {
            const txt = event.data.toUpperCase();
            
            // Hiển thị Online ngay khi có data
            const dot = document.getElementById('status-dot');
            const connText = document.getElementById('conn-text');
            setOnlineUI(dot, connText);

            handleHardwareUpdate(txt);
        };

        socket.onclose = () => {
            setTimeout(connectWS, 2000);
        };
    }

    function handleHardwareUpdate(txt) {
        // Parsing Hardware format: D1: XANH, D2: DO, T:10
        let hwTimer = -1;
        const tMatch = txt.match(/T:(\d+)/);
        if (tMatch) hwTimer = parseInt(tMatch[1]);

        let color1 = "";
        if (txt.includes("D1: XANH")) color1 = "GREEN";
        else if (txt.includes("D1: VANG")) color1 = "YELLOW";
        else if (txt.includes("D1: DO")) color1 = "RED";

        let color2 = "";
        if (txt.includes("D2: XANH")) color2 = "GREEN";
        else if (txt.includes("D2: VANG")) color2 = "YELLOW";
        else if (txt.includes("D2: DO")) color2 = "RED";

        updateLightUI(1, color1, hwTimer);

        // Hướng 2 (Tương quan với hướng 1)
        let t2 = hwTimer;
        if (color1 === "GREEN") t2 = hwTimer + config.YELLOW;
        else if (color1 === "RED") {
            if (hwTimer > config.YELLOW) t2 = hwTimer - config.YELLOW;
            else t2 = hwTimer;
        }
        updateLightUI(2, color2, t2);

        // FORCE UI ngay để số ko bị đứng
        document.getElementById('timer1-display').innerText = hwTimer + "s";
        document.getElementById('timer2-display').innerText = t2 + "s";
    }

    function updateLightUI(idx, color, hwTimer) {
        if (!color) return;
        let currentLocalColor = (idx === 1) ? currentMainColor1 : currentMainColor2;
        let currentLocalTime = (idx === 1) ? timeLeft1 : timeLeft2;

        // Cập nhật Trạng thái & Đèn
        if (color !== currentLocalColor) {
            if (idx === 1) currentMainColor1 = color; else currentMainColor2 = color;
            document.querySelectorAll('[id^="light' + idx + '-"]').forEach(l => l.classList.remove('active'));
            const target = document.getElementById('light' + idx + '-' + color.toLowerCase());
            if (target) target.classList.add('active');
            
            if (idx === 1) timeLeft1 = hwTimer; else timeLeft2 = hwTimer;
        } else {
            // Đồng bộ nếu lệch > 1s
            if (Math.abs(currentLocalTime - hwTimer) > 1) {
                if (idx === 1) timeLeft1 = hwTimer; else timeLeft2 = hwTimer;
            }
        }
    }

    function setOfflineUI(dot, connText) {
        isConnected = false;
        dot.className = "status-dot offline";
        connText.innerText = "DEVICE OFFLINE";
        connText.style.color = "var(--error)";
        document.querySelectorAll('.light').forEach(l => l.classList.remove('active'));
        document.getElementById('timer1-display').innerText = "0s";
        document.getElementById('timer2-display').innerText = "0s";
    }

    function setOnlineUI(dot, connText) {
        isConnected = true;
        dot.className = "status-dot online";
        connText.innerText = "DEVICE ONLINE";
        connText.style.color = "var(--success)";
    }

    async function requestCrossing(direction) {
        const status = document.getElementById('request-status');
        status.style.display = 'block';
        status.style.color = "var(--success)";
        status.innerText = "Sending request for Intersection " + direction + "...";
        try {
            await fetch('status_api.jsp?reqPed=' + direction);
            status.innerText = "Request Sent for Intersection " + direction + "! Wait for pedestrian phase.";
            
            // Tự ẩn thông báo sau 5 giây
            setTimeout(() => {
                status.style.display = 'none';
            }, 5000);
        } catch (e) {
            status.innerText = "Error sending request.";
            status.style.color = "var(--error)";
        }
    }

    fetchStatus();
    connectWS();

    // TINH CHỈNH: Bộ đếm mượt mà (Smooth Ticker)
    // Chỉ giảm số để UI không bị giật (11 -> 8), nhưng tuyệt đối DỪNG Ở 0
    // Không bao giờ tự đổi màu, chờ ESP32 quyết định.
    setInterval(() => {
        if (isConnected) {
            // TINH CHỈNH: Bộ đếm mượt mà (Smooth Ticker)
            // Chỉ giảm số để UI không bị giật, nhưng DỪNG Ở 1S (theo yêu cầu Hardware 1 -> 13)
            // Không bao giờ về 0, chờ ESP32 quyết định chuyển màu.
            if (timeLeft1 > 1) timeLeft1--;
            if (timeLeft2 > 1) timeLeft2--;
            document.getElementById('timer1-display').innerText = timeLeft1 + "s";
            document.getElementById('timer2-display').innerText = timeLeft2 + "s";
        }
    }, 1000);
</script>
</body>
</html>
