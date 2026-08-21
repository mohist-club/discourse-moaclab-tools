function setMeta(name, content) {
  let node = document.head.querySelector(`meta[name="${name}"]`);
  const created = !node;
  const previous = node?.getAttribute("content");
  if (!node) {
    node = document.createElement("meta");
    node.setAttribute("name", name);
    document.head.appendChild(node);
  }
  node.setAttribute("content", content);
  return () => created ? node.remove() : node.setAttribute("content", previous || "");
}

function setCanonical(path) {
  let node = document.head.querySelector('link[rel="canonical"]');
  const created = !node;
  const previous = node?.getAttribute("href");
  if (!node) {
    node = document.createElement("link");
    node.setAttribute("rel", "canonical");
    document.head.appendChild(node);
  }
  node.setAttribute("href", new URL(path, window.location.origin).href);
  return () => created ? node.remove() : node.setAttribute("href", previous || window.location.origin);
}

export function applyToolMeta({ description, keywords, path }) {
  const restore = [setMeta("description", description), setMeta("keywords", keywords), setCanonical(path)];
  return () => restore.reverse().forEach((callback) => callback());
}
