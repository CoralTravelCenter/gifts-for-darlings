window.ASAP = (->
    fns = []
    callall = () ->
        f() while f = fns.shift()
    if document.addEventListener
        document.addEventListener 'DOMContentLoaded', callall, false
        window.addEventListener 'load', callall, false
    else if document.attachEvent
        document.attachEvent 'onreadystatechange', callall
        window.attachEvent 'onload', callall
    (fn) ->
        fns.push fn
        callall() if document.readyState is 'complete'
)()

log = () ->
    if window.console and window.DEBUG
        console.group? window.DEBUG
        if arguments.length == 1 and Array.isArray(arguments[0]) and console.table
            console.table.apply window, arguments
        else
            console.log.apply window, arguments
        console.groupEnd?()
trouble = () ->
    if window.console
        console.group? window.DEBUG if window.DEBUG
        console.warn?.apply window, arguments
        console.groupEnd?() if window.DEBUG

window.preload = (what, fn) ->
    what = [what] unless  Array.isArray(what)
    $.when.apply($, ($.ajax(lib, dataType: 'script', cache: true) for lib in what)).done -> fn?()

window.queryParam = queryParam = (p, nocase) ->
    params_kv = location.search.substr(1).split('&')
    params = {}
    params_kv.forEach (kv) -> k_v = kv.split('='); params[k_v[0]] = k_v[1] or ''
    if p
        if nocase
            return decodeURIComponent(params[k]) for k of params when k.toUpperCase() == p.toUpperCase()
            return undefined
        else
            return decodeURIComponent params[p]
    params

String::zeroPad = (len, c) ->
    s = ''
    c ||= '0'
    len ||= 2
    len -= @length
    s += c while s.length < len
    s + @
Number::zeroPad = (len, c) -> String(@).zeroPad len, c

window.DEBUG = 'APP NAME'

import definedBubbligs from './Bubblings.coffee'

import tt_valentine_markup from 'bundle-text:/site/coral.ru/components/tooltip-valentine.html'
import tt_army_markup from 'bundle-text:/site/coral.ru/components/tooltip-army.html'
import tt_march8_markup from 'bundle-text:/site/coral.ru/components/tooltip-march8.html'
import tt_mar27_02_markup from 'bundle-text:/site/coral.ru/components/tooltip-mar27-02.html'
import tt_feb18_26_markup from 'bundle-text:/site/coral.ru/components/tooltip-feb18-26.html'

import Bubblings from './Bubblings.coffee'


tooltips =
    valentine:
        markup: tt_valentine_markup
        options: {}
    army:
        markup: tt_army_markup
        options: {}
    march8:
        markup: tt_march8_markup
        options: {}
    'mar27-02':
        markup: tt_mar27_02_markup
        options: {}
    'feb18-26':
        markup: tt_feb18_26_markup
        options: {}

ASAP ->

    $('body .subpage-search-bg > .background').append $('#_intro_markup').html()

    preload 'https://cdnjs.cloudflare.com/ajax/libs/jquery-scrollTo/2.1.3/jquery.scrollTo.min.js', ->
        $(document).on 'click', '[data-scrollto]', -> $(window).scrollTo $(this).attr('data-scrollto'), 500, offset: -150

    preload 'https://cdnjs.cloudflare.com/ajax/libs/tooltipster/4.2.8/js/tooltipster.bundle.min.js', ->
        $('[data-holidays]').on
            mouseenter: (e) ->
                e.stopPropagation()
                $parent = $(this).addClass('hovered').parent().removeClass('hovered')
                if $parent.hasClass 'tooltipstered'
                    $parent.tooltipster('instance').close()
            mouseleave: (e) -> e.stopPropagation(); $(this).removeClass 'hovered'
        $('[data-holidays]').each (idx, el) ->
            $el = $(el)
            key = $el.attr 'data-holidays'
            if tooltips[key]
                options =
                    interactive: yes
                    trigger: 'custom'
                    triggerOpen:
                        mouseenter: yes
                        click: yes
                        tap: yes
                    triggerClose:
                        mouseleave: yes
                        click: yes
                    delay: 100
                    animation: 'grow'
                    contentAsHTML: yes
                    repositionOnScroll: yes
                    content: tooltips[key].markup
                Object.assign options, tooltips[key].options
                $el.tooltipster(options).tooltipster('instance').on 'repositioned', (e) ->
                    { tooltip, origin, position } = e
                    $tip = $(tooltip).find('.tip')
                    tt_rect = tooltip.getBoundingClientRect()
                    if position.side == 'top'
                        o_rect = Array.from(origin.getClientRects()).reduce (acc, rect) -> if rect.top < acc.top then rect else acc
                        x_shift = o_rect.left + o_rect.width / 2 - tt_rect.left
                        $tip.css left: "#{ x_shift }px", top: '100%', bottom: 'auto', transform: 'translate(-50%,0)'
                    else
                        o_rect = Array.from(origin.getClientRects()).reduce (acc, rect) -> if rect.bottom > acc.bottom then rect else acc
                        x_shift = o_rect.left + o_rect.width / 2 - tt_rect.left
                        $tip.css left: "#{ x_shift }px", bottom: '100%', top: 'auto', transform: 'translate(-50%,0) scaleY(-1)'

    icons_io = new IntersectionObserver (entries, observer) ->
        for entry in entries
            $(entry.target).find('svg').toggleClass 'active', entry.isIntersecting
    , threshold: 1.0
    $('.icon-art').each (idx, el) -> icons_io.observe el

    $('.bubbling').each (idx, el) -> new Bubblings(el)