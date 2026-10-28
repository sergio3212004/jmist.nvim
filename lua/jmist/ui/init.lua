-- Public surface of the UI layer.
-- Views are pure: they read state and return Volt lines.

return {
  header = require "jmist.ui.header",
  tabs = require "jmist.ui.tabs",
  body = require "jmist.ui.body",
  footer = require "jmist.ui.footer",
  components = require "jmist.ui.components",
}
