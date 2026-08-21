import DiscourseRoute from "discourse/routes/discourse";
import { i18n } from "discourse-i18n";
import { service } from "@ember/service";
import { applyToolMeta } from "../lib/moaclab-tool-meta";

export default class MoaclabViewerRoute extends DiscourseRoute {
  @service siteSettings;

  metaValue(setting, localeKey) {
    return this.siteSettings[setting]?.trim() || i18n(localeKey);
  }

  titleToken() {
    return this.metaValue("moaclab_viewer_meta_title", "discourse_moaclab_tools.viewer_title");
  }

  activate() {
    super.activate(...arguments);
    this.restoreMeta = applyToolMeta({
      description: this.metaValue("moaclab_viewer_meta_description", "discourse_moaclab_tools.viewer_description"),
      keywords: this.metaValue("moaclab_viewer_meta_keywords", "discourse_moaclab_tools.viewer_keywords"),
      path: "/viewer",
    });
  }

  deactivate() {
    this.restoreMeta?.();
    super.deactivate(...arguments);
  }
}
