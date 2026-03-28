async function loadAdminMaterials() {
    try {
        const filterUser = document.getElementById('filter-user')?.value;
        const materials = await api.getAllMaterials(filterUser ? { userId: filterUser } : {});
        renderAdminMaterialsGrid(materials);
    } catch (err) {
        showToast('加载素材列表失败', 'error');
    }
}

function renderAdminMaterialsGrid(materials) {
    const grid = document.getElementById('admin-materials-grid');
    if (!grid) return;

    if (materials.length === 0) {
        grid.innerHTML = '<div class="empty-state"><p>暂无素材</p></div>';
    } else {
        grid.innerHTML = materials.map(m => renderMaterialCard(m)).join('');
    }
}

async function setupAdminMaterialsPage() {
    // Load users for filter
    try {
        const users = await api.getUsers();
        const select = document.getElementById('filter-user');
        if (select) {
            select.innerHTML = '<option value="">所有用户</option>' +
                users.map(u => `<option value="${u.id}">${u.username}</option>`).join('');
            select.onchange = loadAdminMaterials;
        }
    } catch (err) {
        console.error('Failed to load users for filter:', err);
    }
}
