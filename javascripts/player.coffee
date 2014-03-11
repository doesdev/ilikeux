$ ->

  window.musocrat = window.musocrat || {}

  # ToDo: log all audio decoding / playback errors to server

  # Global variables / objects
  ###################
  window.AudioContext = window.AudioContext || window.webkitAudioContext

  # Scoped variables / objects
  ###################
  musocrat.context = new AudioContext()
  musocrat.sync = musocrat.sync || 0 # [ 0 = reset, 1 = continuous ]
  musocrat.baseTTS = musocrat.baseTTS || {}
  musocrat.buffers = {}
  musocrat.buffers.players = {}
  musocrat.buffers.active = []
  musocrat.buffers.playing = []
  musocrat.buffers.cache = []

  # Helper Functions
  ###################
  rmFromArray = (array, value) ->
    in_array = $.inArray(value, array)
    array.splice(in_array, 1) unless in_array == -1

  # Player
  ###################
  class Player
    constructor: (id, url, tts, offset) ->
      @id = id
      @url = url
      @tts = tts || 0
      @offset = offset || 0
      @cached = if ($.inArray(@id, musocrat.buffers.active) >= 0) then true else false
      @clone = if @cached then this.getCachedBuffer() else null
      @audio = musocrat.context.createBufferSource()
      @ready = false
      @error = false
      @playing = false
      @started = 0
      @position = -> (musocrat.context.currentTime - @started) + @offset
      this.buffer()
      this.baseTTS()

    # load file into buffer
    buffer: () =>
      if @clone != null
        buffer = @clone.buffer
        buffer = musocrat.context.createBuffer(buffer.numberOfChannels, buffer.length, buffer.sampleRate)
        for i in [0...buffer.numberOfChannels]
          buffer.getChannelData(i).set(@clone.arraybuffer[i])
        this.loaded(buffer)
      else
        request = new XMLHttpRequest()
        request.open('GET', @url, true)
        request.responseType = 'arraybuffer'
        request.onload = () ->
          musocrat.context.decodeAudioData(request.response, bufferSetup, decodeError)
        request.send()

      bufferSetup = (buffer) =>
        this.loaded(buffer)

      decodeError = (error) =>
        console.error "Audio decoding error: #{error}"
        @error = true

      return

    # connect, clone, and mark ready
    loaded: (buffer) =>
      @audio.buffer = buffer
      console.log "#{@id} loaded"
      @audio.connect(musocrat.context.destination)
      this.cloneBuffer() unless @cached
      musocrat.buffers.active.push(@id) unless $.inArray(@id, musocrat.buffers.active) >= 0
      @ready = true

    # clone buffer for pause / resume
    cloneBuffer: () =>
      buffer = @audio.buffer
      arraybuffer = []
      for i in [0...buffer.numberOfChannels]
        arraybuffer[i] = new Float32Array(buffer.getChannelData(i))
      musocrat.buffers.cache.push({id: @id, data: {buffer: @audio.buffer, arraybuffer: arraybuffer}})

    # retreive cached buffer
    getCachedBuffer: () =>
      for i in [0...musocrat.buffers.cache.length]
        return musocrat.buffers.cache[i].data if musocrat.buffers.cache[i].id == @id

    # set base tts to lowest active buffer tts
    baseTTS: () =>
      all_tts = []
      $.each(musocrat.buffers.players, (key, buffer) ->
        all_tts.push({id: buffer.id, tts: buffer.tts})
      )
      musocrat.baseTTS = all_tts.sort((b1, b2) -> return b1.tts - b2.tts)[0]

    # start position algorithm based on relative tts, sync, and offset, return start position
    time: () =>
      switch
        when @offset < 0
          @start_time = Math.abs(@offset)
          @offset = 0
        when @offset > 0
          @start_time = 0
        else
          @start_time = @tts - musocrat.baseTTS.tts

    # play this buffer
    play: () =>
      if @ready
        this.time()
        console.log "current: #{musocrat.context.currentTime}, start: #{@start_time}, offset: #{@offset}"
        @audio.start(musocrat.context.currentTime + @start_time, @offset)
        @started = musocrat.context.currentTime + @start_time
        musocrat.buffers.playing.push(@id)
        @playing = true

    # stop and destroy this instance
    stop: () =>
      if this.playing
        @audio.stop 0
      this.clean()

    # get playback position, stop, replace player with start position set to current position
    pause: () =>
      console.log "started: #{@started}, current: #{musocrat.context.currentTime}, position: #{@position()}"
      @audio.stop 0
      rmFromArray(musocrat.buffers.playing, @id)
      musocrat.buffers.players["player#{@id}"] = new Player(@id, @url, @tts, @position())

    # stop, replace player
    reset: () =>
      @audio.stop 0
      rmFromArray(musocrat.buffers.playing, @id)
      musocrat.buffers.players["player#{@id}"] = new Player(@id, @url, @tts, 0)

    # set volume
    #volume: () =>

    clean: () =>
      rmFromArray(musocrat.buffers.active, @id)
      rmFromArray(musocrat.buffers.playing, @id)
      length = musocrat.buffers.cache.length
      for i in [0...length]
        musocrat.buffers.cache.splice(i, 1) if musocrat.buffers.cache[i].id == @id
        length = musocrat.buffers.cache.length
      delete musocrat.buffers.players["player#{@id}"]

  ###################
  #/ end Player


  # Functions
  ###################

  # orchestrates the playback controls of active parts,
  # action accepts 'load', 'play', 'playall', 'stop', 'stopall','pause', 'pauseall', 'reset', 'resetall'
  # ids accepts array of part ids, or single part id
  # parts accepts array of parts objects
  musocrat.composer = (action, parts = null, ids = null) ->
    ids = if $.isArray(ids) then ids else [ids]
    switch
      when action == 'load'
        bufferBuilder(parts) unless parts == null
      when action == 'play'
        buffersPlay(ids)
      when action == 'playall'
        buffersPlay()
      when action == 'stop'
        buffersStop(ids)
      when action == 'stopall'
        buffersStop()
      when action == 'pause'
        buffersPause(ids)
      when action == 'pauseall'
        buffersPause()
      when action == 'reset'
        buffersReset(ids)
      else
        buffersReset()

  # takes array of parts objects (containing id, url, tts) and pushes a new player instance to musocrat.buffers.players for each
  bufferBuilder = (parts) ->
    $.each(parts, (i, data) ->
      musocrat.buffers.players["player#{data.id}"] = new Player(data.id, data.url, data.tts)
    )

  # call Player.play on each specified (or all) buffer(s) if all are ready
  buffersPlay = (ids = null, tries = 0) =>
    buffersArray = []
    $.each(musocrat.buffers.players, (k) -> buffersArray.push(musocrat.buffers.players[k]))
    if buffersArray.every((buffer) -> buffer.ready)
      $.each(musocrat.buffers.players, (key, buffer) ->
        buffer.play() if (ids == null || $.inArray(buffer.id, ids) >= 0)
      )
    else if tries < 30
      tries++
      setTimeout( (() -> buffersPlay(ids, tries)), 500)
    else
      console.error 'Problem buffering audio files!'

  # call Player.stop on each specified (or all) buffer(s)
  buffersStop = (ids = null) ->
    $.each(musocrat.buffers.players, (key, buffer) ->
      buffer.stop() if (ids == null || $.inArray(buffer.id, ids) >= 0)
    )

  # call Player.pause on each specified (or all) buffer(s)
  buffersPause = (ids = null) ->
    $.each(musocrat.buffers.players, (key, buffer) ->
      buffer.pause() if (ids == null || $.inArray(buffer.id, ids) >= 0)
    )

  # call Player.pause on each specified (or all) buffer(s)
  buffersReset = (ids = null) ->
    $.each(musocrat.buffers.players, (key, buffer) ->
      buffer.reset() if (ids == null || $.inArray(buffer.id, ids) >= 0)
    )

  # Bindings
  ###################
  $("#load-defaults").on 'click', () ->
    test_parts()

  $("#player-inner-circle").on 'click', () ->
    console.log musocrat.buffers.playing.length
    if musocrat.buffers.playing.length > 0
      musocrat.composer('pauseall')
    else
      musocrat.composer('playall')

  $("#pauseall").on 'click', () ->
    musocrat.composer('pauseall')

  $("#stopall").on 'click', () ->
    musocrat.composer('stopall')

  $("#resetall").on 'click', () ->
    musocrat.composer('resetall')

  $("#unloadall").on 'click', () ->
    musocrat.composer('unloadall')

  # Testing
  ###################
  test_parts = () -> musocrat.composer('load', [
    id: 68
    url: 'https://s3.amazonaws.com/musocrat.s3/uploads/part/file/68/ogg_1012-folk-2-bass-22-4.ogg'
    tts: 51.433438
  ,
    id: 69
    url: 'https://s3.amazonaws.com/musocrat.s3/uploads/part/file/69/ogg_1012-folk-2-drums-20-2.ogg'
    tts: 2.884229
  ,
    id: 70
    url: 'https://s3.amazonaws.com/musocrat.s3/uploads/part/file/70/ogg_1012-folk-2-strings-21-3.ogg'
    tts: 33.6285
  ,
    id: 71
    url: 'https://s3.amazonaws.com/musocrat.s3/uploads/part/file/71/ogg_1012-folk-2-vibes-23-5.ogg'
    tts: 74.084375
  ,
    id: 72
    url: 'https://s3.amazonaws.com/musocrat.s3/uploads/part/file/72/ogg_1012-folk-2-violin-19-1.ogg'
    tts: 1.378844
  ,
    id: 73
    url: 'https://s3.amazonaws.com/musocrat.s3/uploads/part/file/73/ogg_1012-folk-2-vox-24-6.ogg'
    tts: 33.949677
  ])

  test_parts()
