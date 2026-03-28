/**
 * Storage abstract interface
 * All storage implementations must implement these methods
 */
class AbstractStorage {
  async uploadFile(fileBuffer, filePath, options = {}) {
    throw new Error('Not implemented');
  }

  async deleteFile(filePath) {
    throw new Error('Not implemented');
  }

  async getFileUrl(filePath, expiresIn = 3600) {
    throw new Error('Not implemented');
  }

  async fileExists(filePath) {
    throw new Error('Not implemented');
  }

  async getFileSize(filePath) {
    throw new Error('Not implemented');
  }

  async listFiles(prefix) {
    throw new Error('Not implemented');
  }
}

module.exports = AbstractStorage;
