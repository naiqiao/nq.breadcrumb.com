window.Yext = ((Yext) ->

  class Yext.Hours
    @autoRunInstances: true
    @instances: []

    @loadHoursData: ->
      $ '.js-location-hours'
        .each (idx, el) ->
          el.locationHours = new Yext.Hours
            element: el
          Yext.Hours.instances.push el
    @runInstances: ->
      for instanceElement in @instances
        instanceElement.locationHours.run()

    constructor: (args) ->
      {@element, @opts} = args

      @days = $(@element).data 'days'

      elOpts =
        showOpenToday: $(@element).data 'showopentoday'
        highlightToday: $(@element).data 'highlighttoday'

      today = new Date()

      @opts = $.extend elOpts, @opts

      # JS day of week -> Pages day of week
      # 0 -> 6
      # 1 -> 0
      # 2 -> 1
      # 3 -> 2

      @todayIndex = if today.getDay() == 0 then 6 else today.getDay() - 1
      @currentTimeStamp = today.getHours()*100 + today.getMinutes()
      captureThis = @

    isOpenNow: () ->
      currentDayData = @days[@todayIndex]
      openNow = false

      for interval in currentDayData.intervals
        if interval.start == interval.end == 0
          openNow = true
          break
        else if interval.start <= @currentTimeStamp
          if interval.end == 0
            openNow = true
            break
          else if interval.end >=@currentTimeStamp
            openNow = true
            break

      return openNow

    applyOpenToday: () ->
      captureThis = @
      $ '.js-day-of-week-row', @element
        .each (index, row) ->
          startIndex = $(row).data 'day-of-week-start-index'
          endIndex = $(row).data 'day-of-week-end-index'

          if captureThis.todayIndex >= startIndex and captureThis.todayIndex <= endIndex
            $(row).addClass 'is-today js-is-today'

            if captureThis.opts.showOpenToday?
              $('.js-opentoday', @element).show()

    applyOpenNow: () ->
      if @opts.openNowTarget? and @isOpenNow
        $ @opts.openNowTarget
          .addClass 'is-open-now'

    processTodayHours: () ->
      $ '.js-is-today .js-location-hours-interval-instance', @element
        .each (index, element) ->
          start = $(element).data('open-interval-start')
          end = $(element).data('open-interval-end')
          endMinutes = '00' + end%100
          endTimeStamp = "#{~~(end/100)}:#{endMinutes.slice(-2)} AM"
          endTimeStamp = "#{~~(end/100)-12}:#{endMinutes.slice(-2)} PM" if (end/100) > 12
          endTimeStamp = "12:#{endMinutes.slice(-2)} AM" if Math.floor(end/100) is 0
          today = new Date()
          currentHour = today.getHours()*100 + today.getMinutes()

          if start isnt end and (start isnt 0 or end isnt 0) # Not Open 24 hours
            if end is 0 and currentHour > start
              $(element).html($(element).data('midnight-text'))
            else if currentHour > start and currentHour < end
              $(element).html($(element).data('open-until-text') + " #{endTimeStamp}")
            else if currentHour > end and end isnt 0
              $(element).html($(element).data('close-at-text') + " <span class='currentlyClosed'>#{endTimeStamp}</span>")

    run: () ->
      @applyOpenNow()
      @applyOpenToday()
      @processTodayHours()

      if Yext.Callbacks?.hoursProcessed?
        Yext.Callbacks.hoursProcessed(@)

  return Yext
)(window.Yext || {})

$ ->
  Yext.Hours.loadHoursData()

  if Yext.Callbacks?.hoursWillRun?
    Yext.Callbacks.hoursWillRun()

  Yext.Hours.runInstances() if Yext.Hours.autoRunInstances
