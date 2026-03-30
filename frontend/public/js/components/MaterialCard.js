const MaterialCard = {
  render(material, isSelected = false) {
    const thumbnailUrl = material.thumbnail_path || material.file_url || '';
    const isVideo = material.folder_type === 'videos' || material.file_type?.startsWith('video');

    return `
      <div class="material-card ${isSelected ? 'selected' : ''}" data-id="${material.id}">
        <div class="material-thumbnail-container">
          ${isVideo ? '<span class="video-indicator">视频</span>' : ''}
          <img class="material-thumbnail" src="${thumbnailUrl}" alt="${material.file_name || material.title}" onerror="this.style.display='none'">
        </div>
        <div class="material-info">
          <div class="material-name" title="${material.file_name || material.title}">${material.title || material.file_name}</div>
          <div class="material-size">${State.formatFileSize ? State.formatFileSize(material.file_size) : ''}</div>
        </div>
      </div>
    `;
  }
};
