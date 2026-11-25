-- DIVI · project switching (IntelliJ's "recent projects" + your whole disk)
local S = require("divi.settings")

return {
  {
    "snacks.nvim",
    opts = {
      picker = {
        sources = {
          projects = {
            dev = S.projects.roots,
            max_depth = S.projects.depth,
            recent = true,
            patterns = {
              ".git",
              "package.json",
              "pyproject.toml",
              "setup.py",
              "Cargo.toml",
              "go.mod",
              "pom.xml",
              "build.gradle",
              "build.gradle.kts",
              "settings.gradle",
              "Makefile",
              "CMakeLists.txt",
              "Gemfile",
              "composer.json",
              "Package.swift",
              "*.xcodeproj",
              "*.xcworkspace",
              "docker-compose.yml",
              "flake.nix",
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>fP",
        function()
          Snacks.picker.projects({ title = "All Projects (disk scan)", recent = false })
        end,
        desc = "All projects on disk",
      },
    },
  },
}
