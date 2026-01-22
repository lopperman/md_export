// Custom Typst template for md-export
// Provides 0.5in margins and footer with filename and page number

#let source-file = "$source-file$"
#let export-timestamp = "$export-timestamp$"

// Horizontal rule definition for Pandoc
#let horizontalrule = line(length: 100%, stroke: 0.5pt + rgb("#dfe2e5"))

#set page(
  margin: 0.5in,
  footer: context [
    #set text(size: 9pt, fill: rgb("#666666"))
    #source-file - #export-timestamp
    #h(1fr)
    #counter(page).display("1 / 1", both: true)
  ]
)

#set text(
  font: "Helvetica Neue",
  fallback: true,
  size: 11pt,
)

#show raw: set text(font: "Menlo", size: 10pt)

#set par(
  leading: 0.65em,
  justify: false,
)

#set heading(numbering: none)

#show heading.where(level: 1): it => {
  set text(size: 1.5em, weight: "bold")
  block(below: 0.8em)[#it.body]
}

#show heading.where(level: 2): it => {
  set text(size: 1.25em, weight: "bold")
  block(above: 1.2em, below: 0.6em)[#it.body]
}

#show heading.where(level: 3): it => {
  set text(size: 1.1em, weight: "bold")
  block(above: 1em, below: 0.5em)[#it.body]
}

// Style code blocks
#show raw.where(block: true): it => {
  block(
    fill: rgb("#f6f8fa"),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
    it
  )
}

// Style inline code
#show raw.where(block: false): it => {
  box(
    fill: rgb("#f6f8fa"),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
    it
  )
}

// Style blockquotes
#show quote: it => {
  block(
    stroke: (left: 3pt + rgb("#dfe2e5")),
    inset: (left: 12pt, y: 4pt),
    it.body
  )
}

// Smart table function with adaptive sizing
// - Word wrapping enabled
// - Smart column widths (short cols = auto, long cols = 1fr)
// - Header: 11pt bold, Body: 10pt
// - Preserves inline formatting (bold, italic, code, links)
#let smart-table(columns: (), align: (), header: (), body: ()) = {
  // Build header cells: 11pt bold with background
  let header-cells = header.map(h => table.cell(fill: rgb("#f6f8fa"))[
    #set text(size: 11pt, weight: "bold")
    #h
  ])

  // Build body cells: 10pt normal with hyphenation for long words
  let body-cells = body.map(row => row.map(cell => [
    #set text(size: 10pt, hyphenate: true)
    #cell
  ])).flatten()

  // Render the table
  table(
    columns: columns,
    align: align,
    stroke: 0.5pt + rgb("#dfe2e5"),
    inset: 8pt,
    table.header(..header-cells),
    table.hline(),
    ..body-cells
  )
}

// Default table styling (for any tables not using smart-table)
#set table(
  stroke: 0.5pt + rgb("#dfe2e5"),
  inset: 8pt,
  align: left,
)

#show table.cell.where(y: 0): set text(weight: "bold")
#show table.cell.where(y: 0): set table.cell(fill: rgb("#f6f8fa"))

// Override Pandoc's centered table figures - force left alignment
#show figure.where(kind: table): it => {
  align(left)[#it.body]
}

$body$
