local dap = require("dap")

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

dap.adapters.coreclr = {
  type = "executable",
  command = mason_bin .. "/netcoredbg",
  args = { "--interpreter=vscode" },
}

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "Launch (.NET) - pick dll",
    request = "launch",
    program = function()
      return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/net8.0/", "file")
    end,
    cwd = function()
      local dll = vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/net8.0/", "file")
      return vim.fn.fnamemodify(dll, ":h")
    end,
    console = "integratedTerminal",
    stopAtEntry = false,
    justMyCode = false,
    env = {
	DOTNET_ENVIRONMENT = "Development",
	ASPNETCORE_ENVIRONMENT = "Development",
	SMX_DNS_SUFFIX = "dev.smartx.us",
	ASPNETCORE_URLS = "http://localhost:5200",
    },
  },
}

