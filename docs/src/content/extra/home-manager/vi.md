This module provides a complete Neovim setup configured via Nixvim that includes LSPs for several languages, clipboard integration, autoformatting on save, and several plugins. There are a few opinionated defaults which can be overridden if desired, such as 4-space tab width and autoformat on save.

Once installed, it can be used by running either `vi`, `vim`, or `nvim`. An additional alias, `svi` which allows editing with root permissions while still maintaining the userspace Neovim configurations.

When using this module as a code IDE, the `<F5>` key is used to run the project. The behaviour depends on the type of project, and can be overridden by creating a `.virun` file at the root of your project containing the desired run command.
