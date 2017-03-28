window.Yext = window.Yext || {}
window.Yext.Analytics = window.Yext.Analytics || {}
window.Yext.Analytics.Helpers =
  defaultTimeout: 500
  checkSelectorExists: true
  trackLink: (selector, name, selectorOptional, timeout) ->
    handler = (event) ->
      el = event.srcElement or event.target
      # Check if it is a link to an external page (off-domain)
      if el.href and el.href.indexOf(location.host) is -1
        timeout = null
        # if target not set then delay opening of window by 0.5s to allow
        # tracking

        if not el.target or el.target.match(/^_(self|parent|top)$/i)
          timeout = setTimeout ->
            document.location.href = el.href
            return
          , (timeout || Yext.Analytics.Helpers.defaultTimeout)

          window.yext_analytics name, (evt) ->
            window.clearTimeout timeout
            document.location.href = el.href
            return

          # Prevent standard click
          if event.preventDefault
            event.preventDefault()
          else
            event.returnValue = not 1
        else
          window.yext_analytics name

      else
        window.yext_analytics name
      return
    elts = document.querySelectorAll selector
    if elts.length > 0
      for el in elts
        el.addEventListener 'click', handler
        el.dataset?.yextTracked = true
    else if Yext.Analytics.Helpers.checkSelectorExists and not selectorOptional
      if console
        if console.error
          console.error "No elements found for selector: #{selector}"
        else
          console.log "No elements found for selector: #{selector}"
  debug: ->
    els = document.querySelectorAll('[data-yext-tracked]')
    for el in els
      el.style.outline = '#66ff00 solid 3px'