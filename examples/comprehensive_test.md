# Comprehensive Markdown Test

This document tests various markdown features for PDF export.

---

## Basic Text Formatting

This is **bold text** and this is *italic text* and this is ***bold italic***.

This is `inline code` and this is ~~strikethrough~~.

Here's a [link to Google](https://google.com) and an autolink: https://example.com

---

## Headers

### Level 3 Header
#### Level 4 Header
##### Level 5 Header
###### Level 6 Header

---

## Lists

### Unordered List
- Item 1
- Item 2
  - Nested item 2a
  - Nested item 2b
    - Deeply nested
- Item 3

### Ordered List
1. First item
2. Second item
   1. Nested numbered
   2. Another nested
3. Third item

### Task Lists (GitHub style)
- [ ] Unchecked task
- [x] Checked task
- [ ] Another unchecked

---

## Blockquotes

> This is a blockquote.
> It can span multiple lines.

> Nested blockquotes:
> > This is nested
> > > Even deeper

---

## Code Blocks

Inline: Use the `print()` function.

Fenced code block with syntax highlighting:

```python
def hello_world():
    """A simple function."""
    print("Hello, World!")
    return True
```

```javascript
const greeting = (name) => {
    console.log(`Hello, ${name}!`);
};
```

---

## Images

![Placeholder Image](https://via.placeholder.com/150)

---

## Tables with Various Content

### Simple Table
| Name | Age |
|------|-----|
| Alice | 30 |
| Bob | 25 |

### Table with Formatting
| Feature | Description | Example |
|---------|-------------|---------|
| Bold | Makes text bold | **bold text** |
| Italic | Makes text italic | *italic text* |
| Both | Combined | ***bold and italic*** |
| Code | Inline code | `variable_name` |
| Link | Hyperlink | [Click here](https://example.com) |

### Table with Alignment (Markdown syntax)
| Left | Center | Right |
|:-----|:------:|------:|
| L1 | C1 | R1 |
| L2 | C2 | R2 |

### Table with Long Content
| ID | Short | Description |
|----|-------|-------------|
| 1 | Yes | This is a very long description that should wrap to multiple lines within the cell to test word wrapping behavior. |
| 2 | No | Short desc |
| 3 | Maybe | Another longer description with **bold**, *italic*, and `code` formatting mixed in. |

---

## Special Characters

- Ampersand: &
- Less than: <
- Greater than: >
- Quote: "quoted"
- Apostrophe: it's
- Backslash: \\
- Hash: #hashtag
- Dollar: $100
- Asterisks: * not bold *
- Brackets: [not a link]

---

## Math (LaTeX style)

Inline math: $E = mc^2$

Block math:
$$
\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$

---

## Footnotes

Here's a sentence with a footnote[^1].

And another one[^note].

[^1]: This is the first footnote.
[^note]: This is a named footnote.

---

## Definition Lists

Term 1
: Definition for term 1

Term 2
: Definition for term 2
: Another definition for term 2

---

## Horizontal Rules

Above the rule.

---

Below the rule.

***

Another style.

___

Yet another.

---

## Emoji (GitHub shortcodes)

:smile: :thumbsup: :rocket:

---

## Raw HTML

<div style="color: red;">This is red HTML text</div>

<details>
<summary>Click to expand</summary>
Hidden content here.
</details>

---

## Escape Characters

\*Not italic\*
\`Not code\`
\[Not a link\]

---

## End of Test

If you can read this, the document rendered successfully!
