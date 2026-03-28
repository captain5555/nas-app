async function loadBackups() {
    try {
        const backups = await api.getBackups();
        setState({ backups });
        renderBackupsTable(backups);
    } catch (err) {
        showToast('加载备份列表失败', 'error');
    }
}

function renderBackupsTable(backups) {
    const tbody = document.getElementById('backups-tbody');
    if (!tbody) return;

    tbody.innerHTML = backups.map(backup => `
        <tr>
            <td>${formatDate(backup.createdAt)}</td>
            <td>${formatFileSize(backup.size)}</td>
            <td>
                <button class="secondary" onclick="downloadBackup('${backup.id}')">下载</button>
                <button class="danger" onclick="deleteBackup('${backup.id}')">删除</button>
            </td>
        </tr>
    `).join('');
}

async function setupBackupsPage() {
    const createBtn = document.getElementById('create-backup-btn');
    if (createBtn) {
        createBtn.onclick = async () => {
            try {
                showToast('正在创建备份...', 'info');
                await api.createBackup();
                showToast('备份创建成功', 'success');
                await loadBackups();
            } catch (err) {
                showToast('备份创建失败', 'error');
            }
        };
    }
}

function downloadBackup(backupId) {
    window.location.href = `/api/admin/backups/${backupId}/download`;
}

async function deleteBackup(backupId) {
    const confirmed = await showModal('<p>确定要删除此备份吗？</p>', { title: '确认删除' });
    if (confirmed) {
        try {
            await api.deleteBackup(backupId);
            showToast('备份删除成功', 'success');
            await loadBackups();
        } catch (err) {
            showToast(err.message, 'error');
        }
    }
}
