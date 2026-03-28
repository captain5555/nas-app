async function loadDashboard() {
    try {
        const stats = await api.getStats();
        document.getElementById('stat-users').textContent = stats.userCount;
        document.getElementById('stat-files').textContent = stats.totalFiles;
        document.getElementById('stat-storage').textContent = formatFileSize(stats.totalSize);
    } catch (err) {
        showToast('加载统计数据失败', 'error');
    }
}
