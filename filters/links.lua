-- Lua filter to normalize internal link anchors
-- Fixes mismatch between GitHub-style anchors (double dashes for & characters)
-- and Pandoc-generated heading labels (single dashes)
--
-- GitHub: ## Tools & CLIs -> #tools--clis (space-&-space becomes --)
-- Pandoc: ## Tools & CLIs -> <tools-clis> (consecutive dashes collapsed)

function Link(el)
  -- Only process internal links (those starting with #)
  if el.target:sub(1, 1) == "#" then
    local anchor = el.target:sub(2)  -- Remove the leading #

    -- Normalize: collapse consecutive dashes to single dash
    local normalized = anchor:gsub("%-+", "-")

    -- Also remove leading/trailing dashes that might result
    normalized = normalized:gsub("^%-+", ""):gsub("%-+$", "")

    el.target = "#" .. normalized
  end

  return el
end
