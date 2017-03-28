$ ->
  $(".c-events .js-show-more").click (e) ->
    eventDescription = $(@).closest(".c-events-section-event-details-description")
    eventDescription.addClass "show-full-description"
    e.preventDefault()

  $(".c-events .js-show-less").click (e) ->
    eventDescription = $(@).closest(".c-events-section-event-details-description")
    eventDescription.removeClass "show-full-description"
    e.preventDefault()

  filterEvents()

# Only display the number of events specified. This fixes the fact that calendars json returned includes
# all events, even if they've expired, since old events do not get purged automatically (only after a
# publish). This cannot be done in SOY because a running counter is required.
# Display all unexpired events by default, otherwise only show the number specified.
filterEvents = () ->
  eventsToDisplay = $('.c-events-wrapper').data('events-to-display')
  todaysDate = new Date().toISOString()
  eventsDisplayed = 0
  $('.c-events-event').each ->
    startDate = $(@).data('event-start')
    endDate = $(@).data('event-end')
    if (endDate == undefined && todaysDate >= startDate) || todaysDate >= endDate || eventsDisplayed == eventsToDisplay
      $(@).hide()
    else
      eventsDisplayed++

  # All events were hidden
  if eventsDisplayed == 0
    $('.c-events').append($('.c-events').data('no-events'))