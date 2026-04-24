# How to create charts in documents? - Carbone

## Overview

Carbone provides insights into creating charts that work across different document formats, revealing important considerations for cross-format visualization.

## Supported Formats

Carbone's charting solution works with multiple document formats:
- ODT, ODS, ODP, ODG
- DOCX, PPTX, XLSX
- HTML and PDF files

This broad compatibility demonstrates the importance of using standard formats for maximum reach.

## Implementation Approaches

### SVG-Based Charts

1. **Format**: Charts are injected as SVG images into documents
2. **Benefits**: 
   - High quality at any resolution
   - Compatible with most modern document formats
   - Editable in vector graphics software
3. **Limitations**:
   - Not directly editable within Office applications
   - Larger file sizes than native chart objects

### Native Office Charts

1. **Integration**: Can be embedded directly in Office documents
2. **Benefits**:
   - Fully editable within native applications
   - Consistent with Office UI paradigms
   - Automatic updates when data changes
3. **Limitations**:
   - Format-specific implementations
   - Potential compatibility issues across platforms

## Technical Considerations

### Data Handling

1. **JSON Configuration**: Chart formatting and data can be specified through JSON structures
2. **Dynamic Updates**: Charts can be regenerated when underlying data changes
3. **Templating**: Chart configurations can be part of document templates

### Cross-Application Integration

1. **Data Flow**: Systems should consider how data moves between applications
2. **Consistency**: Maintaining visual consistency across different output formats
3. **Performance**: Balancing feature richness with document processing speed

## Best Practices

1. **Format Selection**: Choose the right chart implementation based on document distribution needs
2. **Fallback Strategies**: Provide alternatives when advanced features aren't supported
3. **Testing**: Validate chart rendering across target platforms and applications
4. **Documentation**: Clearly document the charting approach for maintenance purposes