const fs = require('fs');
const path = require('path');
const AbstractStorage = require('./abstract');
const sharp = require('sharp');

class LocalStorage extends AbstractStorage {
  constructor() {
    super();
    this.basePath = path.join(__dirname, '../../data/uploads');
    this.ensureBasePath();
  }

  ensureBasePath() {
    ['', 'images', 'videos', 'others', 'thumbnails'].forEach(dir => {
      const dirPath = path.join(this.basePath, dir);
      if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
      }
    });
  }

  async uploadFile(fileBuffer, filePath, options = {}) {
    const fullPath = path.join(this.basePath, filePath);
    const dir = path.dirname(fullPath);

    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    fs.writeFileSync(fullPath, fileBuffer);

    // Generate thumbnail for images
    let thumbnailPath = null;
    if (options.generateThumbnail && options.isImage) {
      thumbnailPath = await this.generateThumbnail(fileBuffer, filePath);
    }

    return {
      path: filePath,
      thumbnailPath,
      size: fileBuffer.length
    };
  }

  async generateThumbnail(fileBuffer, originalPath) {
    const ext = path.extname(originalPath);
    const baseName = path.basename(originalPath, ext);
    const thumbnailName = `${baseName}_thumb.jpg`;
    const thumbnailPath = path.join('thumbnails', thumbnailName);
    const fullThumbnailPath = path.join(this.basePath, thumbnailPath);

    try {
      await sharp(fileBuffer)
        .resize(200, 200, { fit: 'cover' })
        .jpeg({ quality: 80 })
        .toFile(fullThumbnailPath);

      return thumbnailPath;
    } catch (err) {
      console.error('Thumbnail generation failed:', err);
      return null;
    }
  }

  async deleteFile(filePath) {
    const fullPath = path.join(this.basePath, filePath);
    if (fs.existsSync(fullPath)) {
      fs.unlinkSync(fullPath);
      return true;
    }
    return false;
  }

  async getFileUrl(filePath, expiresIn = 3600) {
    // For local storage, return a relative URL
    return `/uploads/${filePath}`;
  }

  async fileExists(filePath) {
    const fullPath = path.join(this.basePath, filePath);
    return fs.existsSync(fullPath);
  }

  async getFileSize(filePath) {
    const fullPath = path.join(this.basePath, filePath);
    if (fs.existsSync(fullPath)) {
      return fs.statSync(fullPath).size;
    }
    return 0;
  }

  async listFiles(prefix) {
    const dirPath = path.join(this.basePath, prefix);
    if (!fs.existsSync(dirPath)) {
      return [];
    }

    const files = fs.readdirSync(dirPath);
    return files.map(f => path.join(prefix, f));
  }

  getAbsolutePath(filePath) {
    return path.join(this.basePath, filePath);
  }
}

module.exports = new LocalStorage();
