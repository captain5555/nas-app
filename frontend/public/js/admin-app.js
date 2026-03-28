document.addEventListener('DOMContentLoaded', async () => {
    // Check auth
    const token = api.getToken();
    if (!token) {
        window.location.href = '/';
        return;
    }

    try {
        const user = await api.getMe();
        if (user.role !== 'admin') {
            window.location.href = '/';
            return;
        }
        setState({ currentUser: user });
        document.getElementById('user-info').textContent = user.username;
    } catch (err) {
        window.location.href = '/';
        return;
    }

    // Setup navigation
    const sidebarItems = document.querySelectorAll('.sidebar-item');
    sidebarItems.forEach(item => {
        item.onclick = async () => {
            sidebarItems.forEach(i => i.classList.remove('active'));
            item.classList.add('active');

            const page = item.dataset.page;
            setState({ adminPage: page });

            // Update title
            document.getElementById('page-title').textContent = item.textContent;

            // Hide all pages
            document.querySelectorAll('.admin-page').forEach(p => p.classList.add('hidden'));

            // Show selected page
            const pageEl = document.getElementById(`${page}-page`);
            if (pageEl) pageEl.classList.remove('hidden');

            // Load page data
            await loadAdminPage(page);
        };
    });

    // Setup pages
    await setupUsersPage();
    await setupAdminMaterialsPage();
    await setupBackupsPage();

    // Load initial page
    await loadAdminPage('dashboard');

    // Logout button
    document.getElementById('logout-btn').onclick = async () => {
        try {
            await api.logout();
        } catch (err) {
            // Ignore
        }
        api.setToken(null);
        window.location.href = '/';
    };
});

async function loadAdminPage(page) {
    switch (page) {
        case 'dashboard':
            await loadDashboard();
            break;
        case 'users':
            await loadUsers();
            break;
        case 'materials':
            await loadAdminMaterials();
            break;
        case 'logs':
            await loadLogs();
            break;
        case 'backups':
            await loadBackups();
            break;
    }
}
