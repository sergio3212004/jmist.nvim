-- Placeholder payload for the UI skeleton.
-- Real Maven/Gradle data will replace these tables later.

local M = {}

M.project = {
  name = "jmist.nvim",
  root = "~/Projects/jmist.nvim",
  branch = "feat/ui",
  build = "maven",
  build_label = "Maven",
  command = "mvnw",
  java = "Java 21",
  status = "ready",
}

M.counts = {
  total = 15,
  direct = 6,
  transitive = 9,
}

M.dependencies = {
  {
    group = "org.springframework",
    artifact = "spring-core",
    version = "6.2.1",
    scope = "compile",
    kind = "direct",
  },
  {
    group = "org.springframework",
    artifact = "spring-context",
    version = "6.2.1",
    scope = "compile",
    kind = "direct",
  },
  {
    group = "org.springframework.boot",
    artifact = "spring-boot-starter-web",
    version = "3.4.1",
    scope = "compile",
    kind = "direct",
  },
  {
    group = "com.google.code.gson",
    artifact = "gson",
    version = "2.11.0",
    scope = "compile",
    kind = "direct",
  },
  {
    group = "org.projectlombok",
    artifact = "lombok",
    version = "1.18.36",
    scope = "provided",
    kind = "direct",
  },
  {
    group = "org.junit.jupiter",
    artifact = "junit-jupiter",
    version = "5.11.4",
    scope = "test",
    kind = "direct",
  },
  {
    group = "org.apache.commons",
    artifact = "commons-lang3",
    version = "3.17.0",
    scope = "compile",
    kind = "transitive",
  },
  {
    group = "org.slf4j",
    artifact = "slf4j-api",
    version = "2.0.16",
    scope = "compile",
    kind = "transitive",
  },
  {
    group = "ch.qos.logback",
    artifact = "logback-classic",
    version = "1.5.12",
    scope = "runtime",
    kind = "transitive",
  },
  {
    group = "com.fasterxml.jackson.core",
    artifact = "jackson-databind",
    version = "2.18.2",
    scope = "compile",
    kind = "transitive",
  },
  {
    group = "com.fasterxml.jackson.core",
    artifact = "jackson-core",
    version = "2.18.2",
    scope = "compile",
    kind = "transitive",
  },
  {
    group = "org.apache.tomcat.embed",
    artifact = "tomcat-embed-core",
    version = "10.1.34",
    scope = "compile",
    kind = "transitive",
  },
  {
    group = "org.yaml",
    artifact = "snakeyaml",
    version = "2.3",
    scope = "runtime",
    kind = "transitive",
  },
  {
    group = "io.micrometer",
    artifact = "micrometer-core",
    version = "1.14.2",
    scope = "compile",
    kind = "transitive",
  },
  {
    group = "org.mockito",
    artifact = "mockito-core",
    version = "5.15.2",
    scope = "test",
    kind = "transitive",
  },
}

M.search = {
  query = "guava",
  source = "Maven Central",
  results = {
    {
      group = "com.google.guava",
      artifact = "guava",
      version = "33.4.0-jre",
      downloads = "42.1k",
      installed = false,
    },
    {
      group = "com.google.code.gson",
      artifact = "gson",
      version = "2.11.0",
      downloads = "28.4k",
      installed = false,
    },
    {
      group = "org.apache.commons",
      artifact = "commons-lang3",
      version = "3.17.0",
      downloads = "31.2k",
      installed = true,
    },
    {
      group = "org.slf4j",
      artifact = "slf4j-api",
      version = "2.0.16",
      downloads = "26.8k",
      installed = false,
    },
    {
      group = "com.fasterxml.jackson.core",
      artifact = "jackson-databind",
      version = "2.18.2",
      downloads = "24.5k",
      installed = false,
    },
    {
      group = "org.projectlombok",
      artifact = "lombok",
      version = "1.18.36",
      downloads = "19.7k",
      installed = true,
    },
    {
      group = "org.junit.jupiter",
      artifact = "junit-jupiter",
      version = "5.11.4",
      downloads = "14.3k",
      installed = false,
    },
    {
      group = "org.mockito",
      artifact = "mockito-core",
      version = "5.15.2",
      downloads = "12.9k",
      installed = false,
    },
  },
}

M.output = {
  command = "mvn dependency:tree",
  status = "completed",
  elapsed = "4.2s",
  lines = {
    { level = "cmd", text = "$ mvn dependency:tree -DoutputType=text" },
    { level = "dim", text = "" },
    { level = "info", text = "[INFO] Scanning for projects..." },
    { level = "info", text = "[INFO]" },
    { level = "info", text = "[INFO] -----------------------< com.sergio:jmist >-----------------------" },
    { level = "info", text = "[INFO] Building jmist 0.1.0" },
    { level = "info", text = "[INFO]   from pom.xml" },
    { level = "info", text = "[INFO] --------------------------------[ jar ]---------------------------------" },
    { level = "info", text = "[INFO]" },
    { level = "info", text = "[INFO] --- dependency:3.8.1:tree (default-cli) @ jmist ---" },
    { level = "info", text = "[INFO] com.sergio:jmist:jar:0.1.0" },
    { level = "info", text = "[INFO] +- org.springframework:spring-core:jar:6.2.1:compile" },
    { level = "info", text = "[INFO] |  \\- org.springframework:spring-jcl:jar:6.2.1:compile" },
    { level = "info", text = "[INFO] +- com.google.code.gson:gson:jar:2.11.0:compile" },
    { level = "warn", text = "[WARNING] The POM for org.example:missing:jar:1.0 is missing" },
    { level = "success", text = "[INFO] BUILD SUCCESS" },
    { level = "info", text = "[INFO] Total time:  4.218 s" },
    { level = "info", text = "[INFO] Finished at: 2026-10-28T01:12:00-03:00" },
    { level = "dim", text = "" },
    { level = "cmd", text = "$ █" },
  },
}

--- Resets the demo data and navigation state.
--- @param state table
M.apply = function(state)
  state.project = vim.deepcopy(M.project)
  state.counts = vim.deepcopy(M.counts)
  state.dependencies = vim.deepcopy(M.dependencies)
  state.search = vim.deepcopy(M.search)
  state.output = vim.deepcopy(M.output)

  state.tab = "dependencies"
  state.selected = 1
  state.scroll = 0
  state.status = nil
end

return M
