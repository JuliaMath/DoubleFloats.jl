document.addEventListener("DOMContentLoaded", () => {
  const article = document.getElementById("documenter-page");
  const definitions = globalThis.doubleFloatsGlossary;
  if (!article || !definitions) return;

  const tooltip = document.createElement("div");
  tooltip.id = "docs-glossary-tooltip";
  tooltip.className = "docs-glossary-tooltip";
  tooltip.setAttribute("role", "tooltip");
  tooltip.hidden = true;
  document.body.append(tooltip);

  let active;
  let hovered;
  let focused;

  function hide() {
    tooltip.hidden = true;
    if (active) active.removeAttribute("aria-describedby");
    active = undefined;
  }

  function position() {
    if (!active) return;
    const rect = active.getBoundingClientRect();
    if (rect.bottom < 0 || rect.top > window.innerHeight) {
      hide();
      return;
    }
    const gap = 8;
    const width = tooltip.offsetWidth;
    const height = tooltip.offsetHeight;
    const left = rect.left + (rect.width - width) / 2;
    const above = rect.top - height - gap;
    tooltip.style.left = `${Math.max(gap, Math.min(left, window.innerWidth - width - gap))}px`;
    tooltip.style.top = `${above >= gap ? above : Math.min(rect.bottom + gap, window.innerHeight - height - gap)}px`;
  }

  function show(link) {
    if (active !== link) {
      hide();
      if (!link) return;
      active = link;
      tooltip.innerHTML = definitions[link.hash.slice(1)];
      link.setAttribute("aria-describedby", tooltip.id);
      tooltip.hidden = false;
    }
    position();
  }

  for (const link of article.querySelectorAll("a[href*='#glossary-']")) {
    if (!/(?:^|\/)glossary(?:\.html|\/(?:index\.html)?|)$/.test(link.pathname) ||
        !Object.hasOwn(definitions, link.hash.slice(1))) continue;
    link.addEventListener("pointerenter", event => {
      if (event.pointerType === "touch") return;
      hovered = link;
      show(link);
    });
    link.addEventListener("pointerleave", () => {
      if (hovered === link) hovered = undefined;
      show(hovered || focused);
    });
    link.addEventListener("focus", () => {
      if (link.matches(":focus-visible")) {
        focused = link;
        show(link);
      }
    });
    link.addEventListener("blur", () => {
      if (focused === link) focused = undefined;
      show(hovered || focused);
    });
  }

  document.addEventListener("keydown", event => {
    if (event.key === "Escape" && active) {
      hovered = focused = undefined;
      hide();
    }
  });
  window.addEventListener("scroll", position, {passive: true, capture: true});
  window.addEventListener("resize", position);
});
