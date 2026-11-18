# 研习手记｜新版发帖与上线指南

这是一个用 Markdown 写文章的中文学习博客。首页按日期倒序排列，支持翻页。归档、分类和标签页会从文章自动生成，右上角的搜索会查找全文。示例内容包括 Python 刷题、Agent 开发、后端实践和项目复盘。

## 1. 在本机预览

解压源文件，打开 `learning-blog` 文件夹。Mac 上打开「终端」，输入 `cd `（末尾有一个空格），把这个文件夹从访达拖进终端，按回车。然后运行：

```bash
ruby build.rb
open dist/index.html
```

每次改了文章或站点设置，重新执行 `ruby build.rb` 并刷新浏览器。生成结果放在 `dist/`，预览无需启动服务器。若只想看交付时的样子，可以直接打开随附预览文件夹中的 `index.html`。

## 2. 写第一篇文章

在 `posts/` 新建 `2026-11-17-my-first-note.md`。日期换成你实际写笔记的日期，后面用小写字母、数字和短横线命名。把下面这段复制进去（不复制最外层的四个反引号）：

````markdown
---
title: "我的第一篇学习笔记"
summary: "记录今天学到的一个 Python 小技巧。"
category: "算法笔记"
tags: ["Python", "学习笔记"]
---

## 我遇到了什么问题？

用自己的话写下问题，以及我一开始是怎么想的。

## 我是怎么验证的？

```python
print("Hello, blog!")
```

## 下次我会怎么做？

写一个以后能直接用上的经验。
````

- `title` 是标题；`summary` 在首页和正文开头显示；`category` 是分类，`tags` 是可选的标签列表。分类适合放大方向，标签可以写语言、框架或具体知识点。用相同的分类或标签名，文章就会归到同一组。
- 正文可以使用 Markdown 的小标题、链接、列表、引用和代码块。文章页已显示标题，正文直接从 `##` 开始。这些小标题会自动出现在阅读目录里。
- 要发图，把图片放进 `images/`，例如 `images/bfs-diagram.png`，正文里用 `![队列示意图](../images/bfs-diagram.png)`。图片文件也要提交到 GitHub。
- 改文章直接编辑原文件；删掉它，下次发布时页面也会消失。建议保留已发文章的文件名，别人保存的链接才能继续用。
- 在 `site.yml` 里改博客名、副标题、「关于」和每页文章数。想换风景封面，用自己的 JPG 替换 `assets/banner.jpg`。示例文章可以逐篇替换或删除。

## 3. 第一次挂到 GitHub Pages

### 3.1 上传源码

在博客文件夹的终端里执行一次：

```bash
git init -b main
git add .
git commit -m "初始化学习博客"
```

如果 Git 提示要设置身份，先为这个仓库设置提交名和邮箱，再重试最后一条命令。邮箱可以用 GitHub **Settings → Emails** 显示的 noreply 地址。

```bash
git config user.name "你的名字"
git config user.email "替换为你的提交邮箱"
git commit -m "初始化学习博客"
```

接着用 [GitHub Desktop](https://desktop.github.com/) 登录：

1. 点 **File → Add Local Repository…**，选择解压后的 `learning-blog` 文件夹。
2. 点 **Publish repository**，仓库名填 `learning-blog`。使用 GitHub 免费账号时，取消 **Keep this code private**，让 Pages 能部署。点 **Publish Repository**。仓库和发布内容会公开，请先确认文章和图片都可以给别人看。
3. 打开 GitHub 上的仓库，确认 `posts/` 和 `.github/workflows/pages.yml` 都在。后者负责每次有新内容时生成并更新网站。

**已经会用 Git 命令？** 你也可以在 [GitHub 新建仓库](https://github.com/new)，创建一个空的公开仓库 `learning-blog`（不勾选 README 等初始化选项），登录 GitHub 后，用你的仓库地址执行：

```bash
git remote add origin https://github.com/你的用户名/learning-blog.git
git push -u origin main
```

### 3.2 打开 Pages

1. 去仓库的 **Settings → Pages → Build and deployment**，把 **Source** 设为 **GitHub Actions**。
2. 去 **Actions → 发布学习博客 → Run workflow**，选择 `main`，点运行。首次推送可能在 Pages 启用前触发；设好 Pages 后可以手动再跑一次。
3. 等流程成功，从 **Settings → Pages → Visit site** 打开博客。普通仓库的地址通常是 `https://你的用户名.github.io/learning-blog/`；如果仓库就叫 `你的用户名.github.io`，则是对应的域名根目录。

## 4. 以后发帖最简单的方法：在 GitHub 网页上写

1. 打开你的仓库，切到 `main`，进入 `posts/`。
2. 点 **Add file → Create new file**，填入日期和英文文件名，例如 `2026-11-17-my-first-note.md`。如果你已经在本机写好了，改选 **Upload files**，拖进去即可。
3. 粘贴文章，点 **Commit changes…**。个人仓库可以直接提交到 `main`；如果只允许开 Pull Request，合并到 `main` 后才会上线。
4. **Actions → 发布学习博客** 显示成功后，到博客首页刷新。不要只看仓库里的 Markdown 页面，`github.io` 地址才是你的博客。

如果在本机继续修改，先用 GitHub Desktop 的 **Fetch origin → Pull origin** 同步网页上的提交。改好后在 GitHub Desktop **Commit to main → Push origin**；也可以用 `git add posts/`、`git commit -m "发布新笔记"`、`git push`。加了图片时一并提交 `images/`。

## 5. 常见问题

| 看到的情况 | 先检查什么 |
| --- | --- |
| 仓库里有新文章，博客没有 | 文章是否在 `main` 的 `posts/` 里；再看 **Actions** 最近一次运行。 |
| 提示「无法生成文章」 | 查看构建日志中报错的文件名。检查日期、`.md` 后缀、上下两行 `---`，以及有没有漏填标题、摘要或分类。若填了 `tags`，用 `["标签一", "标签二"]` 这样的列表。 |
| 首次访问是 404 | 确认 Pages 来源为 **GitHub Actions**，发布流程已经成功，并用 **Visit site** 给出的地址。 |
| 图片不显示 | 检查文件是否已提交进 `images/`，正文是否写了 `../images/`，扩展名和大小写要一致。 |

参考：[GitHub Pages 快速入门](https://docs.github.com/en/pages/quickstart) · [配置发布来源](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site) · [将本地代码上传到 GitHub](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github)

页面布局参考 [Hexo Fluid 的官方演示](https://hexo.fluid-dev.com/)，风景封面为生成图片。
