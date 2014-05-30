((document) ->

  # Initializer
  miss = (selector = null, options = null) ->
    miss.missies = miss.missies || {}
    miss.settings() unless miss.global
    defaults =
      order: 'series'
      background_color: '#f5f5f5'
      titlebar_color: '#939393'
      font_color: '#000'

    if selector
      els = document.querySelectorAll.call document, selector
      sel = selector.replace(/\./g,'_class_').replace(/\#/g,'_id_').replace(/[^a-zA-Z0-9]/g,'_')
      for el, i in els
        miss.missies[sel + '_' + i] = new Miss(el, i, extend(defaults, options))

  # Constructor
  class Miss
    constructor: (el, i, opts) ->
      @el = el
      @coords = coords(@el)
      @order = @el.dataset.missOrder || 100 + i
      @opts = extend(opts, miss.global)
      @title = @el.dataset.missTitle || null
      @msg = if @el.dataset.missMsg then message(@el.dataset.missMsg) else null

      # Functions called on initialize
      backdrop(true) # ToDo: move this where it belongs
      unless !(@title || @msg)
        @gravity = gravity(@coords)
        this.buildBox()

    buildBox: () =>
      # create elements with data
      box = document.createElement('div')
      box.id = "miss_#{@order}"
      box.className = 'miss-box'
      box.style.position = 'fixed'
      box.style.top = "#{@gravity.x}px"
      box.style.left = "#{@gravity.y}px"
      title_box = document.createElement('div')
      title_box.className = 'miss-titlebar'
      title_box.innerHTML = @title
      msg_box = document.createElement('div')
      msg_box.className = 'miss-msg'
      msg_box.innerHTML = @msg
      # apply (minimal) styling
      unless miss.global.theme
        box.style.backgroundColor = @opts.background_color
        box.style.borderRadius = "3px"
        box.style.maxWidth = "20%"
        box.style.maxHeight = "40%"
        title_box.style.backgroundColor = @opts.titlebar_color
        title_box.style.borderTopLeftRadius = "3px"
        title_box.style.borderTopRightRadius = "3px"
        title_box.style.padding = '8px'
        msg_box.style.padding = '8px'
        li.style.listStyle = 'disc inside' for li in msg_box.querySelectorAll('li')
      # add them to DOM
      box.appendChild(title_box)
      box.appendChild(msg_box)
      miss.bd.appendChild(box)

  # Helpers
  showHideEl = (el, toggle) ->
    if miss.global.compat.hidden
      if toggle then el.removeAttribute('hidden') and el.style.display = '' else el.setAttribute('hidden', true)
    else if toggle then el.style.display = '' else el.style.display = 'none'

  extend = (objA, objB) ->
    for attr of objB
      objA[attr] = objB[attr]
    return objA

  colorConvert = (hex) ->
    red: parseInt((prepHex(hex)).substring(0, 2), 16)
    green: parseInt((prepHex(hex)).substring(2, 4), 16)
    blue: parseInt((prepHex(hex)).substring(4, 6), 16)

  prepHex = (hex) ->
    hex = (if (hex.charAt(0) is "#") then hex.split("#")[1] else hex)
    return if hex.length is 3 then hex + hex else hex

  # Get element coordinates
  coords = (el) ->
    rect = el.getBoundingClientRect()
    top: rect.top
    right: rect.right
    bottom: rect.bottom
    left: rect.left
    width: rect.width || rect.right - rect.left
    height: rect.height || rect.bottom - rect.top

  # Gravitate to center
  gravity = (coords) ->
    ary_x = []
    ary_y = []
    center =
      x: screen.height / 2
      y: screen.width / 2
    el_center =
      x: coords.height / 2
      y: coords.width / 2
    map_x =
      top:
        diff: Math.abs(coords.top - center.x)
        val: coords.top
      middle:
        diff: Math.abs((coords.top + el_center.x) - center.x)
        val: coords.top + el_center.x
      bottom:
        diff: Math.abs(coords.bottom - center.x)
        val: coords.bottom
    map_y =
      left:
        diff: Math.abs(coords.left - center.y)
        val: coords.left
      middle:
        diff: Math.abs((coords.left + el_center.y) - center.y)
        val: coords.left + el_center.y
      right:
        diff: Math.abs(coords.right - center.y)
        val: coords.right

    ary_x.push(v['diff']) for k, v of map_x
    ary_y.push(v['diff']) for k, v of map_y
    optimal_x = ary_x.sort((a,b) -> a - b)[0]
    optimal_y = ary_y.sort((a,b) -> a - b)[0]
    x = v['val'] if v['diff'] == optimal_x for k, v of map_x
    y = v['val'] if v['diff'] == optimal_y for k, v of map_y
    x: x
    y: y

  # Backdrop
  backdrop = (toggle) ->
    unless document.getElementById('miss_bd')
      opts =  miss.global
      rgb = colorConvert(opts.backdrop_color)
      bd = document.createElement('div')
      bd.id = 'miss_bd'
      bd.style.backgroundColor = "rgba(#{rgb.red}, #{rgb.green}, #{rgb.blue}, #{opts.backdrop_opacity})"
      bd.style.position = 'fixed'
      bd.style.zIndex = opts.z_index
      bd.style.top = 0; bd.style.right = 0; bd.style.bottom = 0; bd.style.left = 0
      showHideEl(bd, false)
      document.body.appendChild(bd)
    bd = document.getElementById('miss_bd')
    miss.bd = bd
    showHideEl(bd, toggle)

  # Format message
  message = (msg) ->
    if (/#{(.*?)}/.test(msg))
      msg_el = document.querySelector(msg.match(/#{(.*?)}/)[1])
      showHideEl(msg_el, false)
      return msg_el.innerHTML
    else
      return msg

  # Global settings
  miss.settings = (set) ->
    miss.global = extend(
      theme: null
      trigger: null
      key_on: null
      key_off: null
      key_hover: null
      backdrop_color: '#000'
      backdrop_opacity: 0.3
      z_index: 2100
      compat:
        hidden: !!('hidden' of document.createElement('div'))
    , set)

  # Plugin states
  miss.on = () ->
    backdrop(true)

  miss.off = () ->
    backdrop(false)

  miss.destroy = () =>
    el = document.getElementById("miss_bd")
    el.parentNode.removeChild(el)
    delete this.miss

  this.miss = miss

) document
