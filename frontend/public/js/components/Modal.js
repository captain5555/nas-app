const Modal = {
  show(options) {
    const container = document.getElementById('modal-container');
    const { title, content, footer, onMount } = options;

    container.innerHTML = `
      <div class="modal-content">
        ${title ? `
          <div class="modal-header">
            <h3>${title}</h3>
            <button class="modal-close">&times;</button>
          </div>
        ` : ''}
        <div class="modal-body">${content}</div>
        ${footer !== undefined ? `
          <div class="modal-footer">${footer}</div>
        ` : ''}
      </div>
    `;

    container.classList.remove('hidden');

    // Bind close events
    const closeBtn = container.querySelector('.modal-close');
    if (closeBtn) {
      closeBtn.onclick = () => this.hide();
    }
    container.onclick = (e) => {
      if (e.target === container) this.hide();
    };

    // Call onMount callback if provided
    if (onMount) {
      setTimeout(onMount, 0);
    }
  },

  hide() {
    document.getElementById('modal-container').classList.add('hidden');
  }
};
