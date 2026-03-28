const db = require('../config/database');
const { getClientIp } = require('../utils/helpers');

function createOperationLog(options) {
  return async (req, res, next) => {
    // Store original end function
    const originalEnd = res.end;
    const startTime = Date.now();

    res.end = async function(chunk, encoding) {
      // Call original end first
      originalEnd.call(this, chunk, encoding);

      // Only log if user is authenticated and action is specified
      if (req.user && options.action) {
        try {
          await db.createLog({
            user_id: req.user.id,
            action: options.action,
            target_type: options.targetType,
            target_id: req.params.id || null,
            details: options.details || null,
            ip_address: getClientIp(req)
          });
        } catch (err) {
          console.error('Failed to create operation log:', err);
        }
      }
    };

    next();
  };
}

async function logOperation(user, action, targetType, targetId, details, ip) {
  try {
    await db.createLog({
      user_id: user.id,
      action,
      target_type: targetType,
      target_id: targetId,
      details,
      ip_address: ip
    });
  } catch (err) {
    console.error('Failed to create operation log:', err);
  }
}

module.exports = {
  createOperationLog,
  logOperation
};
