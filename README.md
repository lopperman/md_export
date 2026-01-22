# md-export

A command-line tool to convert Markdown files to PDF or HTML with GitHub-style formatting.

## Features

- **PDF Export** via Pandoc + Typst (lightweight, fast, high quality)
- **HTML Export** with GitHub-style CSS
- **Smart Table Formatting**
  - Automatic column width detection
  - Word wrapping enabled
  - Last column extends to fill available space
  - Header: 11pt bold, Body: 10pt
- **Preserved Inline Formatting** in tables (bold, italic, code, links)
- **Task List Checkboxes** render as proper checkboxes (☐ / ✓)
- **Emoji Support** - converts `:smile:` shortcodes to actual emojis 😄
- **PDF Footer** with filename and export timestamp
- **0.5in margins** on PDF output

## Installation

### Prerequisites

```bash
# Install Pandoc
brew install pandoc

# Install Typst (required for PDF export)
brew install typst
```

### Install md-export

```bash
# Clone the repository
git clone https://github.com/yourusername/md_export.git
cd md_export

# Install globally
./install.sh
```

To uninstall:
```bash
./uninstall.sh
```

## Usage

```bash
# Convert to PDF (default)
md-export document.md

# Convert to HTML
md-export -t html document.md

# Specify output filename
md-export -o report.pdf document.md

# Show help
md-export --help
```

### Options

| Option | Description |
|--------|-------------|
| `-t, --type TYPE` | Output type: `html` or `pdf` (default: `pdf`) |
| `-o, --output FILE` | Output filename (default: input name with new extension) |
| `-h, --help` | Show help message |
| `-v, --version` | Show version |

## Examples

See the comprehensive test files demonstrating supported Markdown features:

- [Markdown Source](examples/comprehensive_test.md)
- [PDF Output](examples/comprehensive_test.pdf)
- [HTML Output](examples/comprehensive_test.html)

## Supported Markdown Features

| Feature | PDF | HTML |
|---------|:---:|:----:|
| Headers (h1-h6) | ✅ | ✅ |
| Bold / Italic / Strikethrough | ✅ | ✅ |
| Inline code | ✅ | ✅ |
| Code blocks (with syntax hints) | ✅ | ✅ |
| Links | ✅ | ✅ |
| Images (local files) | ✅ | ✅ |
| Ordered / Unordered lists | ✅ | ✅ |
| Nested lists | ✅ | ✅ |
| Task lists (checkboxes) | ✅ | ✅ |
| Blockquotes | ✅ | ✅ |
| Tables | ✅ | ✅ |
| Table cell formatting | ✅ | ✅ |
| Horizontal rules | ✅ | ✅ |
| Emoji shortcodes | ✅ | ✅ |

### Not Supported

- Math/LaTeX equations (Typst uses different syntax)
- Footnotes
- Raw HTML (stripped)
- Mermaid diagrams

## Project Structure

```
md_export/
├── md-export           # Main script
├── install.sh          # Global installation script
├── uninstall.sh        # Uninstall script
├── templates/
│   └── pdf.typ         # Typst template for PDF output
├── filters/
│   ├── tables.lua      # Smart table formatting
│   ├── tasks.lua       # Task list checkbox rendering
│   └── emoji.lua       # Emoji shortcode conversion
└── examples/
    ├── comprehensive_test.md
    ├── comprehensive_test.pdf
    └── comprehensive_test.html
```

## Customization

### PDF Styling

Edit `templates/pdf.typ` to customize:
- Page margins
- Fonts and sizes
- Header styles
- Table appearance
- Footer format

### Adding Emojis

Edit `filters/emoji.lua` to add additional emoji shortcodes to the `emoji_map` table.

## License

MIT
