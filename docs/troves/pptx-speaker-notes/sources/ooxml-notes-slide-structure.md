# OOXML Notes Slide Structure

Source: Project schemas (pml.xsd) and validation code (pptx.py)

## Key XML Files

- `ppt/notesSlides/notesSlide{N}.xml` — Speaker notes content per slide
- `ppt/notesMasters/notesMaster1.xml` — Notes master (theming for notes slides)
- `ppt/notesMasters/_rels/notesMaster1.xml.rels` — Notes master relationships

## NotesSlide XML Structure

```xml
<p:notes xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
         xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
  <p:cSld name="Notes Slide 1">
    <p:spTree>
      <p:nvGrpSpPr>
        <p:cNvPr id="1" name=""/>
        <p:cNvGrpSpPr/>
        <p:nvPr/>
      </p:nvGrpSpPr>
      <p:grpSpPr>
        <a:xfrm>
          <a:off x="0" y="0"/><a:ext cx="0" cy="0"/>
          <a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/>
        </a:xfrm>
      </p:grpSpPr>
      <p:sp>
        <p:nvSpPr>
          <p:cNvPr id="2" name="Notes Placeholder"/>
          <p:cNvSpPr txBox="1"/>
          <p:nvPr>
            <p:ph type="body" idx="0"/>
          </p:nvPr>
        </p:nvSpPr>
        <p:spPr>
          <a:xfrm>
            <a:off x="0" y="0"/>
            <a:ext cx="9144000" cy="6858000"/>
          </a:xfrm>
        </p:spPr>
        <p:txBody>
          <a:bodyPr/>
          <a:lstStyle/>
          <a:p>
            <a:r>
              <a:rPr lang="en-US"/>
              <a:t>These are the speaker notes for this slide.</a:t>
            </a:r>
          </a:p>
        </p:txBody>
      </p:sp>
    </p:spTree>
  </p:cSld>
</p:notes>
```

## Relationship (in ppt/slides/_rels/slideN.xml.rels)

```xml
<Relationship Id="rIdN"
  Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/notesSlide"
  Target="../notesSlides/notesSlideN.xml"/>
```

## Content Types

```xml
<!-- For notesSlide -->
<Override PartName="/ppt/notesSlides/notesSlide1.xml"
  ContentType="application/vnd.openxmlformats-officedocument.presentationml.notesSlide+xml"/>

<!-- For notesMaster -->
<Override PartName="/ppt/notesMasters/notesMaster1.xml"
  ContentType="application/vnd.openxmlformats-officedocument.presentationml.notesMaster+xml"/>
```

## presentation.xml

- `<p:notesSz cx="9144000" cy="6858000"/>` — REQUIRED (minOccurs=1), specifies notes area size in EMUs
- `<p:notesMasterIdLst><p:notesMasterId r:id="rIdN"/></p:notesMasterIdLst>` — references the notes master

## Key Constraints

1. **One-to-one**: A notesSlide can only be referenced by one slide (validated in ppxt.py line 243-311)
2. **notesSz is required** in `presentation.xml` (schema minOccurs=1)
3. **notesMaster required** for proper rendering — provides color scheme, default text styling, header/footer
4. **Content_Types declarations required** for both notes slides and notes master
5. **No explicit master reference** on notes slides — linkage is implicit (application determines at load time)
6. **Duplication gotcha**: When duplicating slides, notes slide relationships are NOT automatically handled — must create copies with unique names