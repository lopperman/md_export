-- Lua filter to normalize internal link anchors
-- Fixes mismatches between GitHub-style/manual anchors and Pandoc-generated heading labels
--
-- 1. GitHub: ## Tools & CLIs -> #tools--clis (space-&-space becomes --)
--    Pandoc: ## Tools & CLIs -> <tools-clis> (consecutive dashes collapsed)
--
-- 2. Manual TOC: [1. Title](#1-title) keeps leading number
--    Pandoc: ## 1. Title -> <title> (leading digits/punctuation stripped)

function Link(el)
  -- Only process internal links (those starting with #)
  if el.target:sub(1, 1) == "#" then
    local anchor = el.target:sub(2)  -- Remove the leading #

    -- Strip leading digits, dots, and dashes (matches Pandoc's identifier generation)
    -- e.g. "1-how-it-works" -> "how-it-works"
    -- e.g. "12-some-heading" -> "some-heading"
    local normalized = anchor:gsub("^[%d%.]+%-*", "")

    -- Normalize: collapse consecutive dashes to single dash
    normalized = normalized:gsub("%-+", "-")

    -- Also remove leading/trailing dashes that might result
    normalized = normalized:gsub("^%-+", ""):gsub("%-+$", "")

    el.target = "#" .. normalized
  end

  return el
end
