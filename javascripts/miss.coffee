((document) ->

  # Initializer
  miss = (selector = null, options = null) ->
    miss.missies = miss.missies || []
    miss.settings() unless miss.global
    defaults =
      order: 'series'
      background_color: '#f5f5f5'
      titlebar_color: '#939393'
      font_color: '#000'

    if selector
      els = document.querySelectorAll.call document, selector
      sel = selector.replace(/\./g,'_class_').replace(/\#/g,'_id_').replace(/[^a-zA-Z0-9]/g,'_')
      miss.off()
      for el, i in els
        opts = extend( extend(defaults, options), miss.global)
        title = opts.title || el.dataset.missTitle || null
        msg = message(opts.msg) || message(el.dataset.missMsg) || null
        miss.missies.push(new Miss(el, i, opts, title, msg)) unless !(title || msg)
      sortMissies()
      miss.on()

  # Constructor
  class Miss
    constructor: (el, i, opts, title, msg) ->
      @el = el
      @order = parseInt(@el.dataset.missOrder) || 100 + i
      @opts = opts
      @title = title
      @msg = msg

      # Functions called on initialize
      this.buildBox()

    buildBox: () =>
      # create elements with data
      box = document.createElement('div')
      box.id = "miss_#{@order}"
      box.className = 'miss-box'
      box.style.position = 'fixed'
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
        title_box.style.backgroundColor = @opts.titlebar_color
        title_box.style.borderTopLeftRadius = "3px"
        title_box.style.borderTopRightRadius = "3px"
        title_box.style.padding = '8px'
        msg_box.style.padding = '8px'
        li.style.listStyle = 'disc inside' for li in msg_box.querySelectorAll('li')
      # add them to DOM
      box.appendChild(title_box)
      box.appendChild(msg_box)
      showHideEl(box, false)
      miss.bd.appendChild(box)
      @box = box
      this.boxSizing()

    boxSizing: () =>
      # ensure box is on dom for obtaining dimensions
      bd_visible = miss.bd.visible || null
      box_visible = @box.visible || null
      unless bd_visible
        miss.bd.style.visibility = 'hidden'
        miss.on()
      unless box_visible
        @box.style.visibility = 'hidden'
        showHideEl(@box, true)
      coord = coords(@el)
      # set box dimensions
      @box.style.maxWidth = "30%"
      @box.style.maxHeight = "60%"
      # set box gravity
      gravitate = gravity(coord, @box.offsetHeight, @box.offsetWidth)
      @box.style.top = "#{gravitate.x}px"
      @box.style.left = "#{gravitate.y}px"
      # hide again
      unless bd_visible
        miss.bd.style.visibility = ''
        miss.off()
      unless box_visible
        @box.style.visibility = ''
        showHideEl(@box, false)

  # Helpers
  showHideEl = (el, toggle) ->
    if miss.global.compat.hidden
      if toggle then el.removeAttribute('hidden') and el.style.display = '' else el.setAttribute('hidden', true)
    else if toggle then el.style.display = '' else el.style.display = 'none'
    el.visible = toggle

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

  # Sort missies by order
  sortMissies = () ->
    miss.missies.sort((a, b) -> a['order'] - b['order'])

  # Get element coordinates
  coords = (el) ->
    rect = el.getBoundingClientRect()
    top: rect.top
    right: rect.right
    bottom: rect.bottom
    left: rect.left
    width: rect.width || rect.right - rect.left
    height: rect.height || rect.bottom - rect.top

  #Build test element for getting screen dimensions
  testEl = () ->
    unless test = document.getElementById('miss-size-test')
      test = document.createElement("div")
      test.id = 'miss-size-test'
      test.style.cssText = "position: fixed;top: 0;left: 0;bottom: 0;right: 0; visibility: hidden;"
      document.body.appendChild(test)
    height: test.offsetHeight
    width: test.offsetWidth

  # Gravitate to center
  gravity = (coords, height, width) ->
    ary_x = []
    ary_y = []
    center =
      x: testEl().height / 2
      y: testEl().width / 2
    el_center =
      x: coords.height / 2
      y: coords.width / 2
    box_center =
      x: height / 2
      y: width / 2
    map_x = [
      diff:
        top: Math.abs(coords.top - box_center.x - center.x)
        middle: Math.abs(coords.top - center.x)
        bottom: Math.abs(coords.top + box_center.x - center.x)
      val:
        top: coords.top - height
        middle: coords.top - box_center.x
        bottom: coords.top
      position: 'top'
    ,
      diff:
        top: Math.abs(coords.top + el_center.x - box_center.x - center.x)
        middle: Math.abs(coords.top + el_center.x - center.x)
        bottom: Math.abs(coords.top + el_center.x + box_center.x - center.x)
      val:
        top: coords.top + el_center.x - height
        middle: coords.top + el_center.x - box_center.x
        bottom: coords.top + el_center.x
      position: 'middle'
    ,
      diff:
        top: Math.abs(coords.bottom - box_center.x - center.x)
        middle: Math.abs(coords.bottom - center.x)
        bottom: Math.abs(coords.bottom + box_center.x - center.x)
      val:
        top: coords.bottom - height
        middle: coords.bottom - box_center.x
        bottom: coords.bottom
      position: 'bottom']
    map_y = [
      diff:
        left: Math.abs(coords.left - box_center.y - center.y)
        middle: Math.abs(coords.left - center.y)
        right: Math.abs(coords.left + box_center.y - center.y)
      val: 
        left: coords.left - width
        middle: coords.left - box_center.y
        right: coords.left
      position: 'left'
    ,
      diff:
        left: Math.abs(coords.left + el_center.y - box_center.y - center.y)
        middle: Math.abs(coords.left + el_center.y - center.y)
        right: Math.abs(coords.left + el_center.y + box_center.y - center.y)
      val: 
        left: coords.left + el_center.y - width
        middle: coords.left + el_center.y - box_center.y
        right: coords.left + el_center.y
      position: 'middle'
    ,
      diff:
        left: Math.abs(coords.right - box_center.y - center.y)
        middle: Math.abs(coords.right - center.y)
        right: Math.abs(coords.right + box_center.y - center.y)
      val: 
        left: coords.right - width
        middle: coords.right - box_center.y
        right: coords.right
      position: 'right']

    ary_x.push(xv) for xk, xv of v['diff'] for k, v of map_x
    ary_y.push(yv) for yk, yv of v['diff'] for k, v of map_y
    optimal_x = ary_x.sort((a,b) -> a - b)[0]
    optimal_y = ary_y.sort((a,b) -> a - b)[0]
    for k, v of map_x
      for xk, xv of v['diff']
        if xv == optimal_x then x = val: v.val[xk], position: "#{v['position']}_#{xk}"
    for k, v of map_y
      for yk, yv of v['diff']
        if yv == optimal_y then y = val: v.val[yk], position: "#{v['position']}_#{yk}"
    x: x.val
    y: y.val

  # Backdrop
  backdrop = (toggle) ->
    unless bd = document.getElementById('miss_bd')
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

  # Resize events
  window.onresize = () ->
    m.boxSizing() for i, m of miss.missies

  # Plugin states
  miss.on = () ->
    backdrop(true)

  miss.off = () ->
    backdrop(false)

  miss.destroy = () =>
    test = document.getElementById('miss-size-test')
    test.parentNode.removeChild(test)
    bd = document.getElementById('miss_bd')
    bd.parentNode.removeChild(bd)
    delete this.miss

  this.miss = miss

) document
