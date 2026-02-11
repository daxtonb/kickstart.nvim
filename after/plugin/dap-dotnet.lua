local dap = require 'dap'

local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin'

dap.adapters.coreclr = {
  type = 'executable',
  command = mason_bin .. '/netcoredbg',
  args = { '--interpreter=vscode' },
}

local last_dll_path
local last_env_short_name

local function prompt_dll_path()
  if last_dll_path and #last_dll_path > 0 then
    return last_dll_path
  end
  local cwd = vim.fn.getcwd()
  local bin_path = '/bin/Debug/net8.0/'

  if vim.endswith(cwd, '/smartx-tg-uma') then
    last_dll_path = cwd .. '/src/UmaApi' .. bin_path .. 'SmartX.Uma.Api.dll'
  elseif vim.endswith(cwd, '/smartx-tradebuilderconsumer') then
    last_dll_path = cwd .. '/src/Web' .. bin_path .. 'Web.dll'
  elseif vim.endswith(cwd, '/smartx-tradebuilderproducer') then
    last_dll_path = cwd .. '/src/TradeRebalQueue' .. bin_path .. 'TradeRebalQueue.dll'
  else
    last_dll_path = vim.fn.input('Path to dll: ', cwd .. bin_path, 'file')
  end

  return last_dll_path
end

dap.configurations.cs = {
  {
    type = 'coreclr',
    name = 'Launch (.NET) - pick dll',
    request = 'launch',
    program = function()
      return prompt_dll_path()
    end,
    cwd = function()
      local dll = prompt_dll_path()
      return vim.fn.fnamemodify(dll, ':h')
    end,
    console = 'integratedTerminal',
    stopAtEntry = false,
    justMyCode = false,
    env = function ()
      if not last_dll_path or #last_dll_path == 0 then
        prompt_dll_path()
      end
      if not last_env_short_name or #last_env_short_name == 0 then
        last_env_short_name = vim.fn.input('Environment short name ("dev", "qa", "prod"): ', 'dev')
      end

      local long_name
      if short_name == 'qa' then
	long_name = 'QA'
      elseif short_name == 'prod' then
	long_name = 'Production'
      else
	long_name = 'Development'
      end
      
      local port
      if vim.endswith(last_dll_path, 'SmartX.Uma.Api.dll') then
        port = 5200
      elseif vim.endswith(last_dll_path, 'Web.dll') then
        port = 5300
      elseif vim.endswith(last_dll_path, 'TradeRebalQueue.dll') then
        port = 5400
      else
        port = 5200
      end

      local env = {
        AWS_PROFILE = last_env_short_name,
        DOTNET_ENVIRONMENT = long_name,
        ASPNETCORE_ENVIRONMENT = long_name,
        ENVIRONMENT = long_name,
        SMX_DNS_SUFFIX = last_env_short_name .. 'smartx.us',
        ASPNETCORE_URLS = 'http://localhost:' .. port,
      }
      return env
    end,
  },
}
