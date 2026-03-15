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

        <button onclick="requestCrossing()" class="btn-mode btn-primary" style="padding: 1rem 2rem; font-size: 1.1rem; margin-top: 2rem; width: 100%; justify-content: center;">
             ✋ Request Pedestrian Crossing
        </button>
        
        <p id="request-status" style="margin-top: 1rem; color: var(--success); font-weight: 600; display: none;">Request Sent! Please wait for the green light.</p>
    </div>

<script>
    let config = {GREEN: <%= Esp32ServerListener.timeGreen%>, YELLOW: <%= Esp32ServerListener.timeYellow%>, RED: <%= Esp32ServerListener.timeRed%>};
    let timeLeft1 = 0, timeLeft2 = 0;
    let currentMainColor1 = "", currentMainColor2 = "";

    async function fetchStatus() {
        try {
            const res = await fetch('status_api.jsp');
            const txt = (await res.text()).trim().toUpperCase();
            const dot = document.getElementById('status-dot');
            const connText = document.getElementById('conn-text');

            if (txt === "LOST CONNECTION") {
                dot.className = "status-dot offline";
                connText.innerText = "DEVICE OFFLINE";
                connText.style.color = "var(--error)";
            } else if (txt.includes("WAITING FOR ESP32")) {
                dot.className = "status-dot online";
                connText.innerText = "WAITING FOR ESP32...";
                connText.style.color = "var(--warning)";
            } else {
                dot.className = "status-dot online";
                connText.innerText = "DEVICE ONLINE";
                connText.style.color = "var(--success)";

                let color1 = "", color2 = "";
                if (txt.includes("D1: XANH")) color1 = "GREEN";
                else if (txt.includes("D1: VANG")) color1 = "YELLOW";
                else if (txt.includes("D1: DO")) color1 = "RED";

                if (txt.includes("D2: XANH")) color2 = "GREEN";
                else if (txt.includes("D2: VANG")) color2 = "YELLOW";
                else if (txt.includes("D2: DO")) color2 = "RED";

                if (color1 && color1 !== currentMainColor1) {
                    currentMainColor1 = color1;
                    document.querySelectorAll('[id^="light1-"]').forEach(l => l.classList.remove('active'));
                    document.getElementById('light1-' + color1.toLowerCase()).classList.add('active');
                    timeLeft1 = config[color1];
                }
                if (color2 && color2 !== currentMainColor2) {
                    currentMainColor2 = color2;
                    document.querySelectorAll('[id^="light2-"]').forEach(l => l.classList.remove('active'));
                    document.getElementById('light2-' + color2.toLowerCase()).classList.add('active');
                    timeLeft2 = config[color2];
                }
            }
        } catch (e) {}
        setTimeout(fetchStatus, 1000);
    }

    async function requestCrossing() {
        const status = document.getElementById('request-status');
        status.style.display = 'block';
        status.innerText = "Sending request...";
        try {
            // Placeholder for crossing request logic
            // await fetch('request_crossing_api.jsp'); 
            setTimeout(() => {
                status.innerText = "Request Sent! Please wait for the green light.";
            }, 1000);
        } catch (e) {
            status.innerText = "Error sending request.";
            status.style.color = "var(--error)";
        }
    }

    fetchStatus();
    setInterval(() => {
        if (timeLeft1 > 0) timeLeft1--;
        if (timeLeft2 > 0) timeLeft2--;
        document.getElementById('timer1-display').innerText = timeLeft1 + "s";
        document.getElementById('timer2-display').innerText = timeLeft2 + "s";
    }, 1000);
</script>
</body>
</html>
