'use strict';

try {
  if (localStorage.getItem('learning-blog-theme') === 'dark') {
    document.documentElement.dataset.theme = 'dark';
  }
} catch {
  // The preview still works when the browser blocks site storage.
}
