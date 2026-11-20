# discourse-moaclab-tools

moaclab.com 的服务端插件：注册 `/typing`、`/viewer` 路由，提供 CAD 模型上传与读取接口，并发布 CAD Viewer 运行时（`public/viewer/`）。配套主题组件是 `discourse-moaclab-typing` 和 `discourse-moaclab-cad-viewer`。

站点级的清单、发布流程和发布记录在私有维护仓库 `mohist-club/Moaclab`（`ops/release.md`、`plugins/README.md`）。本文件只写这个仓库内的开发约定。

## 这是唯一需要 rebuild 的自研代码

主题组件在后台点更新即可上线，这个插件要 `./launcher rebuild app`，站点会短暂停机，出错时所有工具页一起失效。因此：

- 不在生产容器里直接改插件文件。线上工作树必须与 `main` 的某个提交一致。
- 生产操作（SSH、rebuild、rails console、数据库写入）每次都要仓库所有者在当前对话里明确批准。
- 含路由、控制器或存储路径的改动，先在非生产的 Discourse 环境验证，再排期上线。

## 目录

| 路径 | 内容 |
| --- | --- |
| `plugin.rb` | 入口：路由、meta 标签、`ModelsController`（上传与读取） |
| `config/settings.yml` | 站点设置，全部以 `moaclab_` 开头 |
| `config/locales/` | `client.*` 给浏览器，`server.*` 给爬虫；两边文案保持一致，`en` 与 `zh_CN` 同步 |
| `assets/javascripts/discourse/` | Ember 路由与模板 |
| `public/viewer/vNNN/` | CAD Viewer 运行时，按版本分目录的构建产物 |
| `spec/requests/` | 请求测试 |

## 约定

- **运行时是构建产物**：`public/viewer/vNNN/` 不手改。新版本新建目录，同时更新 spec 里的版本路径和 CAD Viewer 组件引用的版本。旧版本目录暂不删除，清理前先确认线上没有页面或缓存仍在引用。
- **上传接口**：`ModelsController#create` 必须保持登录校验、扩展名白名单（`MODEL_EXTENSIONS`）和大小上限（`MAX_MODEL_BYTES`）；`show` 必须校验 ID 格式。改动这三处要补对应的请求测试。
- **用户输入**：文件名经 `safe_model_name` 处理后才能落盘或回显；输出到 HTML 的内容要转义。
- **开关**：`moaclab_tools_enabled` 关闭后插件不应留下副作用。
- 不新增 gem 或 npm 依赖，确有需要先问。

## 检查

CI（`.github/workflows/discourse-plugin.yml`）用 Discourse 官方工作流在最新 Discourse 上跑 `spec/`。本地验证需要 Discourse 开发环境，把本仓库放到 `plugins/` 下：

```sh
LOAD_PLUGINS=1 bin/rspec plugins/discourse-moaclab-tools/spec
```

lint 目前在 CI 中跳过（`skip_linting: true`），原因见工作流文件里的注释。

## 版本与发布

1. 从 `main` 开分支，一个分支只做一件事。
2. 同步更新 `plugin.rb` 的 `version`、`CHANGELOG.md` 和 README 里的版本说明。
3. 推分支，开指向 `main` 的 PR，等 CI 通过。合并由仓库所有者完成。
4. 合并后打 `vX.Y.Z` tag。
5. 上线按维护仓库的 `ops/release.md`「服务端插件」一节执行，完成后在 `plugins/README.md` 更新线上版本和提交。

## 不要做

- 不直接推 `main`，不强制推送。
- 不提交密钥、`app.yml`、备份或用户上传的模型文件。
- 不做任务范围以外的重构。
