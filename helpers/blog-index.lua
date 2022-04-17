if not config["index_template"] then
  Plugin.fail("Please define the index_template option")
end

if not config["index_selector"] then
  Plugin.fail("Please define the index_selector option")
end

tag_path = "tag"
if config["tag_path"] then
  tag_path = config["tag_path"]
end


-- Render entries on the blog page
env = {}
env["entries"] = site_index
posts = HTML.parse(String.render_template(config["index_template"], env))
container = HTML.select_one(page, config["index_selector"])
HTML.append_child(container, posts)

-- Create new pages for each tag

tag_path = Sys.join_path(Sys.dirname(page_file), tag_path)

-- Find all existing tags first
all_tags = {}
local i = 1
local count = size(site_index)
while (i <= count) do
  entry = site_index[i]
  local k = 1
  if not entry["tags"] then
    -- This entry has no tags, skip it
    i = i + 1
  else
    tag_count = size(entry["tags"])
    while (k <= tag_count) do
      all_tags[entry["tags"][k]] = 1
      k = k + 1
    end
  end
  i = i + 1
end

all_tags = Table.keys(all_tags)

function find_entries_with_tag(entries, tag)
  local es = {}
  local i = 1
  Log.debug("so far")
  local count = size(entries)
  local k = 1
  while (i <= count) do
    entry = entries[i]
    if not (Value.is_table(entry["tags"])) then
      -- No tags in this entry, so it definitely does not match
      i = i + 1
    else
      if Table.has_value(entry["tags"], tag) then
        es[k] = entry
        k = k + 1
      end
      i = i + 1
    end
  end
  return es
end

function build_tag_page(entries, tag)
  local matching_entries = find_entries_with_tag(entries, tag)
  local template = "<h1>Posts tagged \"{{tag}}\"</h1>" .. config["index_template"]
  local env = {}
  env["tag"] = tag
  env["entries"] = matching_entries
  posts = String.render_template(template, env)
  return posts
end

pages = {}

local i = 1
local tag_count = size(all_tags)
while (i <= tag_count) do
  tag = all_tags[i]
  Log.info(format("Generating a page for tag \"%s\"", tag))

  tag_page = {}
  tag_page["page_file"] = Sys.join_path(tag_path, format("%s.html", tag))
  tag_page["page_content"] = build_tag_page(site_index, tag)
  
  pages[i] = tag_page

  i = i + 1
end

-- Finally, generate a page with a list of all tags
local tag_links = {}
local i = 1
local tag_count = size(all_tags)
while (i <= tag_count) do
  local tag = all_tags[i]
  local tag_link = {}
  tag_link["url"] = tag
  tag_link["title"] = tag
  tag_links[i] = tag_link

  i = i + 1
end

local template = [[
<h1>Posts by tag</h1>
<ul>
{% for t in tag_links %}
  <li> <a href="{{t.url}}">{{t.title}}</a> </li>
{% endfor %}
</ul>
]]

local env = {}
env["tag_links"] = tag_links
local all_tags_page = {}
all_tags_page["page_file"] = Sys.join_path(tag_path, "index.html")
all_tags_page["page_content"] = String.render_template(template, env)

pages[size(pages) + 1] = all_tags_page
