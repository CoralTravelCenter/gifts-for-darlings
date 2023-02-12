import { compose, transform, translate, fromString, applyToPoints, toCSS } from 'transformation-matrix'

animationLoop = (fn, ctx) ->
    recent_timestamp = performance.now()
    tick = (timestamp) ->
        fn.call(ctx, timestamp - recent_timestamp)
        recent_timestamp = timestamp
        requestAnimationFrame(tick)
    requestAnimationFrame(tick)
    tick

randomInRange = (min,max) -> Math.random() * (max-min) + min

distrubuteInRange = (qty, min, max) ->
    span = (max - min) / qty
    value = randomInRange min, min + span
    series = [value]
    series.push value += span for i in [0..qty - 1] if qty > 1
    series

overlaps = (rect, topleft, bottomright) ->
    overlap =
        top: topleft.y < rect.top
        left: topleft.x < rect.left
        bottom: bottomright.y > rect.bottom
        right: bottomright.x > rect.right

export default class Bubblings
    constructor: (el) ->
        @el = el
        @$el = $(el)
        @$el.prop 'Bubblings', @
        @init()
    init: () ->
        @velocity = randomInRange 10/1000, 30/1000
        cover_ratio_max = 0.9
        cover_ratio_min = 0.6
        blur = 32
        aspect = @$el.width() / @$el.height()
        h = @$el.height()
        @$bubbles = @$el.find('.bubble')
        angles = distrubuteInRange @$bubbles.length, 0, 2 * Math.PI
        velocities = distrubuteInRange @$bubbles.length, 10/1000, 20/1000
        @$bubbles.each (idx, bubble) ->
            $bubble = $(bubble)
            cover = randomInRange cover_ratio_min, cover_ratio_max
            dim = h * cover - blur
            $bubble.css width: "#{ (dim / h)/aspect * 100 }%", height: "#{ dim / h * 100 }%"
            bubble.movement =
                angle: angles[idx]
                velocity: velocities[idx]
        $(window).on 'resize orientationchange', ->
        @
    go: () ->
        animationLoop (elapsed) ->
            me = @
            my_client_rect = me.el.getBoundingClientRect()
            @$bubbles.each (idx, el) ->
                mx = fromString(getComputedStyle(el).transform)
                r = el.getBoundingClientRect()
                dx = me.velocity * elapsed * Math.cos(el.movement.angle)
                dy = me.velocity * elapsed * Math.sin(el.movement.angle)
                step_mx = translate(dx, dy)
                [moved_rect_topleft, moved_rect_bottomright] = applyToPoints step_mx, [
                    { x: r.left, y: r.top }
                    { x: r.right, y: r.bottom }
                ]
                over = overlaps my_client_rect, moved_rect_topleft, moved_rect_bottomright
                if over.top or over.bottom
                    el.movement.angle *= -1
                else if over.left or over.right
                    el.movement.angle = Math.PI - el.movement.angle
                else
                    el.style.transform = toCSS(compose(mx, step_mx))
        , @
        @


