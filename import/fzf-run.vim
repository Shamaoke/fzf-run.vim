vim9script
##               ##
# ::: Fzf Run ::: #
##               ##

def SetExitCb( ): func(job, number): string

  def Callback(job: job, status: number): string
    var commands: list<string>

    commands = ['quit']

    return execute(commands)
  enddef

  return Callback

enddef

def SetCloseCb(config: dict<any>, file: string): func(channel): string

  def Callback(channel: channel): string
    var data: list<string> = readfile(file)

    if data->len() < 2
      return execute([':$bwipeout', $"call delete('{file}')"])
    endif

    var key   = data->get(0)
    var entry = data->get(-1)

    var commands: list<string>

    commands = [':$bwipeout', config['commands'][key](entry), $"call delete('{file}')"]

    return execute(commands)
  enddef

  return Callback

enddef

def ExtendTermCommandOptions(config: dict<any>): list<string>
  var extensions = [ ]

  return config.term_command->extendnew(extensions)
enddef

def ExtendTermOptions(config: dict<any>): dict<any>
  var tmp_file = config.tmp_file()

  var extensions =
    { 'out_name': tmp_file,
      'exit_cb':  SetExitCb(),
      'close_cb': SetCloseCb(config, tmp_file) }

  return config.term_options->extendnew(extensions)
enddef

def ExtendPopupOptions(config: dict<any>): dict<any>
  var extensions =
    { 'minwidth':  (&columns * config['geometry']->get('width'))->ceil()->float2nr(),
      'minheight': (&lines * config['geometry']->get('height'))->ceil() ->float2nr() }

   return config.popup_options->extendnew(extensions)
enddef

def SetFzfCommand(config: dict<any>): void
  $FZF_DEFAULT_COMMAND = config.fzf_command(config.fzf_data())
enddef

def RestoreFzfCommand(config: dict<any>): void
  $FZF_DEFAULT_COMMAND = config->get('fzf_default_command')
enddef

def CreateFzfPopup(config: dict<any>): void
  term_start(
    config
      ->ExtendTermCommandOptions(),
    config
      ->ExtendTermOptions())
    ->popup_create(
        config
          ->ExtendPopupOptions())
enddef

export def Run(config: dict<any>): void
  SetFzfCommand(config)

  try
    CreateFzfPopup(config)
  finally
    RestoreFzfCommand(config)
  endtry
enddef

# vim: set textwidth=80 colorcolumn=80:
