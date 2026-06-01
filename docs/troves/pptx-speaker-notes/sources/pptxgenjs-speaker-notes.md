# PptxGenJS Speaker Notes API

Source: https://gitbrent.github.io/PptxGenJS/docs/speaker-notes/

## API

`slide.addNotes('TEXT')` adds speaker notes to any slide.

## Example

```javascript
let pres = new PptxGenJS();
let slide = pptx.addSlide();
slide.addText('Hello World!', { x:1.5, y:1.5, fontSize:18, color:'363636' });
slide.addNotes('This is my favorite slide!');
pptx.writeFile('Sample Speaker Notes');
```

## Constraints

- `addNotes` accepts a plain string only (not an array of objects or rich text)
- Issue #941 reports that passing arrays causes `[object Object]` in the notes field
- The `addNotes` method signature is `addNotes(notes: string): Slide`