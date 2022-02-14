Plugin.require_version("4.0.0")

if not config["post_header_template"] then
  Plugin.fail("post_header_template option must be specified")
end

if not config["content_container_selector"] then
  Plugin.fail("content_container_selector option must be specified")
end

content_container = HTML.select_one(page, config["content_container_selector"])
if not content_container then
  Log.warning(format("Page does not have an element matching the \"%s\" content container selector"),
    config["content_container_selector"])
  Plugin.exit()
end

-- The goal of this plugin is to produce uniform post headers
-- from custom <post-title>, <post-date>, <post-tags>, and <post-excerpt> elements
--
-- There are two cases.
--
-- When those elements found standalone ("bare") in the document,
-- they are treated more like "front matter": their content is incorporated
-- in the post header, and those elements themselves are removed.
--
-- However, if they are found within some other HTML elements
-- (like in <p>During my <post-date datetime="1970-01-01">yesterday</post-date> visit
-- to the MIT AI lab...)
-- they are not removed, but translated to valid HTML elements,
-- in addition to their data being used in the header
--
-- However, there's a tricky part with standalone/bare elements
-- when Markdown conversion comes into play.
--
-- We consider an element "bare" if it's either
-- 1. a child of the element tree's root node
-- 2. or the only child of a <p> element
--
-- The latter is needed because Markdown processors will wrap
-- a single <post-header> etc. element on a line into <p> </p>
--
--
function is_bare(elem)
  local parent = HTML.parent(elem)

  if parent then
    -- If it's a child of the content container, consider it bare
    if parent == content_container then
      return 1
    end

    -- If it's inside <post-metadata>, it's also bare
    -- though this is mostly for completeness:
    -- in practice <post-metadata> is always cleaned up as a whole
    if HTML.get_tag_name(parent) == "post-metadata" then
      return 1
    end

    -- Now check if it's the only child of a paragraph.
    -- If yes, assume that paragraph was added by a Markdown processor,
    -- not by the user
    if (HTML.get_tag_name(parent) == "p") and (size(HTML.children(parent)) == 1) then
      return 1
    else
      return nil
    end
  else
    -- If it has no parent (i.e. its parent is root),
    -- it's definitely bare
    -- (even though in a real page that's quite unlikely)
    return 1
  end
end


function clean_up(elem)
  local parent = HTML.parent(elem)
  if parent then
    if (HTML.get_tag_name(parent) == "p") and (size(HTML.children(parent)) == 1) then
      HTML.delete(parent)
    else
      HTML.unwrap(elem)
    end
  else
    HTML.delete(elem)
  end
end

env = {}

-- Extract and clean up the <post-title> element
post_title = HTML.select_one(page, "post-title")
env["title"] = HTML.inner_html(post_title)
clean_up(post_title)

-- Extract and clean up the <post-date> element
post_date = HTML.select_one(page, "post-date")
post_datetime = HTML.get_attribute(post_date, "datetime")
if post_datetime then
  env["date"] = post_datetime
else
  env["date"] = HTML.inner_html(post_date)
end

if is_bare(post_date) then
  HTML.delete(post_date)
else
  HTML.set_tag_name(post_date, "time")
end

-- Extract and clean up the <post-tags> element
-- It's supposed to look like <post-tags>foo, bar, baz</post-tags>
-- We extract the tags string and split it into individual tags
post_tags = HTML.select_one(page, "post-tags")
tags = HTML.strip_tags(post_tags)
tags = Regex.split(tags, ",")
Table.apply_to_values(String.trim, tags)
env["tags"] = tags
clean_up(post_tags)

--- Handle the <post-excerpt> element

post_excerpt = HTML.select_one(page, "post-excerpt")
env["excerpt"] = HTML.inner_html(post_excerpt)
-- The logic for <post-excerpt> is somewhat more complicated:
-- if it's bare 
local excerpt_parent = HTML.parent(post_excerpt)
if HTML.get_tag_name(excerpt_parent) == "p" then
  -- If it looks like <p><post-excerpt>...</post-excerpt></p>,
  -- then we can just move its content to the parent paragraph
  -- and call it a day
  HTML.unwrap(excerpt)
else
  local children = HTML.select_any_of(excerpt, {"p", "div"})
  if children then
    HTML.set_tag_name(post_excerpt, "div")
  else
    HTML.set_tag_name(post_excerpt, "p")
  end
  HTML.set_attribute(post_excerpt, "id", "post-excerpt")
end

-- Now clean up the <post-metadata> container
post_metadata_container = HTML.select_one(page, "post-metadata")
if post_metadata_container then
    HTML.delete(post_metadata_container)
end

-- Render the post header and add it to the page

tmpl = config["post_header_template"]
header = HTML.parse(String.render_template(tmpl, env))
HTML.prepend_child(content_container, header)




