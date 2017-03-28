window.Yext = ((Yext) ->
  Yext.StateList = ((StateList) ->

    StateList = $.extend StateList,
      id: '#us-map'
      fillColor: '#2B2B2C'
      seriesFillColor: '#95979A'
      strokeColor: 'black'
      hoverFillColor: '#E22136'

    StateList = $.extend StateList,
      mapRenderConfig:
        map: "us_aea_en"
        backgroundColor: 'none'
        zoomOnScroll: false
        regionStyle:
          initial:
            fill: StateList.fillColor
            stroke: StateList.strokeColor
            "stroke-width": 1
            cursor: "pointer"

          hover:
            fill: StateList.hoverFillColor
            "fill-opacity": 1

        series:
          regions: [
            scale:
              0: '#000'
              1: StateList.seriesFillColor

            attribute: "fill"
            values: StateList.vals
          ]

        onRegionClick: (event, code) ->
          i = StateList.keys.length - 1

          while i >= 0
            keyCode = "US-" + StateList.keys[i].key
            window.location.href = Yext.BaseUrl + StateList.keys[i].url  if code is keyCode
            i--
          return

        onRegionLabelShow: (e, el, code) ->
          e.preventDefault()
          return

        onRegionOver: (event, code) ->
          map = $(StateList.id).vectorMap("get", "mapObject")
          event.preventDefault()  unless map.series.regions[0].values[code]
          return

    StateList = $.extend StateList,
      renderMap: ->
        $ StateList.id
          .vectorMap StateList.mapRenderConfig

    return StateList
  )(Yext.StateList || {})
  return Yext
)(window.Yext || {})

$ ->
  window.Yext.StateList.renderMap()

