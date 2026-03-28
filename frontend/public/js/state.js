const state = {
    isLoggedIn: false,
    currentUser: null,
    currentFolder: 'images',
    isTrashView: false,
    materials: [],
    selectedMaterialIds: new Set(),
    isSelectMode: false,
    adminPage: 'dashboard',
    users: [],
    logs: [],
    backups: []
};

const listeners = new Set();

function setState(updates) {
    Object.assign(state, updates);
    listeners.forEach(fn => fn(state));
}

function subscribe(fn) {
    listeners.add(fn);
    return () => listeners.delete(fn);
}

function formatFileSize(bytes) {
    if (!bytes) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function formatDate(dateStr) {
    return new Date(dateStr).toLocaleString('zh-CN');
}
