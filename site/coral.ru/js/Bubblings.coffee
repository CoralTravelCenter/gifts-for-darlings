export default class Bubblings
    constructor: (el) ->
        @el = el
        @$el = $(el)
        @$el.prop 'Bubblings', @
        @init()
    init: () ->
        cover_ratio_max = 0.9
        cover_ratio_min = 0.62
        aspect = @$el.width() / @$el.height()
        h = @$el.height()
        @$bubbles = @$el.find('.bubble')
        @$bubbles.each (idx, b) ->
            cover = Math.random() * (cover_ratio_max - cover_ratio_min) + cover_ratio_min
            $(b).css width: "#{ cover/aspect * 100 }%", height: "#{ cover * 100 }%"
        @
