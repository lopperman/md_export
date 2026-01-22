-- Lua filter to format tables for Typst output
-- Features:
-- 1. Word wrapping enabled
-- 2. Smart column widths: short columns use auto, long columns share remaining space
-- 3. Left-aligned content
-- 4. Preserves inline formatting (bold, italic, code, links)

-- Threshold: columns with max content <= this many chars use 'auto' width
local SHORT_COLUMN_THRESHOLD = 15

-- Convert Pandoc inline elements to Typst markup
local function inlines_to_typst(inlines)
  local result = {}

  for _, inline in ipairs(inlines) do
    if inline.t == "Str" then
      -- Escape special Typst characters in plain text
      local text = inline.text
      text = text:gsub("\\", "\\\\")
      text = text:gsub("%[", "\\[")
      text = text:gsub("%]", "\\]")
      text = text:gsub("#", "\\#")
      text = text:gsub("%$", "\\$")
      text = text:gsub("\"", "\\\"")
      text = text:gsub("`", "\\`")
      table.insert(result, text)

    elseif inline.t == "Space" then
      table.insert(result, " ")

    elseif inline.t == "SoftBreak" then
      table.insert(result, " ")

    elseif inline.t == "LineBreak" then
      table.insert(result, "\\ ")

    elseif inline.t == "Strong" then
      -- Bold: **text** -> *text* in Typst
      local inner = inlines_to_typst(inline.content)
      table.insert(result, "*" .. inner .. "*")

    elseif inline.t == "Emph" then
      -- Italic: *text* -> _text_ in Typst
      local inner = inlines_to_typst(inline.content)
      table.insert(result, "_" .. inner .. "_")

    elseif inline.t == "Code" then
      -- Inline code: use #raw() function to avoid backtick escaping issues
      local code = inline.text:gsub("\"", "\\\"")
      table.insert(result, "#raw(\"" .. code .. "\")")

    elseif inline.t == "Link" then
      -- Link: [text](url) -> #link("url")[text] in Typst
      local link_text = inlines_to_typst(inline.content)
      local url = inline.target:gsub("\"", "\\\"")
      table.insert(result, "#link(\"" .. url .. "\")[" .. link_text .. "]")

    elseif inline.t == "Strikeout" then
      -- Strikethrough: ~~text~~ -> #strike[text] in Typst
      local inner = inlines_to_typst(inline.content)
      table.insert(result, "#strike[" .. inner .. "]")

    elseif inline.t == "Superscript" then
      local inner = inlines_to_typst(inline.content)
      table.insert(result, "#super[" .. inner .. "]")

    elseif inline.t == "Subscript" then
      local inner = inlines_to_typst(inline.content)
      table.insert(result, "#sub[" .. inner .. "]")

    elseif inline.t == "Quoted" then
      local inner = inlines_to_typst(inline.content)
      if inline.quotetype == "DoubleQuote" then
        table.insert(result, "\"" .. inner .. "\"")
      else
        table.insert(result, "'" .. inner .. "'")
      end

    else
      -- Fallback: stringify unknown elements
      local text = pandoc.utils.stringify(inline)
      text = text:gsub("\\", "\\\\")
      text = text:gsub("%[", "\\[")
      text = text:gsub("%]", "\\]")
      text = text:gsub("#", "\\#")
      text = text:gsub("%$", "\\$")
      text = text:gsub("\"", "\\\"")
      text = text:gsub("`", "\\`")
      table.insert(result, text)
    end
  end

  return table.concat(result)
end

-- Get cell content as Typst markup
local function cell_to_typst(cell)
  -- cell.contents is a list of blocks, usually containing a single Plain or Para
  local result = {}
  for _, block in ipairs(cell.contents) do
    if block.t == "Plain" or block.t == "Para" then
      table.insert(result, inlines_to_typst(block.content))
    else
      -- Fallback for other block types
      table.insert(result, pandoc.utils.stringify(block))
    end
  end
  return table.concat(result, " ")
end

