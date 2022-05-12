-- Atom feed generator

Plugin.require_version("4.0.0")

data = {}

date_input_formats = soupault_config["index"]["date_formats"]

feed_file = config["feed_file"]

custom_options = soupault_config["custom_options"]

if not Table.has_key(custom_options, "site_url") then
  Plugin.exit([[Atom feed generation is not enabled in the config. If you want to enable it, set custom_options.atom_feeds = true]])
end

if not Table.has_key(custom_options, "site_url") then
  Plugin.fail([[custom_options["site_url"] option is required when feed generation is enabled]])
end

data["site_url"] = custom_options["site_url"]
data["feed_id"] = Sys.join_path(custom_options["site_url"], feed_file)

data["soupault_version"] = Plugin.soupault_version()

data["feed_author"] = custom_options["site_author"]
data["feed_author_email"] = custom_options["site_author_email"]
data["feed_title"] = custom_options["site_title"]
data["feed_subtitle"] = custom_options["site_subtitle"]
data["feed_logo"] = custom_options["site_logo"]


function in_section(entry)
  return (entry["nav_path"][1] == config["use_section"])
end

function tags_match(entry)
  if config["use_tag"] then
    return (Regex.match(entry["tags"], format("\\b%s\\b", config["use_tag"])))
  else
    return 1
  end
end

entries = {}

-- Original, unfiltered entries inded
local n = 1

-- Index of the new array of entries we are building
local m = 1

local count = size(site_index)
while (n <= count) do
  entry = site_index[n]
  if (in_section(entry) and tags_match(entry)) then
    if entry["date"] then
      entry["date"] = Date.reformat(entry["date"], date_input_formats, "%Y-%m-%dT%H:%M:%S%:z")
    end
    entries[m] = entry
    m = m + 1
  end
  n = n + 1
end

if (soupault_config["index"]["sort_descending"] or
   (not Table.has_key(soupault_config["index"], "sort_descending")))
then
  data["feed_last_updated"] = entries[1]["date"]
else
  data["feed_last_updated"] = entries[size(entries)]["date"]
end

data["entries"] = entries

feed_template = [[
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en">
  <id>{{feed_id}}</id>
  <updated>{{feed_last_updated}}</updated>
  <title>{{feed_title}}</title>
  {%- if feed_subtitle -%} <subtitle>{{feed_subtitle}}</subtitle> {%- endif -%}
  {%- if feed_logo -%} <logo>{{feed_logo}}</logo> {%- endif -%}
  <author>
    <name>{{feed_author}}</name>
    {%- if feed_author_email -%}<email>{{feed_author_email}}</email> {%- endif -%}
  </author>
  <generator uri="https://soupault.app" version="{{soupault_version}}">soupault</generator>
  {%- for e in entries %}
  <entry>
    <id>{{site_url}}{{e.url}}</id>
    <title>{{e.title}}</title>
    <updated>{{e.date}}</updated>
    <content type="html">
    {{e.excerpt | escape}}
    </content>
    <link href="{{site_url}}{{e.url}}" rel="alternate"/>
  </entry>
  {% endfor %}
</feed>
]]

feed = String.render_template(feed_template, data)

Sys.write_file(Sys.join_path(target_dir, feed_file), String.trim(feed))
