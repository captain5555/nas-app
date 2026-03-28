const express = require('express');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { canAccessUser, isAdmin } = require('../middleware/permission');
const { asyncHandler, sendSuccess, sendError, getClientIp } = require('../utils/helpers');
const { logOperation } = require('../middleware/logger');

const router = express.Router();

// Get user folders
router.get('/user/:userId', authenticateToken, asyncHandler(async (req, res) => {
  const userId = parseInt(req.params.userId);

  if (!canAccessUser(req, userId)) {
    return sendError(res, 'Permission denied', 403);
  }

  const folders = await db.getFolders(userId);
  sendSuccess(res, folders);
}));

// Create folder
router.post('/', authenticateToken, asyncHandler(async (req, res) => {
  const { folderType, name } = req.body;

  if (!folderType || !name) {
    return sendError(res, 'Folder type and name are required');
  }

  const folder = await db.createFolder(req.user.id, folderType, name);

  await logOperation(
    req.user,
    'create_folder',
    'folder',
    folder.id,
    name,
    getClientIp(req)
  );

  sendSuccess(res, folder);
}));

// Update folder
router.put('/:id', authenticateToken, asyncHandler(async (req, res) => {
  const folderId = parseInt(req.params.id);
  const { name } = req.body;

  if (!name) {
    return sendError(res, 'Name is required');
  }

  // Get folder to check ownership
  const folders = await db.getFolders(req.user.id);
  const folder = folders.find(f => f.id === folderId);

  if (!folder && !isAdmin(req)) {
    return sendError(res, 'Permission denied', 403);
  }

  const updated = await db.updateFolder(folderId, name);

  await logOperation(
    req.user,
    'update_folder',
    'folder',
    folderId,
    null,
    getClientIp(req)
  );

  sendSuccess(res, updated);
}));

// Delete folder
router.delete('/:id', authenticateToken, asyncHandler(async (req, res) => {
  const folderId = parseInt(req.params.id);

  // Get folder to check ownership
  const folders = await db.getFolders(req.user.id);
  const folder = folders.find(f => f.id === folderId);

  if (!folder && !isAdmin(req)) {
    return sendError(res, 'Permission denied', 403);
  }

  const result = await db.deleteFolder(folderId);

  await logOperation(
    req.user,
    'delete_folder',
    'folder',
    folderId,
    null,
    getClientIp(req)
  );

  sendSuccess(res, result);
}));

module.exports = router;
