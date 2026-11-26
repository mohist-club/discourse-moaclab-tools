import CadLibrary from "../components/moaclab-cad-library";

<template>
  {{#if @model.preview}}
    <div class="moaclab-tool-route-placeholder" data-moaclab-tool-route="viewer"></div>
  {{else}}
    <CadLibrary />
  {{/if}}
</template>
