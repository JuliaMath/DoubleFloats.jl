document.addEventListener("DOMContentLoaded", () => {
  const outline = document.querySelector(".docs-sidebar li.is-active > ul.internal");
  const article = document.getElementById("documenter-page");
  if (!outline || !article) return;

  const glossary = article.querySelector("h1#Glossary") !== null;
  const sections = new Map();
  for (const link of outline.querySelectorAll(":scope > li > a[href^='#']")) {
    sections.set(decodeURIComponent(link.hash.slice(1)), link.parentElement);
  }

  let parent;
  let children;
  for (const heading of article.querySelectorAll("h1[id], h2[id], h3[id]")) {
    if (heading.tagName !== "H3") {
      parent = heading.tagName === "H2" ? sections.get(heading.id) : undefined;
      children = undefined;
      continue;
    }
    if (!parent) continue;
    const title = heading.querySelector(":scope > a.docs-heading-anchor");
    if (!title) continue;

    if (!children) {
      children = document.createElement("ul");
      children.className = "docs-subsections";
      if (glossary) {
        const disclosure = document.createElement("details");
        disclosure.className = "docs-glossary-terms";
        const summary = document.createElement("summary");
        const title = document.createElement("em");
        title.textContent = "Terms";
        summary.append(title);
        disclosure.append(summary, children);
        parent.append(disclosure);
      } else {
        parent.append(children);
      }
    }

    const item = document.createElement("li");
    const link = document.createElement("a");
    const label = document.createElement("span");
    link.className = "tocitem";
    link.href = title.getAttribute("href");
    label.append(...Array.from(title.childNodes, node => node.cloneNode(true)));
    link.append(label);
    item.append(link);
    children.append(item);
  }
});
