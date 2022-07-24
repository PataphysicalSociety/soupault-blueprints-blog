# soupault-blueprints-blog

[Soupault](https://soupault.app) is a static website generator framework.
It's highly flexible and can be used for different kinds of websites
from small homepages to large websites with a complex structure.

Since it lacks a built-in content model and allows the user to define it from scratch,
settings up a website from scratch can be a daunting task for beginners.
To help people set up new websites quickly, the soupault community provides
a set of "blueprints". Each blueprint is a set of a soupault config,
plugins, HTML templates, CSS styles, and sample data for demonstration.

This blueprint defines a blog with all features you'd expect from a blog:
post lists, tags, Atom feeds.

## Using this blueprint

* Install soupault 4.0.0 or later (see https://soupault.app/install/).
* Run `soupault` in the blueprint directory.
* Serve the `build/` directory (e.g. with `python3 -m http.server --directory build`) and visit the page.

You will find both sample posts and detailed usage instructions there.

Then you can delete the sample data and populate the website with your own content.

## Deployment

This blueprint includes a ready-to-use script for Netlify.
 
