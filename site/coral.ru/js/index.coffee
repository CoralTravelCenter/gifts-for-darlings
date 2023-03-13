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

import tt_valentine_markup from 'bundle-text:/site/coral.ru/components/tooltip-valentine.html'
import tt_army_markup from 'bundle-text:/site/coral.ru/components/tooltip-army.html'
import tt_march8_markup from 'bundle-text:/site/coral.ru/components/tooltip-march8.html'
import tt_mar27_02_markup from 'bundle-text:/site/coral.ru/components/tooltip-mar27-02.html'
import tt_feb18_26_markup from 'bundle-text:/site/coral.ru/components/tooltip-feb18-26.html'

import Bubblings from './Bubblings.coffee'


tooltips =
    feb14:
        markup: tt_valentine_markup
        options: {}
    feb23:
        markup: tt_army_markup
        options: {}
    mar8:
        markup: tt_march8_markup
        options: {}
    'mar27-apr02':
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

    $(window).on 'scroll', ->
        dtop = $('section.destinations').get(0).getBoundingClientRect().top
        destinations_in_view = dtop < 300
        footer_in_view = $('.footermaincontainer').get(0).getBoundingClientRect().top < window.innerHeight
        $('.occassion-selector').toggleClass 'shown', destinations_in_view and not footer_in_view

    $('.occassion-selector li').on 'click', ->
        $this = $(this)
        $this.parent().toggleClass 'open'
        unless $this.hasClass 'selected'
            $this.addClass('selected').siblings('.selected').removeClass('selected')

    $(document).on 'click', '.country-block [data-group-marker]', ->
        group_marker = $(this).attr 'data-group-marker'
        $(".group-filters [data-group='#{ group_marker }']").click()

    $hotels_widgets = $('[id="hotels-set"]').map (idx, el) -> $(el).closest('.widgetcontainer').get(0)
    $hotels_widgets.each (idx) -> $(this).hide() if idx

    doSelectHolidays = (holidays) ->
        widget_idx = ['feb18-26','feb23','mar8','mar27-apr02'].indexOf holidays
        $hotels_widgets.each (idx, w) ->
            if idx == widget_idx
                iso = $(w).show().find('.cards-grid').data('isotope')
                iso.layoutItems(iso.items, true)
                iso.layout()
            else $(w).hide()
        $(".occassion-selector [data-select-holidays='#{ holidays }']").addClass('selected').siblings('.selected').removeClass('selected')

    $(document).on 'click', '[data-select-holidays]', ->
        doSelectHolidays $(this).attr 'data-select-holidays'

    doSelectHolidays 'mar27-apr02'

    $(document).on 'click', '[data-ym-reachgoal]', () -> ym?(553380,'reachGoal',$(this).attr('data-ym-reachgoal'))
    $(document).on 'click', '.card-cell .buttonlike', () -> ym?(553380,'reachGoal','zabr-holidays')
