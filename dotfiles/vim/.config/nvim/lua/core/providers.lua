-- virtualenv using poetry in `./providers/python3`
local python3_host_prog = '/home/jeewangue/.cache/pypoetry/virtualenvs/python3-YosyxKBh-py3.12/bin/python'

if vim.uv.fs_stat(python3_host_prog) then
  vim.g.python3_host_prog = python3_host_prog
end
