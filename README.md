# Atlas

Atlas 是一个面向设计师的个人视觉参考与能力收藏库。它可以保存图片、链接、设计项目、AI 生图参考、Prompt、工具、技能和方法，并通过分类、标签和搜索慢慢整理成自己的资料库。

## 现在有两种使用模式

### 本地模式

直接打开 `index.html` 即可使用。没有配置 Supabase 时，收藏会保存在当前浏览器的 `localStorage` 中，支持图片粘贴、拖拽、导出和导入 JSON。

### 云端模式

登录后，收藏记录保存到 Supabase 数据库，本地上传的图片保存到 Supabase Storage。这样同一个账号可以在手机、电脑和不同浏览器之间访问同一套收藏。

GitHub Pages 只负责托管前端页面，不保存用户的素材。每个账号通过 RLS（Row Level Security）只能读取和修改自己的数据。

## 配置 Supabase

1. 创建一个 Supabase 项目。
2. 打开 Supabase 的 SQL Editor，完整执行 [`supabase/schema.sql`](./supabase/schema.sql)。这个脚本会创建 `library_items` 表、RLS 权限，以及私有的 `atlas-assets` 图片 bucket。
3. 复制 `supabase-config.example.js`，重命名为 `supabase-config.js`。
4. 打开 `supabase-config.js`，填入 Supabase Project URL 和 publishable key（旧项目也可能显示为 anon key）：

```js
window.ATLAS_SUPABASE_CONFIG = {
  url: 'https://你的项目.supabase.co',
  key: '你的_publishable_或_anon_key'
};
```

5. 本地预览时，和 `index.html` 放在同一目录下；发布到 GitHub 时，将这个文件一起部署。

`publishable/anon key` 可以出现在前端，但绝对不要把 `service_role key` 写入这个项目。真正的安全边界由数据库 RLS 和 Storage policies 提供。

## 登录设置

在 Supabase 的 **Authentication → Providers** 中开启 Email。可以使用邮箱密码，也可以使用魔法链接。若开启了邮箱确认，注册后需要先去邮箱点击确认链接。

## 发布到 GitHub Pages

1. 将项目推送到 GitHub 仓库的 `main` 分支。
2. 在仓库的 **Settings → Secrets and variables → Actions → Variables** 中添加：
   - `ATLAS_SUPABASE_URL`
   - `ATLAS_SUPABASE_KEY`
3. 当前静态页面会直接读取 `supabase-config.js`。如果仓库是公开的，建议不要把真实配置文件提交进仓库，而是在 GitHub Actions 中生成它，或者使用私有仓库。
4. 在仓库的 **Settings → Pages** 中将发布来源设为 **GitHub Actions**。

本项目的 `pages.yml` 会发布根目录的 `index.html` 和静态资源。GitHub Pages 地址通常是：

`https://你的用户名.github.io/仓库名/`

## 图片保存说明

- 通过上传、拖拽或粘贴加入的图片，会在登录后上传到私有 `atlas-assets` bucket，数据库只保存图片路径。
- 页面打开时会为私有图片生成临时 signed URL，所以图片不会公开暴露。
- 通过链接自动读取到的第三方封面，受原网站跨域和防盗链限制，当前会保存来源 URL；如果希望永久保留，建议在分析后点击“只用封面”确认，再将图片下载或复制粘贴到上传区域。
- 删除收藏时会同时删除对应的云端记录和上传图片。

## 数据迁移

未登录时可以使用“导出”得到 `atlas-library.json`。登录后可以在“账号与同步”里选择“上传本地收藏”，把当前浏览器里未同步的收藏合并到云端。
