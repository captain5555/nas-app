const { sendError } = require('../utils/helpers');

function requireRole(role) {
  return (req, res, next) => {
    if (!req.user) {
      return sendError(res, 'Authentication required', 401);
    }

    if (req.user.role !== role && req.user.role !== 'admin') {
      return sendError(res, 'Permission denied', 403);
    }

    next();
  };
}

function isAdmin(req) {
  return req.user && req.user.role === 'admin';
}

function canAccessUser(req, targetUserId) {
  if (!req.user) return false;
  if (isAdmin(req)) return true;
  return req.user.id === targetUserId;
}

function canAccessMaterial(req, material) {
  if (!req.user) return false;
  if (isAdmin(req)) return true;
  return req.user.id === material.user_id;
}

module.exports = {
  requireRole,
  isAdmin,
  canAccessUser,
  canAccessMaterial
};
