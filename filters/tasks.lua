-- Lua filter to improve task list checkbox rendering in Typst
-- Replaces Unicode ballot boxes with better alternatives

function Str(el)
  -- Replace ballot box (☐) with empty square bracket style
  if el.text == "☐" then
    if FORMAT == "typst" then
      return pandoc.RawInline("typst", "#box(stroke: 0.5pt, width: 0.8em, height: 0.8em, inset: 1pt)[]")
    end
    return el
  end

  -- Replace ballot box with X (☒) with checked box
  if el.text == "☒" then
    if FORMAT == "typst" then
      return pandoc.RawInline("typst", "#box(stroke: 0.5pt, width: 0.8em, height: 0.8em, inset: 1pt, align(center + horizon)[✓])")
    end
    return el
  end

  return el
end
