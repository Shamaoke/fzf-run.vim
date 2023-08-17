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

def SetCloseCb(spec: dict<any>): func(channel): string

  def Callback(channel: channel): string
    var tmp_file = spec['tmp_file']
    var tmp_data = spec['tmp_data']

    var data: list<string> = readfile(tmp_file)

    if data->len() < 2
      return execute([':$bwipeout', $"call delete('{tmp_file}')", $"call delete('{tmp_data}')"])
    endif

    var key   = data->get(0)
    var entry = data->get(-1)

    var commands: list<string>

    commands = [
      ':$bwipeout',
      spec['commands'][key](entry),
      $"call delete('{tmp_file}')",
      $"call delete('{tmp_data}')",
    ]

    return execute(commands)
  enddef

  return Callback

enddef

def ExtendTermCommandOptions(spec: dict<any>, extensions: list<string>): list<string>
  return spec.term_command->extendnew(extensions)
enddef

def ExtendTermOptions(spec: dict<any>): dict<any>
  var extension =
    { 'out_name': spec['tmp_file'],
      'exit_cb':  SetExitCb(),
      'close_cb': SetCloseCb(spec) }

  return spec.term_options->extendnew(extension)
enddef

def ExtendPopupOptions(spec: dict<any>): dict<any>
  var extensions =
    { 'minwidth':  (&columns * spec['geometry']->get('width'))->ceil()->float2nr(),
      'minheight': (&lines * spec['geometry']->get('height'))->ceil() ->float2nr() }

   return spec.popup_options->extendnew(extensions)
enddef

def SetTmpFiles(spec: dict<any>): dict<any>
  var extension = spec->extendnew(
    { 'tmp_file': spec.set_tmp_file(),
      'tmp_data': spec.set_tmp_data()  })

  return extension
enddef

def SetFzfData(spec: dict<any>): void
  spec.set_fzf_data(spec['tmp_data'])
enddef

export def Run(spec: dict<any>): void
  var new_spec = SetTmpFiles(spec)

  SetFzfData(new_spec)

  term_start(
    new_spec
      ->ExtendTermCommandOptions(new_spec.set_term_command_options(new_spec['tmp_data'])),
    new_spec
      ->ExtendTermOptions())
    ->popup_create(
        new_spec
          ->ExtendPopupOptions())
enddef

# vim: set textwidth=80 colorcolumn=80:
