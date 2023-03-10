import { compose, transform, translate, fromString, applyToPoints, toCSS } from 'transformation-matrix'

animationLoop = (fn, ctx) ->
    recent_timestamp = performance.now()
    tick = (timestamp) ->
        fn.call(ctx, timestamp - recent_timestamp)
        recent_timestamp = timestamp
        ctx.raf = requestAnimationFrame(tick)
    ctx.raf = requestAnimationFrame(tick)
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

responsiveHandler = (query, match_handler, unmatch_handler) ->
    layout = matchMedia query
    layout.addEventListener 'change', (e) ->
        if e.matches then match_handler() else unmatch_handler()
    if layout.matches then match_handler() else unmatch_handler()
    layout

export default class Bubblings
    constructor: (el) ->
        @el = el
        @$el = $(el)
        @$el.prop 'Bubblings', @
        @init()
    init: () ->
        me = @
        cover_ratio_max = 0.9
        cover_ratio_min = 0.6
        blur = 32
        aspect = @$el.width() / @$el.height()
        h = @$el.height()
        @$bubbles = @$el.find('.bubble')
        angles = distrubuteInRange @$bubbles.length, 0, 2 * Math.PI
        velocities = distrubuteInRange @$bubbles.length, 20/1000, 40/1000
        @$bubbles.each (idx, bubble) ->
            $bubble = $(bubble)
            cover = randomInRange cover_ratio_min, cover_ratio_max
            dim = h * cover - blur
            $bubble.css width: "#{ (dim / h)/aspect * 100 }%", height: "#{ dim / h * 100 }%"
            bubble.movement =
                angle: angles[idx]
                velocity: velocities[idx]
        @io = new IntersectionObserver (entries, observer) ->
            for entry in entries
                if entry.isIntersecting then me.go() else me.stop()
        , threshold: .38
        @io.observe @el
        responsiveHandler '(max-width:768px)',
            -> me.$bubbles.each () -> $(this).css transform: 'translate(-50%,-50%)'
            -> me.$bubbles.each () -> $(this).css transform: 'translate(-50%,-50%)'
        @
    stop: () ->
        cancelAnimationFrame @raf
        @
    go: () ->
        animationLoop (elapsed) ->
            me = @
            my_client_rect = me.el.getBoundingClientRect()
            @$bubbles.each (idx, el) ->
                mx = fromString(getComputedStyle(el).transform)
                r = el.getBoundingClientRect()
                dx = el.movement.velocity * elapsed * Math.cos(el.movement.angle)
                dy = el.movement.velocity * elapsed * Math.sin(el.movement.angle)
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


