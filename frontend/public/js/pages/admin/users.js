async function loadUsers() {
    try {
        const users = await api.getUsers();
        setState({ users });
        renderUsersTable(users);
    } catch (err) {
        showToast('加载用户列表失败', 'error');
    }
}

function renderUsersTable(users) {
    const tbody = document.getElementById('users-tbody');
    if (!tbody) return;

    tbody.innerHTML = users.map(user => `
        <tr>
            <td>${user.id}</td>
            <td>${user.username}</td>
            <td>${user.role}</td>
            <td>${formatDate(user.created_at)}</td>
            <td>
                <button class="secondary" onclick="editUser(${user.id})">编辑</button>
                ${user.role !== 'admin' ? `<button class="danger" onclick="deleteUser(${user.id})">删除</button>` : ''}
            </td>
        </tr>
    `).join('');
}

async function setupUsersPage() {
    const addBtn = document.getElementById('add-user-btn');
    if (addBtn) {
        addBtn.onclick = async () => {
            const result = await showModal(`
                <div>
                    <input type="text" id="new-username" placeholder="用户名" style="width: 100%; margin-bottom: 12px;">
                    <input type="password" id="new-password" placeholder="密码" style="width: 100%; margin-bottom: 12px;">
                    <select id="new-role" style="width: 100%;">
                        <option value="user">用户</option>
                        <option value="admin">管理员</option>
                    </select>
                </div>
            `, { title: '添加用户' });

            if (result) {
                const username = document.getElementById('new-username').value;
                const password = document.getElementById('new-password').value;
                const role = document.getElementById('new-role').value;

                try {
                    await api.createUser({ username, password, role });
                    showToast('用户创建成功', 'success');
                    await loadUsers();
                } catch (err) {
                    showToast(err.message, 'error');
                }
            }
        };
    }
}

async function editUser(userId) {
    const user = state.users.find(u => u.id === userId);
    if (!user) return;

    const result = await showModal(`
        <div>
            <input type="text" id="edit-username" value="${user.username}" style="width: 100%; margin-bottom: 12px;">
            <input type="password" id="edit-password" placeholder="新密码（留空不修改）" style="width: 100%; margin-bottom: 12px;">
            <select id="edit-role" style="width: 100%;">
                <option value="user" ${user.role === 'user' ? 'selected' : ''}>用户</option>
                <option value="admin" ${user.role === 'admin' ? 'selected' : ''}>管理员</option>
            </select>
        </div>
    `, { title: '编辑用户' });

    if (result) {
        const data = {
            username: document.getElementById('edit-username').value,
            role: document.getElementById('edit-role').value
        };
        const password = document.getElementById('edit-password').value;
        if (password) data.password = password;

        try {
            await api.updateUser(userId, data);
            showToast('用户更新成功', 'success');
            await loadUsers();
        } catch (err) {
            showToast(err.message, 'error');
        }
    }
}

async function deleteUser(userId) {
    const confirmed = await showModal('<p>确定要删除此用户吗？</p>', { title: '确认删除' });
    if (confirmed) {
        try {
            await api.deleteUser(userId);
            showToast('用户删除成功', 'success');
            await loadUsers();
        } catch (err) {
            showToast(err.message, 'error');
        }
    }
}
