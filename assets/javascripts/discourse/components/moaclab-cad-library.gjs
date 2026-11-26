import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { ajax } from "discourse/lib/ajax";
import DButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";
import i18n from "discourse/helpers/i18n";

export default class CadLibrary extends Component {
  @tracked drawings = [];
  @tracked loading = true;
  @tracked failed = false;
  @tracked query = "";
  @tracked format = "";
  @tracked nextBefore = null;
  requestId = 0;
  formats = ["STEP", "STP", "IGES", "IGS", "DXF", "DWG", "GLB", "GLTF", "STL", "OBJ"];

  constructor() {
    super(...arguments);
    this.load();
  }

  async load(append = false) {
    const request = ++this.requestId;
    this.loading = true;
    this.failed = false;
    try {
      const data = await ajax("/moaclab-cad/drawings.json", {
        data: { q: this.query, format_filter: this.format, before: append ? this.nextBefore : null },
      });
      if (this.isDestroying || this.isDestroyed || request !== this.requestId) { return; }
      this.drawings = append ? [...this.drawings, ...data.drawings] : data.drawings;
      this.nextBefore = data.next_before;
    } catch {
      if (!this.isDestroying && !this.isDestroyed && request === this.requestId) { this.failed = true; }
    } finally {
      if (!this.isDestroying && !this.isDestroyed && request === this.requestId) { this.loading = false; }
    }
  }

  @action search(event) {
    event.preventDefault();
    this.drawings = [];
    this.nextBefore = null;
    this.load();
  }
  @action updateQuery(event) { this.query = event.target.value; }
  @action updateFormat(event) { this.format = event.target.value; this.search(event); }
  @action more() { this.load(true); }
  @action retry() { this.load(this.drawings.length > 0); }

  <template>
    <section class="moaclab-cad-library" aria-labelledby="cad-library-title">
      <header class="moaclab-cad-library__heading">
        <div><h1 id="cad-library-title">{{i18n "discourse_moaclab_tools.library.title"}}</h1></div>
        <div class="moaclab-cad-library__actions">
          <a class="btn btn-default" href="/viewer?mode=preview">{{icon "cube"}}{{i18n "discourse_moaclab_tools.library.local"}}</a>
          <a class="btn btn-primary" href="/viewer?mode=preview&share=1">{{icon "upload"}}{{i18n "discourse_moaclab_tools.library.upload"}}</a>
        </div>
      </header>
      <form class="moaclab-cad-library__filters" {{on "submit" this.search}}>
        <div class="moaclab-cad-library__search">
          <label class="sr-only" for="cad-library-query">{{i18n "discourse_moaclab_tools.library.search"}}</label>
          <input id="cad-library-query" type="search" value={{this.query}} placeholder={{i18n "discourse_moaclab_tools.library.search"}} {{on "input" this.updateQuery}} />
          <DButton @type="submit" @icon="magnifying-glass" @title="discourse_moaclab_tools.library.search" />
        </div>
        <label class="sr-only" for="cad-library-format">{{i18n "discourse_moaclab_tools.library.format"}}</label>
        <select id="cad-library-format" {{on "change" this.updateFormat}}>
          <option value="">{{i18n "discourse_moaclab_tools.library.all_formats"}}</option>
          {{#each this.formats as |format|}}<option value={{format}}>{{format}}</option>{{/each}}
        </select>
      </form>
      <div class="moaclab-cad-library__grid" aria-busy={{this.loading}}>
        {{#each this.drawings key="id" as |drawing|}}
          <article class="moaclab-cad-library__card">
            <a class="moaclab-cad-library__image" href={{drawing.topic_url}} aria-label={{drawing.title}}>
              {{#if drawing.image_url}}<img src={{drawing.image_url}} alt="" loading="lazy" />{{else}}{{icon "cube"}}{{/if}}
              {{#if drawing.format}}<span class="moaclab-cad-library__format">{{drawing.format}}</span>{{/if}}
            </a>
            <div class="moaclab-cad-library__body">
              <h2><a href={{drawing.topic_url}}>{{drawing.title}}</a></h2>
              <p class="moaclab-cad-library__byline">{{drawing.username}}<span>{{drawing.replies}} {{i18n "discourse_moaclab_tools.library.replies"}}</span></p>
              <div class="moaclab-cad-library__card-actions">
                <a href={{drawing.topic_url}}>{{i18n "discourse_moaclab_tools.library.details"}}</a>
                {{#if drawing.preview_url}}<a class="btn btn-default" href={{drawing.preview_url}}>{{icon "cube"}}{{i18n "discourse_moaclab_tools.library.preview"}}</a>{{/if}}
              </div>
            </div>
          </article>
        {{/each}}
      </div>
      <div class="moaclab-cad-library__status" role="status" aria-live="polite">
        {{#if this.loading}}
          {{i18n "discourse_moaclab_tools.library.loading"}}
        {{else if this.failed}}
          <p>{{i18n "discourse_moaclab_tools.library.error"}}</p>
          <DButton @action={{this.retry}} @icon="rotate-right" @label="discourse_moaclab_tools.library.retry" />
        {{else if this.nextBefore}}
          <DButton @action={{this.more}} @label="discourse_moaclab_tools.library.more" />
        {{else if this.drawings.length}}{{else}}
          <p>{{i18n "discourse_moaclab_tools.library.empty"}}</p>
        {{/if}}
      </div>
    </section>
  </template>
}
