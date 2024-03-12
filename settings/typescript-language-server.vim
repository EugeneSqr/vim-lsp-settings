function! s:find_vue_plugin() abort
  let package_json_path = lsp#utils#find_nearest_parent_file(lsp#utils#get_buffer_path(), 'package.json')
  if empty(package_json_path)
    return v:null
  endif

  let package_json = json_decode(join(readfile(package_json_path), ''))
  if !(has_key(package_json, 'dependencies') && has_key(package_json['dependencies'], 'vue'))
    return v:null
  endif

  let plugin_location = lsp_settings#servers_dir() .. '/volar-server/node_modules/@vue/typescript-plugin'
  if !isdirectory(plugin_location)
    call lsp_settings#utils#warning('Please install the latest volar-server to enable Vue support')
    return v:null
  endif

  return {
  \ 'name': '@vue/typescript-plugin',
  \ 'location': plugin_location,
  \ 'languages': ['vue'],
  \ }
endfunction

function! Vim_lsp_settings_typescript_language_server_setup_plugins() abort
  let plugins = []

  let vue_plugin = s:find_vue_plugin()
  if !empty(vue_plugin)
    call add(plugins, vue_plugin)
  endif

  return plugins
endfunction

augroup vim_lsp_settings_typescript_language_server
  au!
  LspRegisterServer {
      \ 'name': 'typescript-language-server',
      \ 'cmd': {server_info->lsp_settings#get('typescript-language-server', 'cmd', [lsp_settings#exec_path('typescript-language-server')]+lsp_settings#get('typescript-language-server', 'args', ['--stdio']))},
      \ 'root_uri':{server_info->lsp_settings#get('typescript-language-server', 'root_uri', lsp_settings#root_uri('typescript-language-server'))},
      \ 'initialization_options': lsp_settings#get('typescript-language-server', 'initialization_options', {
      \   'preferences': {
      \     'includeInlayParameterNameHintsWhenArgumentMatchesName': v:true,
      \     'includeInlayParameterNameHints': 'all',
      \     'includeInlayVariableTypeHints': v:true,
      \     'includeInlayPropertyDeclarationTypeHints': v:true,
      \     'includeInlayFunctionParameterTypeHints': v:true,
      \     'includeInlayEnumMemberValueHints': v:true,
      \     'includeInlayFunctionLikeReturnTypeHints': v:true
      \   },
      \   'plugins': Vim_lsp_settings_typescript_language_server_setup_plugins(),
      \ }),
      \ 'allowlist': lsp_settings#get('typescript-language-server', 'allowlist', ['javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'typescript.tsx', 'vue']),
      \ 'blocklist': lsp_settings#get('typescript-language-server', 'blocklist', {c->empty(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'node_modules/')) ? ['typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue'] : []}),
      \ 'config': lsp_settings#get('typescript-language-server', 'config', lsp_settings#server_config('typescript-language-server')),
      \ 'workspace_config': lsp_settings#get('typescript-language-server', 'workspace_config', {}),
      \ 'semantic_highlight': lsp_settings#get('typescript-language-server', 'semantic_highlight', {}),
      \ }
augroup END
