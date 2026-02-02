local dap = require("dap")

-- Mason installs binaries here (works on Linux/macOS/WSL)
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

-- netcoredbg adapter (CoreCLR)
dap.adapters.coreclr = {
  type = "executable",
  command = mason_bin .. "/netcoredbg",
  args = { "--interpreter=vscode" },
}

-- Helper: try to guess the Debug/net8.0 dll, but still let you choose
local function pick_dll()
  local cwd = vim.fn.getcwd()

  -- If you're in a project folder, this often exists:
  -- <project>/bin/Debug/net8.0/<project>.dll
  -- But solutions vary, so we prompt.
  return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/net8.0/", "file")
end

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "Launch (.NET) - netcoredbg",
    request = "launch",
    program = pick_dll,
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    stopAtEntry = false,
    justMyCode = true,
  },
  {
    type = "coreclr",
    name = "Attach (.NET) - pick process",
    request = "attach",
    processId = require("dap.utils").pick_process,
  },
}

-- Keymaps (minimal + usable)
vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "DAP Continue" })
vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "DAP Step Over" })
vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "DAP Step Into" })
vim.keymap.set("n", "<F12>", function() dap.step_out() end, { desc = "DAP Step Out" })
vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dr", function() dap.repl.open() end, { desc = "DAP REPL" })
vim.keymap.set("n", "<leader>dl", function() dap.run_last() end, { desc = "DAP Run Last" })

