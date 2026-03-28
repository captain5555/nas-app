async function loadLogs() {
    try {
        const logs = await api.getLogs();
        setState({ logs });
        renderLogsTable(logs);
    } catch (err) {
        showToast('加载日志失败', 'error');
    }
}

function renderLogsTable(logs) {
    const tbody = document.getElementById('logs-tbody');
    if (!tbody) return;

    tbody.innerHTML = logs.map(log => `
        <tr>
            <td>${formatDate(log.created_at)}</td>
            <td>${log.user_id || '-'}</td>
            <td>${log.action}</td>
            <td>${log.ip_address || '-'}</td>
        </tr>
    `).join('');
}