-- Get plain text length for column width calculation
local function cell_to_plain_text(cell)
  return pandoc.utils.stringify(cell.contents)
end

function Table(tbl)
  -- Set all column alignments to left (AlignLeft)
  for i, colspec in ipairs(tbl.colspecs) do
    tbl.colspecs[i] = {pandoc.AlignLeft, colspec[2]}
  end

  -- For Typst output, generate raw Typst with smart table wrapper
  if FORMAT == "typst" then
    local num_cols = #tbl.colspecs

    -- Track max plain text length per column (for width calculation)
    local col_max_len = {}
    for i = 1, num_cols do
      col_max_len[i] = 0
    end

    -- Collect header cells with formatting
    local header_cells = {}
    if tbl.head and tbl.head.rows and #tbl.head.rows > 0 then
      for _, row in ipairs(tbl.head.rows) do
        for i, cell in ipairs(row.cells) do
          local typst_content = cell_to_typst(cell)
          local plain_len = #cell_to_plain_text(cell)
          table.insert(header_cells, typst_content)
          if plain_len > col_max_len[i] then
            col_max_len[i] = plain_len
          end
        end
      end
    end

    -- Collect body cells with formatting
    local body_cells = {}
    for _, body in ipairs(tbl.bodies) do
      for _, row in ipairs(body.body) do
        local row_cells = {}
        for i, cell in ipairs(row.cells) do
          local typst_content = cell_to_typst(cell)
          local plain_len = #cell_to_plain_text(cell)
          table.insert(row_cells, typst_content)
          if plain_len > col_max_len[i] then
            col_max_len[i] = plain_len
          end
        end
        table.insert(body_cells, row_cells)
      end
    end

    -- Determine column widths:
    -- - Last column always gets 1fr (fills remaining space)
    -- - Other columns: auto if short, or proportional if long
    local col_spec = {}
    local long_col_count = 0

    -- Count how many non-last columns are "long"
    for i = 1, num_cols - 1 do
      if col_max_len[i] > SHORT_COLUMN_THRESHOLD then
        long_col_count = long_col_count + 1
      end
    end

    -- Assign widths
    for i = 1, num_cols do
      if i == num_cols then
        -- Last column always gets 1fr
        table.insert(col_spec, "1fr")
      elseif col_max_len[i] <= SHORT_COLUMN_THRESHOLD then
        -- Short columns get auto
        table.insert(col_spec, "auto")
      elseif long_col_count > 1 then
        -- Multiple long columns: give them smaller fixed fractions
        -- so last column still gets most space
        table.insert(col_spec, "0.5fr")
      else
        -- Single long non-last column: still use auto but it will wrap
        table.insert(col_spec, "auto")
      end
    end

    -- Build alignment string (all left + top for vertical)
    local aligns = {}
    for i = 1, num_cols do
      table.insert(aligns, "left + top")
    end

    -- Build the smart-table call
    local typst = "#smart-table(\n"
    typst = typst .. "  columns: (" .. table.concat(col_spec, ", ") .. "),\n"
    typst = typst .. "  align: (" .. table.concat(aligns, ", ") .. "),\n"

    -- Header cells as array (using single quotes to avoid escaping issues)
    typst = typst .. "  header: (\n"
    for i, h in ipairs(header_cells) do
      typst = typst .. "    [" .. h .. "]"
      if i < #header_cells then typst = typst .. "," end
      typst = typst .. "\n"
    end
    typst = typst .. "  ),\n"

    -- Body cells as array of arrays
    typst = typst .. "  body: (\n"
    for i, row in ipairs(body_cells) do
      typst = typst .. "    ("
      for j, cell in ipairs(row) do
        typst = typst .. "[" .. cell .. "]"
        if j < #row then typst = typst .. ", " end
      end
      typst = typst .. ")"
      if i < #body_cells then typst = typst .. "," end
      typst = typst .. "\n"
    end
    typst = typst .. "  ),\n"
    typst = typst .. ")\n"

    return pandoc.RawBlock("typst", typst)
  end

  return tbl
end
