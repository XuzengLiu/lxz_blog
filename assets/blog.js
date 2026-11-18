'use strict';

const topbar = document.querySelector('.topbar');
function updateTopbar() {
  topbar.classList.toggle('scrolled', window.scrollY > 30);
}
window.addEventListener('scroll', updateTopbar, { passive: true });
updateTopbar();

const menu = document.querySelector('#site-menu');
const menuToggle = document.querySelector('.menu-toggle');
menuToggle.hidden = false;
menu.dataset.collapsed = 'true';
menuToggle.addEventListener('click', () => {
  const opening = menu.dataset.collapsed === 'true';
  menu.dataset.collapsed = String(!opening);
  menuToggle.setAttribute('aria-expanded', String(opening));
  menuToggle.setAttribute('aria-label', opening ? '收起导航' : '展开导航');
});

const themeToggle = document.querySelector('#theme-toggle');
const root = document.documentElement;
function labelTheme() {
  const dark = root.dataset.theme === 'dark';
  const label = dark ? '切换到浅色' : '切换到深色';
  themeToggle.firstElementChild.textContent = dark ? '☀' : '☾';
  themeToggle.setAttribute('aria-label', label);
  themeToggle.title = label;
}
themeToggle.hidden = false;
themeToggle.addEventListener('click', () => {
  root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
  try {
    localStorage.setItem('learning-blog-theme', root.dataset.theme);
  } catch {
    // Theme switching still works on the current page.
  }
  labelTheme();
});
labelTheme();

const searchButton = document.querySelector('#open-search');
const searchDialog = document.querySelector('#search-dialog');
const searchInput = document.querySelector('#search-input');
const searchStatus = document.querySelector('#search-status');
const searchResults = document.querySelector('#search-results');
let searchIndexPromise;

function loadIndex() {
  if (!searchIndexPromise) {
    searchIndexPromise = new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = document.body.dataset.root + 'assets/search-index.js';
      script.onload = () => resolve(window.blogSearchIndex);
      script.onerror = () => {
        script.remove();
        reject(new Error('无法加载搜索索引'));
      };
      document.head.append(script);
    }).catch(error => {
      searchIndexPromise = null;
      throw error;
    });
  }
  return searchIndexPromise;
}

let lastSearch = 0;
async function search() {
  const sequence = ++lastSearch;
  const words = searchInput.value.trim().toLocaleLowerCase().split(/\s+/).filter(Boolean);
  searchResults.replaceChildren();
  if (!words.length) {
    searchStatus.textContent = '输入关键词开始搜索。';
    return;
  }
  searchStatus.textContent = '正在搜索…';
  try {
    const index = await loadIndex();
    if (sequence !== lastSearch) return;
    const matches = index.filter(post => {
      const text = [post.title, post.summary, post.category, ...post.tags, post.text].join(' ').toLocaleLowerCase();
      return words.every(word => text.includes(word));
    });
    searchStatus.textContent = matches.length ? `找到 ${matches.length} 篇文章` : '没有找到相关文章。';
    for (const post of matches) {
      const item = document.createElement('li');
      const link = document.createElement('a');
      link.href = document.body.dataset.root + post.path;
      const title = document.createElement('strong');
      title.textContent = post.title;
      const description = document.createElement('span');
      description.textContent = post.summary;
      link.append(title, description);
      item.append(link);
      searchResults.append(item);
    }
  } catch {
    if (sequence === lastSearch) searchStatus.textContent = '搜索暂时不可用，请重试。';
  }
}

if (typeof searchDialog.showModal === 'function') {
  searchButton.hidden = false;
  searchButton.addEventListener('click', () => {
    searchDialog.showModal();
    searchInput.focus();
  });
  searchInput.addEventListener('input', search);
}

for (const code of document.querySelectorAll('.prose pre > code')) {
  const pre = code.parentElement;
  const wrap = document.createElement('div');
  wrap.className = 'code-wrap';
  pre.before(wrap);
  wrap.append(pre);
  const label = document.createElement('span');
  label.className = 'code-lang';
  label.textContent = code.dataset.language || '代码';
  const button = document.createElement('button');
  button.className = 'copy';
  button.type = 'button';
  button.textContent = '复制代码';
  wrap.append(label, button);
  let timer;
  button.addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(code.textContent);
      button.textContent = '已复制';
    } catch {
      const range = document.createRange();
      range.selectNodeContents(code);
      const selection = window.getSelection();
      selection.removeAllRanges();
      selection.addRange(range);
      button.textContent = '已选中，请手动复制';
    }
    clearTimeout(timer);
    timer = setTimeout(() => { button.textContent = '复制代码'; }, 2200);
  });
}
