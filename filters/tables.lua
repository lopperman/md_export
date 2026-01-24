-- Lua filter to format tables for Typst output
-- Features:
-- 1. Word wrapping enabled
-- 2. Smart column widths: short columns use auto, long columns share remaining space
-- 3. Left-aligned content
-- 4. Preserves inline formatting (bold, italic, code, links)

-- Threshold: columns with max content <= this many chars use 'auto' width
local SHORT_COLUMN_THRESHOLD = 15

-- Threshold: if longest unbreakable word exceeds this, column needs minimum width
local MIN_WORD_WIDTH_THRESHOLD = 10

-- Find the longest unbreakable word in a string
-- Words are split by spaces; this finds the longest token that can't wrap
local function longest_word_length(text)
  local max_len = 0
  for word in text:gmatch("%S+") do
    if #word > max_len then
      max_len = #word
    end
  end
  return max_len
end

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
      text = text:gsub("<", "\\<")
      text = text:gsub(">", "\\>")
      text = text:gsub("@", "\\@")
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
      -- In tables, render code as plain text with break opportunities
      local text = inline.text

      -- Helper function to escape special Typst characters
      local function escape_typst(s)
        s = s:gsub("\\", "\\\\")
        s = s:gsub("%[", "\\[")
        s = s:gsub("%]", "\\]")
        s = s:gsub("#", "\\#")
        s = s:gsub("%$", "\\$")
        s = s:gsub("\"", "\\\"")
        s = s:gsub("`", "\\`")
        s = s:gsub("_", "\\_")
        s = s:gsub("<", "\\<")
        s = s:gsub(">", "\\>")
        s = s:gsub("@", "\\@")
        return s
      end

      -- Skip ZWS insertion for URLs (causes Typst parsing issues)
      if text:find("://") then
        table.insert(result, escape_typst(text))
      else
        local zws = "\226\128\139"  -- UTF-8 encoding of U+200B (zero-width space)

        -- First split at _ and - to get segments
        local segments = {}
        local current = ""
        for i = 1, #text do
          local char = text:sub(i, i)
          current = current .. char
          if char == "_" or char == "-" then
            table.insert(segments, current)
            current = ""
          end
        end
        if current ~= "" then
          table.insert(segments, current)
        end

        -- For segments > 15 chars, insert break opportunities every 12 chars
        local final_parts = {}
        for _, seg in ipairs(segments) do
          if #seg > 15 then
            local pos = 1
            while pos <= #seg do
              local chunk = seg:sub(pos, pos + 11)
              table.insert(final_parts, chunk)
              pos = pos + 12
            end
          else
            table.insert(final_parts, seg)
          end
        end

        -- Escape special Typst characters in each part and join with zws
        local escaped_parts = {}
        for _, part in ipairs(final_parts) do
          table.insert(escaped_parts, escape_typst(part))
        end

        table.insert(result, table.concat(escaped_parts, zws))
      end

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
      text = text:gsub("<", "\\<")
      text = text:gsub(">", "\\>")
      text = text:gsub("@", "\\@")
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

-- Find the longest inline code element in a cell
-- Returns the length of the longest code string (0 if no code)
local function cell_longest_code(cell)
  local max_code_len = 0
  for _, block in ipairs(cell.contents) do
    if block.t == "Plain" or block.t == "Para" then
      for _, inline in ipairs(block.content) do
        if inline.t == "Code" then
          if #inline.text > max_code_len then
            max_code_len = #inline.text
          end
        end
      end
    end
  end
  return max_code_len
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
    -- Track longest unbreakable word per column (for minimum width)
    local col_max_word = {}
    -- Track longest inline code per column (code needs more space - can't wrap easily)
    local col_max_code = {}
    for i = 1, num_cols do
      col_max_len[i] = 0
      col_max_word[i] = 0
      col_max_code[i] = 0
    end

    -- Collect header cells with formatting
    local header_cells = {}
    if tbl.head and tbl.head.rows and #tbl.head.rows > 0 then
      for _, row in ipairs(tbl.head.rows) do
        for i, cell in ipairs(row.cells) do
          local typst_content = cell_to_typst(cell)
          local plain_text = cell_to_plain_text(cell)
          local plain_len = #plain_text
          local max_word = longest_word_length(plain_text)
          local max_code = cell_longest_code(cell)
          table.insert(header_cells, typst_content)
          if plain_len > col_max_len[i] then
            col_max_len[i] = plain_len
          end
          if max_word > col_max_word[i] then
            col_max_word[i] = max_word
          end
          if max_code > col_max_code[i] then
            col_max_code[i] = max_code
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
          local plain_text = cell_to_plain_text(cell)
          local plain_len = #plain_text
          local max_word = longest_word_length(plain_text)
          local max_code = cell_longest_code(cell)
          table.insert(row_cells, typst_content)
          if plain_len > col_max_len[i] then
            col_max_len[i] = plain_len
          end
          if max_word > col_max_word[i] then
            col_max_word[i] = max_word
          end
          if max_code > col_max_code[i] then
            col_max_code[i] = max_code
          end
        end
        table.insert(body_cells, row_cells)
      end
    end

    -- Determine column widths based on minimum content requirements
    -- Key insight: width should be proportional to longest non-wrappable segment
    local col_spec = {}

    -- Calculate "minimum width need" for each column
    -- This is the longest segment that absolutely cannot wrap
    local col_min_need = {}
    for i = 1, num_cols do
      if col_max_code[i] > 0 then
        -- For code columns: find longest segment between _ and -
        -- (we split code at these chars, so each segment is the min need)
        -- Approximate: divide code length by number of break points + 1
        local code_len = col_max_code[i]
        -- Rough estimate: assume 3-4 segments on average for long code
        local segments = math.max(1, math.floor(code_len / 15))
        col_min_need[i] = math.ceil(code_len / segments)
      else
        -- For text columns: longest word is the min need
        col_min_need[i] = col_max_word[i]
      end
    end

    -- Calculate total "need" to determine proportions
    local total_need = 0
    for i = 1, num_cols do
      total_need = total_need + col_min_need[i]
    end

    -- Assign widths proportionally based on need
    -- But use some minimums and maximums to keep things reasonable
    for i = 1, num_cols do
      local need = col_min_need[i]

      if col_max_len[i] <= SHORT_COLUMN_THRESHOLD and col_max_word[i] <= 10 then
        -- Truly short columns: use auto
        table.insert(col_spec, "auto")
      else
        -- Calculate proportional fraction based on need
        local fraction = need / total_need * num_cols
        -- Clamp to reasonable range: 0.5 to 2.0
        fraction = math.max(0.5, math.min(2.0, fraction))
        -- Round to 1 decimal place
        fraction = math.floor(fraction * 10 + 0.5) / 10
        table.insert(col_spec, fraction .. "fr")
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
