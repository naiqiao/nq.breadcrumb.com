trackOutBoundClick = () ->
  clickTarget = @
  unless $(clickTarget).data 'gaNoTrack'

    cat = $ clickTarget
      .data 'gaCategory'

    cat = 'Outbound Click' unless cat

    href = $ clickTarget
      .attr 'href'

    gaEvent =
      hitType: 'event',
      eventCategory: cat,
      eventAction: 'click',
      eventLabel: href
      hitCallback: () ->
        unless $(clickTarget).attr('target') is '_blank'
          document.location = href

    ga 'send', gaEvent

$ ->
  $("a[href^='http']").click trackOutBoundClick
