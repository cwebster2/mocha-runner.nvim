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

## Using it

Run `:MochaRunner` in a buffer that has mocha tests in it, and it will run them
and annotate their pass/fail status and update it on every write of that file.
