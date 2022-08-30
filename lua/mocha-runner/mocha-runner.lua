local M = {}

M.config = {
  mocha_args = "",
  mocha_bin = "mocha",
  test_file_pattern = "*/test/*.js",
  pass_message = " ✓ Test Passed",
  fail_message = " Test Failed",
}

local function runTests()
  -- run test and decorate buffer
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local mocha = M.config.mocha_bin .. " " .. M.config.mocha_args .. " " .. filename .. " --reporter json"

  vim.fn.jobstart(mocha, {
    stdout_buffered = true,
    on_stdout = function(_,data)

      vim.diagnostic.reset(M.ns_id, bufnr)
      vim.api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1)

      local json = vim.fn.json_decode(data)
      local failures = json.stats.failures
      local passes = json.stats.passes

      if passes > 0 then
        for _, result in pairs(json.passes) do
          local lnr = vim.fn.search("\""..result.title.."\"", "nw")
          vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, lnr - 1, -1, {
            id = lnr - 1,
            virt_text = { { M.config.pass_message, "MochaRunnerSuccess" } },
            virt_text_pos = "eol",
            hl_eol = true,
            -- virt_lines_above = true,
            priority = 1
          })
        end
      end

      if failures > 0 then
        local diagnostics = {}
        for _, result in pairs(json.failures) do
          local lnr = vim.fn.search("\""..result.title.."\"", "nw")
          vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, lnr - 1, -1, {
            id = lnr - 1,
            virt_text = { { M.config.fail_message, "MochaRunnerFailure" } },
            virt_text_pos = "eol",
            hl_eol = true,
            -- virt_lines_above = true,
            priority = 1
          })
          table.insert(diagnostics, {
            lnum = lnr - 1,
            col = -1,
            severity = vim.diagnostic.severity.ERROR,
            source = "mocha",
            message = result.err.message
          })
        end
        vim.diagnostic.set(M.ns_id, bufnr, diagnostics, {})
      end
    end
  })
end

local function setupAutoCommand()
  -- setup BufWrite autocommand to run test
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("mocha_runner", { clear = true}),
    pattern = M.config.test_file_pattern,
    callback = function() runTests() end,
  })
  runTests()
end

function M.setup(opts)
  -- setup command to enroll buffer in on-save behavior
  vim.api.nvim_create_user_command("MochaRunner", function() setupAutoCommand() end, {})

  M.config = vim.tbl_deep_extend("force", M.config, opts)
  M.ns_id = vim.api.nvim_create_namespace("mocharunner")
  vim.api.nvim_set_hl(0, "MochaRunnerSuccess", { fg = "green", bold = true})
  vim.api.nvim_set_hl(0, "MochaRunnerFailure", { fg = "red", bold = true})
end

return M
