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

def SetCloseCb(spec: dict<any>, file: string): func(channel): string

  def Callback(channel: channel): string
    var data: list<string> = readfile(file)

    if data->len() < 2
      return execute([':$bwipeout', $"call delete('{file}')"])
    endif

    var key   = data->get(0)
    var entry = data->get(-1)

    var commands: list<string>

    commands = [':$bwipeout', spec['commands'][key](entry), $"call delete('{file}')"]

    return execute(commands)
  enddef

  return Callback

enddef

def ExtendTermCommandOptions(spec: dict<any>): list<string>
  var extensions = [ ]

  return spec.term_command->extendnew(extensions)
enddef

def ExtendTermOptions(spec: dict<any>): dict<any>
  var tmp_file = spec.tmp_file()

  var extensions =
    { 'out_name': tmp_file,
      'exit_cb':  SetExitCb(),
      'close_cb': SetCloseCb(spec, tmp_file) }

  return spec.term_options->extendnew(extensions)
enddef

def ExtendPopupOptions(spec: dict<any>): dict<any>
  var extensions =
    { 'minwidth':  (&columns * spec['geometry']->get('width'))->ceil()->float2nr(),
      'minheight': (&lines * spec['geometry']->get('height'))->ceil() ->float2nr() }

   return spec.popup_options->extendnew(extensions)
enddef

def SetFzfCommand(spec: dict<any>): void
  $FZF_DEFAULT_COMMAND = spec.fzf_command(spec.fzf_data())
enddef

def RestoreFzfCommand(spec: dict<any>): void
  $FZF_DEFAULT_COMMAND = spec->get('fzf_default_command')
enddef

def CreateFzfPopup(spec: dict<any>): void
  term_start(
    spec
      ->ExtendTermCommandOptions(),
    spec
      ->ExtendTermOptions())
    ->popup_create(
        spec
          ->ExtendPopupOptions())
enddef

export def Run(spec: dict<any>): void
  SetFzfCommand(spec)

  try
    CreateFzfPopup(spec)
  finally
    RestoreFzfCommand(spec)
  endtry
enddef

# vim: set textwidth=80 colorcolumn=80:
