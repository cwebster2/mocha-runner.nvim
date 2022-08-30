Better docs Coming soon

Install with packer:

```lua
use {
  "cwebster2/mocha-runner.nvim",
  config = function() require("mocha-runner").setup(options) end,
}
```

Where `options` is a table that accepts the following keys

```lua
options = {
  mocha_args = "",
  mocha_bin = "mocha",
  pass_message = " ✓ Test Passed",
  fail_message = " Test Failed",
}
```

You can customize the look of the pass and fail messages with the highlight
groups `MochaRunnerSuccess` and `MochaRunnerFailure`.
