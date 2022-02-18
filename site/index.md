This is a sample [soupault](https://soupault.app) blog setup that you can make your own.

You can edit this page content in `site/index.md`. For example, greet your readers
and introduce yourself and your blog.

## Basics

* The configuration is in the `soupault.toml` file. Make sure to read it and tweak it if you want.
* Page source files are in `site/`.
* The page template is in `templates/main.html`.
* The header and the footer are in `templates/header.html` and `templates/footer.html`, respectively.
* Navigation menu link highlighting is done by the `section-link-highlight` plugin.
* Lua plugins are stored in `plugins/`. You can find more plugins at [soupault.app/plugins](https://www.soupault.app/plugins/).

## Styling

The CSS file is in `site/style.css`. Soupault copies all non-page files<fn id="asset-files">That is, files with extensions not mentioned in
<code>settings.page_file_extensions</code>.</fn> to the `build/` directory unchanged, so it doesn't need a dedicated assets directory.

## Dependencies

This setup uses [pandoc](https://pandoc.org) for Markdown to HTML conversion. To build it locally, please make sure
that pandoc is installed on your system.

You can switch to a different Markdown convertor or add convertors for more formats in the `[preprocessors]` section
of `soupault.toml`. See the [page preprocessors](https://soupault.app/reference-manual/#page-preprocessors)
section of the reference manual for details.

## Creating new posts

Create a new page under `site/blog`, e.g. `site/blog/my-post.md`. Instead of "front matter", you will use a custom
HTML "microformat" for the metadata.<fn id="post-metadata">This isn't a built-in feature of soupault, but rather a feature
of this blueprint, implemented with a mix of Lua plugins and soupault configuration. See <kbd>plugins/post-header.lua</kbd>
and the <kbd>[index]</kbd> section in <kbd>soupault.toml</kbd>

In the simplest case it will look like this:

```html
<post-metadata>
  <post-title>My post</post-title>
  <post-date>1970-01-01</post-date>
  <post-tags>test, post</post-tags>
</post-metadata>

This is a post...
```

However, you can also embed those tags in the post content and still have a generated header. See `site/blog/second-post.md`
for an example.

<h2 id="latest-entries-header">Latest posts</h2>

<div id="latest-blog-entries">
  <!-- The blog-summary index view will insert titles of the latest 10 entries here.
       To change the behaviour or styling,
       edit the [index.views.blog-summary] section in soupault.toml
    -->
</div>
