require("conform").setup({
	formatters_by_ft = {
		-- Conform will run multiple formatters sequentially
		go = { "goimports", "gofmt" },
	},
	format_on_save = {
		-- I recommend these options. See :help conform.format for details.
		lsp_format = "fallback",
		timeout_ms = 500,
	},
})
