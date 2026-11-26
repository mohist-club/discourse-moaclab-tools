import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";

export default class MoaclabViewerController extends Controller {
  queryParams = ["mode", "id", "upload", "url", "ext", "name", "embed", "share"];
  @tracked mode = "";
  @tracked id = "";
  @tracked upload = "";
  @tracked url = "";
  @tracked ext = "";
  @tracked name = "";
  @tracked embed = "";
  @tracked share = "";
}
