<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Traffic Light Portal</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
</head>
<body style="display: flex; justify-content: center; align-items: center; height: 100vh;">

<div class="selection-card">
    <h1 style="margin-bottom: 0.5rem;">🚦 Traffic System</h1>
    <p style="color: var(--text-muted);">Please select your access level</p>

    <div class="role-container">
        <a href="admin" class="role-btn">
            <span style="font-size: 32px; background: #eff6ff; padding: 12px; border-radius: 12px;">👨‍💻</span>
            <div style="text-align: left;">
                <h3>Admin Portal</h3>
                <small>System Settings & Control</small>
            </div>
        </a>

        <a href="user.jsp" class="role-btn">
            <span style="font-size: 32px; background: #f0fdf4; padding: 12px; border-radius: 12px;">🚶</span>
            <div style="text-align: left;">
                <h3>User View</h3>
                <small>Pedestrian View & Request</small>
            </div>
        </a>
    </div>
</div>

</body>
</html>