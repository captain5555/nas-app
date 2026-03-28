function getClientIp(req) {
  return req.ip ||
    req.connection?.remoteAddress ||
    req.socket?.remoteAddress ||
    req.connection?.socket?.remoteAddress ||
    'unknown';
}

function formatDate(date) {
  return new Date(date).toISOString();
}

function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

function sendSuccess(res, data, status = 200) {
  res.status(status).json({ success: true, data });
}

function sendError(res, message, status = 400) {
  res.status(status).json({ success: false, error: message });
}

module.exports = {
  getClientIp,
  formatDate,
  asyncHandler,
  sendSuccess,
  sendError
};
