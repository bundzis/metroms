

# ==========================================================================
#  BCU ADDITION: Rule to fix long Fortran flag lines in a specific file
# ==========================================================================

FIX_FILE = $(SCRATCH_DIR)/mod_strings.f90
FIX_LINE_NUM = 260
LINE_LIMIT   = 132

fix_long_fflags: $(FIX_FILE)
	@echo "Fixing long character line in $(FIX_FILE) at line $(FIX_LINE_NUM)..."
	cp $(FIX_FILE) $(FIX_FILE).tmp
	awk -v line_num=$(FIX_LINE_NUM) -v limit=$(LINE_LIMIT) ' \
	BEGIN { FS = "\"" } \
	NR == line_num && length($$0) > limit { \
		prefix = $$1; \
		str_content = $$2; \
		suffix = $$3; \
		\
		available = limit - length(prefix) - 1; \
		\
		remaining = str_content; \
		while (length(remaining) > available) { \
			breakpoint = match(substr(remaining, 1, available), / *[[:space:]]/); \
			if (breakpoint == 0) { \
				breakpoint = available; \
			} else { \
				breakpoint = RSTART + RLENGTH - 1; \
			} \
			\
			chunk = substr(remaining, 1, breakpoint); \
			\
			printf "%s\"%s\" // &\n", (NR == line_num ? prefix : "     "), chunk; \
			\
			remaining = substr(remaining, breakpoint + 1); \
			\
			available = limit - 5; \
			NR++; \
		} \
		\
		printf "     \"%s\"%s\n", remaining, suffix; \
		next; \
	} \
	{ \
		print $$0; \
	} \
	' $(FIX_FILE).tmp > $(FIX_FILE)
	rm $(FIX_FILE).tmp
	@echo "Fix applied."


# ==========================================================================
#  End of USER ADDITION
# ==========================================================================



