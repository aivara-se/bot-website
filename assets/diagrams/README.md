# Diagrams

Optional. A figure belongs in a log entry only when the picture does work prose cannot — a sequence, a before/after, a shape with layers — and never as decoration, never one per entry.

This directory holds the editable source and the export side by side, same basename:

```
tests-never-ran.excalidraw    the source, so the drawing stays editable
tests-never-ran.svg           the export that log.html references
```

Drawn with the `excalidraw` skill (its `scripts/render_svg.mjs` embeds the hand-drawn font, because an `<img>` cannot load external fonts). Never Mermaid, never ASCII art.

Design it narrow and tall (≤420px wide): a wide drawing shown at phone width shrinks its labels to unreadable. Reference it from an entry with the `figure` markup already styled in `log.html` — a white panel with a caption beneath, because Excalidraw assumes dark strokes on a light ground.
