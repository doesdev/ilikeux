((document) ->

  # Initializer
  miss = (selector = null, options = null) ->
    miss.missies = miss.missies || {}
    miss.settings() unless miss.global
    defaults =
      order: 'series'
      background_color: '#000'
      font_color: '#000'
      z_index: 2100

    if selector
      els = document.querySelectorAll.call document, selector
      sel = selector.replace(/\./g,'_class_').replace(/\#/g,'_id_').replace(/[^a-zA-Z0-9]/g,'_')
      for el, i in els
        miss.missies[sel + '_' + i] = new Miss(el, i, extend(defaults, options))

  # Constructor
  class Miss
    constructor: (el, i, opts) ->
      @el = el
      @index = i
      @opts = extend(opts, miss.global)

      backdrop(1, opts.backdrop_color, opts.backdrop_opacity)

    logElement: () => console.log @el.innerHTML

  # Property normalization
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

  fullHex = (hex) ->
    return "#" + prepHex(hex)

  # Backdrop
  backdrop = (toggle, color = null, opacity = null) ->
    unless document.getElementById('miss_bd')
      rgb = colorConvert(color)
      bd = document.createElement("div")
      bd.id = 'miss_bd'
      bd.style.backgroundColor = "rgba(#{rgb.red}, #{rgb.green}, #{rgb.blue}, #{opacity})"
      bd.style.position = 'fixed'
      bd.style.top = 0; bd.style.right = 0; bd.style.bottom = 0; bd.style.left = 0
      bd.style.display = 'none'
      document.body.appendChild(bd)
    bd = document.getElementById('miss_bd')
    if bd.style.display == 'none' && toggle == 1 then bd.style.display = "" else bd.style.display = 'none'

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
    , set)

  this.miss = miss

) document
